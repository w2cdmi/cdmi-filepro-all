package com.huawei.sharedrive.uam.user.dao.impl;

import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.user.dao.ManagerLockedDao;

import pw.cdmi.box.dao.impl.AbstractDAOImpl;
import pw.cdmi.common.domain.ManagerLocked;

@SuppressWarnings("deprecation")
@Service("ManagerLockedDao")
public class ManagerLockedDaoImpl extends AbstractDAOImpl implements ManagerLockedDao
{
    
    @Override
    public ManagerLocked get(String loginName)
    {
        
        Object obj = sqlMapClientTemplate.queryForObject("ManagerLocked.getForUpdate", loginName);
        if (null == obj)
        {
            return null;
        }
        else
        {
            return (ManagerLocked) obj;
        }
    }
    
    @Override
    public void insert(ManagerLocked managerLocked)
    {
        sqlMapClientTemplate.insert("ManagerLocked.insert", managerLocked);
    }
    
    @Override
    public void addFailTime(ManagerLocked managerLocked)
    {
        sqlMapClientTemplate.update("ManagerLocked.updateFailTime", managerLocked);
    }
    
    @Override
    public void delete(String loginName)
    {
        
        sqlMapClientTemplate.delete("ManagerLocked.delete", loginName);
        
    }
    
    @Override
    public void lock(ManagerLocked managerLocked)
    {
        // TODO Auto-generated method stub
        sqlMapClientTemplate.update("ManagerLocked.lock", managerLocked);
    }
    
}
