/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.user.domain.Admin;
import com.huawei.sharedrive.uam.user.domain.AdminRole;
import com.huawei.sharedrive.uam.user.domain.MessageTemplate;
import com.huawei.sharedrive.uam.user.service.AdminService;
import com.huawei.sharedrive.uam.user.service.MessageTemplateService;
import com.huawei.sharedrive.uam.util.Constants;
import com.huawei.sharedrive.uam.util.PasswordGenerateUtil;
import com.huawei.sharedrive.uam.weixin.domain.WxDepartment;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.domain.WxWorkCorpApp;
import com.huawei.sharedrive.uam.weixin.rest.*;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxWorkOauth2SuiteProxy;
import com.huawei.sharedrive.uam.weixin.service.WxDepartmentService;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseUserService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkCorpAppService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkUserManager;
import com.huawei.sharedrive.uam.weixin.service.impl.WxDomainUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>当企业通信录中的部门和用户数据与系统数据不一致，用于增量增加数据</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Component
public class SyncAddressListTask extends SuiteTask {
    private static Logger logger = LoggerFactory.getLogger(SyncAddressListTask.class);

    @Autowired
    private WxDepartmentService wxDeptService;

    @Autowired
    private WxEnterpriseUserService wxUserService;

    @Autowired
    private WxWorkUserManager wxWorkUserManager;

    @Autowired
    private WxWorkOauth2SuiteProxy wxWorkOauth2SuiteProxy;

    @Autowired
    private WxWorkCorpAppService wxWorkCorpAppService;

    @Autowired
    private WxEnterpriseUserService wxEnterpriseUserService;

    @Autowired
    private AdminService adminService;

    @Autowired
    private MessageTemplateService messageTemplateService;

    private WxEnterprise enterprise;

    public SyncAddressListTask() {
    }

    public WxEnterprise getEnterprise() {
        return enterprise;
    }

    public void setEnterprise(WxEnterprise enterprise) {
        this.enterprise = enterprise;
    }

    @Override
    public void run() {
        //获取suite下所以已经安装的应用
        List<WxWorkCorpApp> appList = wxWorkCorpAppService.getByCorpIdAndSuiteId(corpId, suiteId);

        //查询部门列表
        QueryDepartmentResponse deptResponse = wxWorkOauth2SuiteProxy.getDepartmentList(corpId);
        if(deptResponse == null) {
            logger.error("Failed to query department list from corporate={}: query result is null.", enterprise.getId());
            return;
        }

        //返回错误
        if(deptResponse.hasError()) {
            logger.error("Failed to query department list from corporate={}, code={}, msg={}", enterprise.getId(), deptResponse.getErrcode(), deptResponse.getErrmsg());
            return;
        }

        //同步部门数据
        List<WxDepartment> dbDeptList = wxDeptService.listByCorpId(enterprise.getId());

        for(Department dept : deptResponse.getDepartment()) {
            WxDepartment wx = take(dbDeptList, dept.getId());

            WxDepartment newDept = WxDomainUtils.toWxDepartment(dept);
            newDept.setCorpId(enterprise.getId());
            newDept.setBoxEnterpriseId(enterprise.getBoxEnterpriseId());

            if(wx == null) {
                wxDeptService.create(newDept);
            } else {
                wxDeptService.update(newDept);
            }
        }

        //删除已经不存在的部门
        for(WxDepartment dept : dbDeptList) {
            wxDeptService.delete(enterprise.getId(), dept.getId());
        }

        //同步用户数据
        List<WxEnterpriseUser> dbUserList = wxUserService.getByCorpId(enterprise.getId());
        for(Department dept : deptResponse.getDepartment()) {
            QueryUserResponse userResponse = wxWorkOauth2SuiteProxy.getUserListOfDept(corpId, String.valueOf(dept.getId()));
            if(userResponse == null) {
                logger.error("Failed to query user list of dept: corporate={}, deptId={}", enterprise.getId(), dept.getId());
                continue;
            }
            if(!userResponse.hasError()) {
                for(User user : userResponse.getUserlist()) {
                    WxEnterpriseUser wx = take(dbUserList, user.getUserid());

                    WxEnterpriseUser newUser = WxDomainUtils.toWxEnterpriseUser(user);
                    newUser.setCorpId(enterprise.getId());
                    newUser.setBoxEnterpriseId(enterprise.getBoxEnterpriseId());
                    if(wx == null) {
                        wxWorkUserManager.openAccount(enterprise.getName(), newUser, appList);
                    } else {
                        wxUserService.update(newUser);
                    }
                }
            } else {
                logger.error("Failed to query department list from corporate={}, department={}, code={}, msg={}", enterprise.getId(), dept.getId(), deptResponse.getErrcode(), deptResponse.getErrmsg());
            }
        }

        //删除已经不存在的用户
        for(WxEnterpriseUser user : dbUserList) {
            wxUserService.delete(enterprise.getId(), user.getUserId());
        }

        //同步企业管理员信息
        if(appList.isEmpty()) {
            logger.error("Failed to create enterprise admin: no app installed. corpId={}, suiteId={}", corpId, suiteId);
            return;
        }
        String corpId = enterprise.getId();
        int agentId = appList.get(0).getAgentId();
        AdminListInfo adminList = wxWorkOauth2SuiteProxy.getCorpAdminList(corpId, agentId);
        if(adminList != null) {
            if(!adminList.hasError()) {
                for(AdminInfo admin : adminList.getAdmin()) {
                    WxEnterpriseUser user = wxEnterpriseUserService.get(corpId, admin.getUserid());
                    if(user != null) {
                        createEnterpriseAdmin(user, agentId);
                    } else {
                        logger.error("Failed to create enterprise admin: cannot find the user from wx_enterprise_user. corpId={}, userId={}", corpId, admin.getUserid());
                    }
                }
            } else {
                logger.error("Failed to create enterprise admin: error occurred while getting AdminListInfo. code={}, error={}", adminList.getErrcode(), adminList.getErrmsg());
            }
        } else {
            logger.error("Failed to create enterprise admin: AdminListInfo is null.");
        }
    }

    protected WxDepartment take(List<WxDepartment> deptList, Integer deptId) {
        for(int i = 0; i < deptList.size(); i++) {
            WxDepartment d = deptList.get(i);
            if(d.getId().equals(deptId)) {
                deptList.remove(i);
                return d;
            }
        }

        return null;
    }

    protected WxEnterpriseUser take(List<WxEnterpriseUser> userList, String userId) {
        for(int i = 0; i < userList.size(); i++) {
            WxEnterpriseUser u = userList.get(i);
            if(u.getUserId().equals(userId)) {
                userList.remove(i);
                return u;
            }
        }

        return null;
    }

    private void createEnterpriseAdmin(WxEnterpriseUser user, Integer agentId) {
        Admin admin = new Admin();
        HashSet<AdminRole> roles = new HashSet<>(1);
        roles.add(AdminRole.ENTERPRISE_MANAGER);

        admin.setEnterpriseId(user.getBoxEnterpriseId());
        admin.setLoginName(user.getUserId());
        admin.setName(user.getName());
        admin.setEmail(user.getEmail());
        admin.setRoles(roles);
        admin.setDomainType(Constants.DOMAIN_TYPE_LOCAL);

        String randomPassword = PasswordGenerateUtil.getRandomPassword(6);
        admin.setPassword(randomPassword);
        admin.setType(Constants.ROLE_ENTERPRISE_ADMIN);

        // loginName + enterpriseId唯一，不会有重名
        Admin oldAdmin = adminService.getByLoginNameAndEnterpriseId(admin.getLoginName(), user.getBoxEnterpriseId());
        if (oldAdmin == null) {
            adminService.create(admin);

            //发送消息通知用户
//            sendUserMessage(user.getCorpId(), agentId, user.getUserId(), admin);
        }
    }

    private void sendUserMessage(String corpId, Integer agentId, String userId, Admin admin) {
        MessageTemplate template = messageTemplateService.getById("createAdmin");

        if(template != null) {
            //在企业微信中发送消息。
            String message = template.getContent().replaceAll("(\\$\\{username})", admin.getLoginName());
            message = message.replaceAll("(\\$\\{password})", admin.getPassword());

            SendMessageResult result = wxWorkOauth2SuiteProxy.sendTextMessage(corpId, agentId, userId, message);
            if(result.hasError()) {
                logger.error("Failed to send message: corpId={}, agentId={}, user={}, code={}, error={}", corpId, agentId, userId, result.getErrcode(), result.getErrmsg());
            }
        } else {
            logger.warn("No Message Template found: id = createAdmin");
        }
    }
}
