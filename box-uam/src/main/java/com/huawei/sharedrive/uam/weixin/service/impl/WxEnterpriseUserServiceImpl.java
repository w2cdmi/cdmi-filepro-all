/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import java.util.List;

import com.huawei.sharedrive.uam.organization.service.DepartmentService;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamMemberInfo;
import com.huawei.sharedrive.uam.teamspace.domain.TeamSpace;
import com.huawei.sharedrive.uam.user.service.UserImageService;
import com.huawei.sharedrive.uam.util.PasswordGenerateUtil;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.manager.UserAccountManager;
import com.huawei.sharedrive.uam.authapp.service.AuthAppService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.manager.EnterpriseUserManager;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.organization.domain.DepartmentAccount;
import com.huawei.sharedrive.uam.organization.service.DepartmentAccountService;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamMember;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamMemberCreateRequest;
import com.huawei.sharedrive.uam.teamspace.service.TeamSpaceService;
import com.huawei.sharedrive.uam.weixin.dao.WxDepartmentDao;
import com.huawei.sharedrive.uam.weixin.dao.WxEnterpriseUserDao;
import com.huawei.sharedrive.uam.weixin.domain.WxDepartment;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseUserService;

import pw.cdmi.common.domain.enterprise.Enterprise;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>部门员工管理</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Service("weixinEnterpriseUserService")
public class WxEnterpriseUserServiceImpl implements WxEnterpriseUserService {
    private static final Logger logger = LoggerFactory.getLogger(WxEnterpriseUserServiceImpl.class);

    @Autowired
    private WxEnterpriseUserDao wxEnterpriseUserDao;

    @Autowired
    private WxDepartmentDao wxDepartmentDao;

    @Autowired
    private EnterpriseUserManager enterpriseUserManager;

    @Autowired
    private EnterpriseUserService enterpriseUserService;

    @Autowired
    private EnterpriseAccountService enterpriseAccountService;

    @Autowired
    private AuthAppService authAppService;

    @Autowired
    private UserAccountManager userAccountManager;

    @Autowired
    private DepartmentService departmentService;

    @Autowired
    private DepartmentAccountService deptAccountService;

    @Autowired
    private TeamSpaceService teamSpaceService;

    @Autowired
    private UserImageService userImageService;

    @Override
    public WxEnterpriseUser get(String corpId, String userId) {
        return wxEnterpriseUserDao.get(corpId, userId);
    }

    @Override
    public EnterpriseUser create(WxEnterpriseUser wxUser) {
        try {
            EnterpriseUser user = toEnterpriseUser(wxUser);
            WxDepartment dept = wxDepartmentDao.get(wxUser.getCorpId(), wxUser.getDepartmentId());
            user.setDepartmentId(dept.getBoxDepartmentId());
            long enterpriseUserId = enterpriseUserManager.createWeixin(user, true);

            //自动加入部门空间
            String appId = authAppService.getDefaultWebApp().getAuthAppId();
            UserAccount userAccount = userAccountManager.getUserAccountByApp(enterpriseUserId, wxUser.getBoxEnterpriseId(), appId);
            EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(dept.getBoxEnterpriseId(), appId);
            List<Long> deptList = departmentService.listDeptHierarchyOfDept(dept.getBoxDepartmentId());
            List<DepartmentAccount> deptAccountList = deptAccountService.listByAccountIdAndDeptId(enterpriseAccount.getAccountId(), deptList);

            for(DepartmentAccount deptAccount : deptAccountList) {
                addTeamSpaceMembers(dept.getBoxEnterpriseId(), appId, deptAccount.getCloudUserId(), String.valueOf(userAccount.getCloudUserId()));
            }

            //todo: 如果是leader，自动设置为审批人

            wxUser.setBoxEnterpriseUserId(enterpriseUserId);
            wxEnterpriseUserDao.create(wxUser);

            //更新用户头像
            if(StringUtils.isNotBlank(wxUser.getAvatar())) {
                userImageService.updateUserImage(enterpriseUserId, enterpriseAccount.getAccountId(), wxUser.getAvatar());
            }

            return user;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private void addTeamSpaceMembers(Long enterpriseId, String appId, Long teamId, String memberId) {
        try {
            RestTeamMemberCreateRequest request = new RestTeamMemberCreateRequest();
            request.setTeamRole("member");
            request.setRole("editor");
            RestTeamMember restTeamMember = new RestTeamMember();
            restTeamMember.setType("user");
            restTeamMember.setId(memberId);
            request.setMember(restTeamMember);

            teamSpaceService.addTeamSpaceMember(enterpriseId, appId, teamId , request);
        } catch (Exception e) {
            logger.error("自动增加部门空间[{}]成员[{}]失败：{}", teamId, memberId, e.getMessage());
            logger.debug("自动增加部门空间成员失败：", e);
        }
    }

    @Override
    public void update(WxEnterpriseUser wxUser) {
        EnterpriseUser user = toEnterpriseUser(wxUser);

        //设置对应的系统内企业ID
        WxEnterpriseUser dbWxUser = wxEnterpriseUserDao.get(wxUser.getCorpId(), wxUser.getUserId());
        user.setId(dbWxUser.getBoxEnterpriseUserId());

        String appId = authAppService.getDefaultWebApp().getAuthAppId();
        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(dbWxUser.getBoxEnterpriseId(), appId);

        if(!dbWxUser.getDepartmentId().equals(wxUser.getDepartmentId())) {
            try {
                //设置对应的系统内部门ID
                WxDepartment newDept = wxDepartmentDao.get(wxUser.getCorpId(), wxUser.getDepartmentId());
                user.setDepartmentId(newDept.getBoxDepartmentId());

                UserAccount userAccount = userAccountManager.getUserAccountByApp(dbWxUser.getBoxEnterpriseUserId(), dbWxUser.getBoxEnterpriseId(), appId);

/*
                //退出以前的部门空间
                WxDepartment oldDept = wxDepartmentDao.get(wxUser.getCorpId(), dbWxUser.getDepartmentId());
                DepartmentAccount oldDeptAccount = deptAccountService.getByDeptIdAndAccountId(oldDept.getBoxDepartmentId(), enterpriseAccount.getAccountId());
                teamSpaceService.deleteTeamSpaceMember(dbWxUser.getBoxEnterpriseId(), appId, oldDeptAccount.getCloudUserId(), userAccount.getCloudUserId());

                //加入新的部门空间
                DepartmentAccount newDeptAccount = deptAccountService.getByDeptIdAndAccountId(newDept.getBoxDepartmentId(), enterpriseAccount.getAccountId());
                addTeamSpaceMembers(dbWxUser.getBoxEnterpriseId(), appId, newDeptAccount.getCloudUserId(), String.valueOf(userAccount.getCloudUserId()));
*/

                //之前加入的部门空间
                List<RestTeamMemberInfo> spaceList = teamSpaceService.listUserTeamSpaces(dbWxUser.getBoxEnterpriseId(), appId, userAccount.getCloudUserId(), TeamSpace.TYPE_OFFICIAL);

                List<Long> deptList = departmentService.listDeptHierarchyOfDept(newDept.getBoxDepartmentId());
                List<DepartmentAccount> deptAccountList = deptAccountService.listByAccountIdAndDeptId(enterpriseAccount.getAccountId(), deptList);

                for(DepartmentAccount deptAccount : deptAccountList) {
                    Long teamId = take(spaceList, deptAccount.getCloudUserId());

                    //新增
                    if(teamId == null) {
                        addTeamSpaceMembers(dbWxUser.getBoxEnterpriseId(), appId, deptAccount.getCloudUserId(), String.valueOf(userAccount.getCloudUserId()));
                    }
                }

                for (RestTeamMemberInfo info : spaceList) {
                    teamSpaceService.deleteTeamSpaceMemberByCloudUserId(dbWxUser.getBoxEnterpriseId(), appId, info.getTeamId(), userAccount.getCloudUserId());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        //只更新部门信息
        EnterpriseUser dbUser = enterpriseUserService.get(user.getId(), user.getEnterpriseId());
        dbUser.setDepartmentId(user.getDepartmentId());
        enterpriseUserService.update(dbUser);

        //复制属性
        BeanUtils.copyProperties(wxUser, dbWxUser);
        dbWxUser.setDepartmentId(wxUser.getDepartmentId());
        wxEnterpriseUserDao.update(dbWxUser);

        //更新用户头像
        if(StringUtils.isNotBlank(wxUser.getAvatar())) {
            userImageService.updateUserImage(dbUser.getId(), enterpriseAccount.getAccountId(), wxUser.getAvatar());
        }
    }

    protected Long take(List<RestTeamMemberInfo> accountList, Long id) {
        for(int i = 0; i < accountList.size(); i++) {
            RestTeamMemberInfo item = accountList.get(i);
            if(item.getTeamId().equals(id)) {
                accountList.remove(i);
                return item.getTeamId();
            }
        }

        return null;
    }


    @Override
    public void delete(String corpId, String userId) {
        WxEnterpriseUser wxUser = wxEnterpriseUserDao.get(corpId, userId);
        if(wxUser != null) {
            //退出部门空间
            String appId = authAppService.getDefaultWebApp().getAuthAppId();
            UserAccount userAccount = userAccountManager.getUserAccountByApp(wxUser.getBoxEnterpriseUserId(), wxUser.getBoxEnterpriseId(), appId);
            EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(wxUser.getBoxEnterpriseId(), appId);
            WxDepartment dept = wxDepartmentDao.get(wxUser.getCorpId(), wxUser.getDepartmentId());
            List<Long> deptList = departmentService.listDeptHierarchyOfDept(dept.getBoxDepartmentId());
            List<DepartmentAccount> deptAccountList = deptAccountService.listByAccountIdAndDeptId(enterpriseAccount.getAccountId(), deptList);

            for(DepartmentAccount account : deptAccountList) {
                teamSpaceService.deleteTeamSpaceMemberByCloudUserId(wxUser.getBoxEnterpriseId(), appId, account.getCloudUserId(), userAccount.getCloudUserId());
            }

            //删除系统账号
            enterpriseUserManager.delete(wxUser.getBoxEnterpriseUserId(), wxUser.getBoxEnterpriseId());

            //删除微信用户信息
            wxEnterpriseUserDao.delete(wxUser);
        }
    }

    protected EnterpriseUser toEnterpriseUser(WxEnterpriseUser wxUser) {
        EnterpriseUser user = new EnterpriseUser();
        user.setEnterpriseId(wxUser.getBoxEnterpriseId());
        user.setName(wxUser.getUserId());
        user.setAlias(wxUser.getName());
        user.setMobile(wxUser.getMobile());
        user.setType(EnterpriseUser.TYPE_MEMBER);
        if(user.getMobile() == null && wxUser.getTelephone() != null) {
            user.setMobile(wxUser.getTelephone());
        }
        user.setEmail(wxUser.getEmail());
        user.setStatus(EnterpriseUser.STATUS_ENABLE);

        //生成默认密码
        user.setPassword(PasswordGenerateUtil.getRandomPassword(6));
        if(user.getObjectSid() == null) {
            user.setObjectSid(user.getName());
        }

        return user;
    }

    @Override
    public List<WxEnterpriseUser> getByCorpId(String corpId) {
        return wxEnterpriseUserDao.getByCorpId(corpId);
    }

    @Override
    public List<WxEnterpriseUser> getByEnterpriseIdAndUserId(long enterpriseId, long enterpriseUserId) {
        return wxEnterpriseUserDao.getByEnterpriseIdAndUserId(enterpriseId, enterpriseUserId);
    }
}
