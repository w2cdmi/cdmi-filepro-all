package com.huawei.sharedrive.uam.enterprise.service;

import com.huawei.sharedrive.uam.enterprise.domain.AccountBasicConfig;

public interface AccountBasicConfigService
{
    void insert(AccountBasicConfig appBasicConfig);
    
    void update(AccountBasicConfig appBasicConfig);
    
    AccountBasicConfig get(AccountBasicConfig appBasicConfig);
    
    int getAccountIdNum(AccountBasicConfig appBasicConfig);
}
