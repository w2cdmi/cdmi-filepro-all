package com.huawei.sharedrive.uam.enterprise.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.enterprise.dao.EnterpriseAccountDao;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;

import pw.cdmi.common.domain.enterprise.EnterpriseAccount;

@Service
public class EnterpriseAccountServiceImpl implements EnterpriseAccountService
{
    
    @Autowired
    private EnterpriseAccountDao enterpriseAccountDao;
    
    @Override
    public List<EnterpriseAccount> getByEnterpriseId(long enterpriseId)
    {
        
        return enterpriseAccountDao.getByEnterpriseId(enterpriseId);
    }
    
    @Override
    public int deleteByAccountId(long accountId)
    {
        
        return enterpriseAccountDao.deleteByAccountId(accountId);
    }
    
    @Override
    public void create(EnterpriseAccount enterpriseAccount)
    {
        
        enterpriseAccountDao.create(enterpriseAccount);
    }
    
    @Override
    public EnterpriseAccount getByEnterpriseApp(long enterpriseId, String authAppId)
    {
        return enterpriseAccountDao.getByEnterpriseApp(enterpriseId, authAppId);
    }
    
    @Override
    public List<String> getAppByEnterpriseId(long enterpriseId)
    {
        
        return enterpriseAccountDao.getAppByEnterpriseId(enterpriseId);
    }
    
    @Override
    public List<Long> getAccountIdByEnterpriseId(long enterpriseId)
    {
        
        return enterpriseAccountDao.getAccountIdByEnterpriseId(enterpriseId);
    }
    
    @Override
    public List<EnterpriseAccount> getAppContextByEnterpriseId(long enterpriseId)
    {
        
        return enterpriseAccountDao.getAppContextByEnterpriseId(enterpriseId);
    }
    
    @Override
    public EnterpriseAccount getByAccessKeyId(String accessKeyId)
    {
        return enterpriseAccountDao.getByAccessKeyId(accessKeyId);
    }
    @Override
    public EnterpriseAccount getByAccountId(long accountId)
    {
        return enterpriseAccountDao.getByAccountId(accountId);
    }
    //密码复杂度
	@Override
	public void setPwdLevelByEnterpriseId(long enterpriseId, int pwdLevel) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void modifyPwdLevelByEnterpriseId(long enterpriseId, int pwdLevel) {
		enterpriseAccountDao.modifyPwdLevelByEnterpriseId(enterpriseId, pwdLevel);
	}

	@Override
	public String getPwdLevelByEnterpriseId(long enterpriseId) {
		return enterpriseAccountDao.getPwdLevelByEnterpriseId(enterpriseId);
	}

	@Override
	public void update(EnterpriseAccount enterpriseAccount) {
		// TODO Auto-generated method stub
		enterpriseAccountDao.update(enterpriseAccount);
		
	}
}
