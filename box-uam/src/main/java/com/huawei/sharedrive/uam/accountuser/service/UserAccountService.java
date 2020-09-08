package com.huawei.sharedrive.uam.accountuser.service;

import java.util.List;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;

import pw.cdmi.box.domain.Limit;
import pw.cdmi.common.domain.AppBasicConfig;

public interface UserAccountService
{
    /**
     * create user account
     * 
     * @param userAccount
     * @return
     */
    void create(UserAccount userAccount);
    
    void update(UserAccount userAccount);
    
    UserAccount get(long userId, long accountId);
    
    void delByUserAccountId(UserAccount userAccount);
    
    UserAccount getById(long id, long accountId);
    
    UserAccount getByImAccount(String imAccount, long accountId);

    void bulidUserAccount(UserAccount userAccount, AppBasicConfig appBasicConfig);
    
    void bulidUserAccountParam(UserAccount userAccount, AppBasicConfig appBasicConfig);
    
    int getFilterdCount(long accountId, long enterpriseId, long userSource, String filter, Integer status);
    
    List<UserAccount> getFilterd(UserAccount userAccount, long userSource, Limit limit, String filter);
    
    void updateStatus(UserAccount userAccount, String ids);
    
    void updateRole(UserAccount userAccount, String ids);
    
    void updateLoginTime(UserAccount userAccount);
    
    UserAccount getBycloudUserAccountId(UserAccount userAccount);
    
    boolean isLocalAndFirstLogin(long accountId, long userId);
    
    void setNoneFirstLogin(long accountId, long userId);
    
    void updateUserIdById(UserAccount userAccount);
}
