package com.huawei.sharedrive.uam.accountuser.dao;

import java.util.List;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;

import pw.cdmi.box.domain.Limit;

public interface UserAccountDao
{
    long getMaxUserId();
    
    void create(UserAccount userAccount);
    
    void update(UserAccount userAccount);
    
    UserAccount get(long userId, long accountId);
    
    void delByUserAccountId(UserAccount userAccount);
    
    UserAccount getBycloudUserAccountId(UserAccount userAccount);
    
    UserAccount getById(long id, long accountId);

    UserAccount getByImAccount(String imAccount, long accountId);

    int getFilterdCount(long accountId, long enterpriseId, long userSource, String filter, Integer status);
    
    List<UserAccount> getFilterd(UserAccount userAccount, long userSource, Limit limit,
        String filter);
    
    void updateStatus(UserAccount userAccount, String ids);
    
    void updateRole(UserAccount userAccount, String ids);
    
    void updateLoginTime(UserAccount userAccount);
    
    void updateFirstLogin(UserAccount userAccount);
    
    void updateUserIdById(UserAccount userAccount);
}
