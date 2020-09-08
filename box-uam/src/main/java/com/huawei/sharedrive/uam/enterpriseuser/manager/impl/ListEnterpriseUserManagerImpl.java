package com.huawei.sharedrive.uam.enterpriseuser.manager.impl;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.manager.UserAccountManager;
import com.huawei.sharedrive.uam.enterprise.manager.EnterpriseAccountManager;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUserExtend;
import com.huawei.sharedrive.uam.enterpriseuser.manager.EnterpriseUserManager;
import com.huawei.sharedrive.uam.enterpriseuser.manager.LdapUserManager;
import com.huawei.sharedrive.uam.enterpriseuser.manager.ListEnterpriseUserManager;
import com.huawei.sharedrive.uam.exception.BusinessException;

import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageImpl;
import pw.cdmi.box.domain.PageRequest;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;
import pw.cdmi.core.utils.SqlUtils;

@Component
public class ListEnterpriseUserManagerImpl implements ListEnterpriseUserManager
{
    @Autowired
    private LdapUserManager ldapUserManager;
    
    @Autowired
    private EnterpriseUserManager enterpriseUserManager;
    
    @Autowired
    private UserAccountManager userAccountManager;
    
    @Autowired
    private EnterpriseAccountManager enterpriseAccountManager;
    
    @SuppressWarnings("PMD.ExcessiveParameterList")
    @Override
    public Page<EnterpriseUserExtend> getPagedEnterpriseUser(String sessionId, String dn, Long authServerId,String deptId,
        Long enterpriseId, String filter, PageRequest pageRequest)
    {
        Page<EnterpriseUser> page = null;
        if (StringUtils.isNotBlank(dn))
        {
            ldapUserManager.insertLdapUser(sessionId, dn, authServerId);
            page = ldapUserManager.getPagedUserExtend(sessionId,
                dn,
                authServerId,
                enterpriseId,
                SqlUtils.stringToSqlLikeFields(filter),
                pageRequest);
        }
        else
        {
            page = enterpriseUserManager.getPagedEnterpriseUser(SqlUtils.stringToSqlLikeFields(filter),
                authServerId,
                deptId,
                enterpriseId,
                pageRequest);
        }
        List<EnterpriseUser> list = page.getContent();
        List<EnterpriseAccount> enterpriseAccountList = enterpriseAccountManager.getByEnterpriseId(enterpriseId);
        List<EnterpriseUserExtend> enterpriseUserExtendList = new ArrayList<EnterpriseUserExtend>(10);
        EnterpriseUserExtend enterpriseUserExtend;
        for (EnterpriseUser enterpriseUser : list)
        {
            enterpriseUserExtend = bulidEnterpriseUserExtend(enterpriseUser, enterpriseAccountList);
            enterpriseUserExtendList.add(enterpriseUserExtend);
        }
        Page<EnterpriseUserExtend> enterpriseUserExtendPage = new PageImpl<EnterpriseUserExtend>(
            enterpriseUserExtendList, pageRequest, page.getTotalElements());
        return enterpriseUserExtendPage;
    }
    
    private EnterpriseUserExtend bulidEnterpriseUserExtend(EnterpriseUser enterpriseUser,
        List<EnterpriseAccount> enterpriseAccounts)
    {
        EnterpriseUserExtend enterpriseUserExtend = EnterpriseUserExtend.copyEnterpriseUserPro(enterpriseUser);
        List<String> authAppIdList = enterpriseUserExtend.getAuthAppIdList();
        String authAppId;
        for (EnterpriseAccount enterpriseAccount : enterpriseAccounts)
        {
            authAppId = enterpriseAccount.getAuthAppId();
            try
            {
                UserAccount userAccount = userAccountManager.getUserAccountByApp(enterpriseUser.getId(),
                    enterpriseUser.getEnterpriseId(),
                    authAppId);
                if (null != userAccount)
                {
                	enterpriseUserExtend.setCloudUserId(userAccount.getCloudUserId());
                    authAppIdList.add(authAppId);
                }
            }
            catch (BusinessException e)
            {
                continue;
            }
        }
        return enterpriseUserExtend;
    }

	@Override
	public Page<EnterpriseUserExtend> getPagedEnterpriseUser(String sessionId, String dn, Long authServerId,
			String deptId, long enterpriseId, String filter, PageRequest pageRequest, long type) {
        Page<EnterpriseUser> page = null;
        if (StringUtils.isNotBlank(dn))
        {
            ldapUserManager.insertLdapUser(sessionId, dn, authServerId);
            page = ldapUserManager.getPagedUserExtend(sessionId,
                dn,
                authServerId,
                enterpriseId,
                SqlUtils.stringToSqlLikeFields(filter),
                pageRequest);
        }
        else
        {
            page = enterpriseUserManager.getPagedEnterpriseUser(SqlUtils.stringToSqlLikeFields(filter),
                authServerId,
                deptId,
                enterpriseId,
                pageRequest,
                type);
        }
        List<EnterpriseUser> list = page.getContent();
        List<EnterpriseAccount> enterpriseAccountList = enterpriseAccountManager.getByEnterpriseId(enterpriseId);
        List<EnterpriseUserExtend> enterpriseUserExtendList = new ArrayList<EnterpriseUserExtend>(10);
        EnterpriseUserExtend enterpriseUserExtend;
        for (EnterpriseUser enterpriseUser : list)
        {
            enterpriseUserExtend = bulidEnterpriseUserExtend(enterpriseUser, enterpriseAccountList);
            enterpriseUserExtendList.add(enterpriseUserExtend);
        }
        Page<EnterpriseUserExtend> enterpriseUserExtendPage = new PageImpl<EnterpriseUserExtend>(
            enterpriseUserExtendList, pageRequest, page.getTotalElements());
        return enterpriseUserExtendPage;
    }
}
