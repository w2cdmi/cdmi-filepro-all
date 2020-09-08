/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import com.huawei.sharedrive.uam.authapp.service.AuthAppService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.manager.EnterpriseUserManager;
import com.huawei.sharedrive.uam.exception.ExistUserConflictException;
import com.huawei.sharedrive.uam.user.service.UserImageService;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.domain.WxUser;
import com.huawei.sharedrive.uam.weixin.domain.WxUserEnterprise;
import com.huawei.sharedrive.uam.weixin.service.WxUserEnterpriseService;
import com.huawei.sharedrive.uam.weixin.service.WxUserManager;
import com.huawei.sharedrive.uam.weixin.service.WxUserService;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;

import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>微信用户账户管理</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Service
public class WxUserManagerImpl implements WxUserManager {
    private static final Logger logger = LoggerFactory.getLogger(WxUserManagerImpl.class);

    @Autowired
    private WxUserService wxUserService;

    @Autowired
    private WxUserEnterpriseService wxUserEnterpriseService;

    @Autowired
    private EnterpriseUserManager enterpriseUserManager;

    @Autowired
    private EnterpriseAccountService enterpriseAccountService;

    @Autowired
    private AuthAppService authAppService;

    @Autowired
    private UserImageService userImageService;

    @Override
    public WxUserEnterprise openAccount(WxUser wxUser, long enterpriseId, String appId) {
        try {
            //首先保存微信用户信息
            WxUser dbWxUser = wxUserService.getByUnionId(wxUser.getUnionId());
            if(dbWxUser == null) {
                wxUserService.create(wxUser);
            } else {
                wxUserService.update(wxUser);
            }

            //1. 内部开户
            EnterpriseUser user = toEnterpriseUser(wxUser);
            user.setEnterpriseId(enterpriseId);
            //临时账户
            user.setType(EnterpriseUser.TYPE_TEMPORARY);
            //临时账户，部门为0
            long deptId = 0;
            user.setDepartmentId(deptId);
            long enterpriseUserId = enterpriseUserManager.createWeixin(user, false);

            //自动加入部门空间（暂不实现该功能）
/*
            UserAccount userAccount = userAccountManager.getUserAccountByApp(enterpriseUserId, enterpriseId, appId);
            //
            DepartmentAccount deptAccount = deptAccountService.getByDeptIdAndAccountId(deptId, enterpriseAccount.getAccountId());
            if(deptAccount != null) {
                addTeamSpaceMembers(enterpriseId, appId, deptAccount.getCloudUserId(), String.valueOf(userAccount.getCloudUserId()));
            }
*/

            //更新用户头像
            if(StringUtils.isNotBlank(wxUser.getAvatarUrl())) {
                EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(enterpriseId, appId);
                userImageService.updateUserImage(enterpriseUserId, enterpriseAccount.getAccountId(), wxUser.getAvatarUrl());
            }

            //3.保存微信用户与系统账户关系
            WxUserEnterprise wxUserEnterprise = new WxUserEnterprise();
            wxUserEnterprise.setUnionId(wxUser.getUnionId());
            wxUserEnterprise.setEnterpriseId(enterpriseId);
            wxUserEnterprise.setEnterpriseUserId(enterpriseUserId);
            wxUserEnterpriseService.create(wxUserEnterprise);

            return wxUserEnterprise;
        } catch (Exception e) {
//            e.printStackTrace();
            logger.error("Failed to open account when creating WxUser: ", e);
            return null;
        }
    }

    @Override
    public void deleteUser(String unionId) {
        try {
            List<WxUserEnterprise> userEnterpriseList = wxUserEnterpriseService.listByUnionId(unionId);

            for(WxUserEnterprise enterprise : userEnterpriseList) {
/*
                //退出部门空间
                String appId = authAppService.getDefaultWebApp().getAuthAppId();
                UserAccount userAccount = userAccountManager.getUserAccountByApp(enterprise.getEnterpriseUserId(), enterprise.getEnterpriseId(), appId);
                EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(enterprise.getEnterpriseId(), appId);

                //此处时微信用户在企业中的部门ID
                long deptId = 0;
                DepartmentAccount deptAccount = deptAccountService.getByDeptIdAndAccountId(deptId, enterpriseAccount.getAccountId());
                teamSpaceService.deleteTeamSpaceMember(enterprise.getEnterpriseId(), appId, deptAccount.getCloudUserId(), userAccount.getCloudUserId());
*/

                //删除系统账号
                enterpriseUserManager.delete(enterprise.getEnterpriseUserId(), enterprise.getEnterpriseId());
            }


            //删除微信用户开户信息
            wxUserEnterpriseService.deleteByUnionId(unionId);

            //删除微信用户
            wxUserService.delete(unionId);
        } catch (Exception e) {
//            e.printStackTrace();
            logger.error("Failed to delete account when delete WxUser: ", e);
        }
    }

    protected EnterpriseUser toEnterpriseUser(WxUser wxUser) {
        EnterpriseUser user = new EnterpriseUser();
        user.setName(wxUser.getUnionId());
        user.setAlias(wxUser.getNickName());
        user.setMobile(wxUser.getMobile());
        user.setMobile(wxUser.getMobile());
        user.setEmail(wxUser.getEmail());

        if(user.getObjectSid() == null) {
            user.setObjectSid(user.getName());
        }

/*
        String position;
        Integer gender;
        Integer isLeader;
        String avatar;
        String telephone;
        String englishName;
*/
        return user;
    }

    public void bindWxAccount(WxUser wxUser, long enterpriseId, long userId) {
        WxUser dbWxUser = wxUserService.getByUnionId(wxUser.getUnionId());

        if(dbWxUser != null) {
            wxUserService.update(wxUser);

            //保存用户头像
            if(StringUtils.isNotBlank(wxUser.getAvatarUrl()) && !wxUser.getAvatarUrl().equals(dbWxUser.getAvatarUrl())) {
                String appId = authAppService.getDefaultWebApp().getAuthAppId();
                EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(enterpriseId, appId);
                userImageService.updateUserImage(userId, enterpriseAccount.getAccountId(), wxUser.getAvatarUrl());
            }
        } else {
            wxUserService.create(wxUser);

            //保存用户头像
            if(StringUtils.isNotBlank(wxUser.getAvatarUrl())) {
                String appId = authAppService.getDefaultWebApp().getAuthAppId();
                EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(enterpriseId, appId);
                userImageService.updateUserImage(userId, enterpriseAccount.getAccountId(), wxUser.getAvatarUrl());
            }
        }
        
        WxUserEnterprise userEnterprise = new WxUserEnterprise();
        userEnterprise.setUnionId(wxUser.getUnionId());
        userEnterprise.setEnterpriseId(enterpriseId);
        userEnterprise.setEnterpriseUserId(userId);
        //创建微信用户与企业用户的关联
        WxUserEnterprise dbEnterpriseUser = wxUserEnterpriseService.getByUnionIdAndEnterpriseId(wxUser.getUnionId(), enterpriseId);
        //微信号绑定企业账号，账号如果已经绑定，则更新绑定信息
        if(dbEnterpriseUser != null) {
        	wxUserEnterpriseService.update(userEnterprise);
        }else{
        	wxUserEnterpriseService.create(userEnterprise);
        }
    }
}
