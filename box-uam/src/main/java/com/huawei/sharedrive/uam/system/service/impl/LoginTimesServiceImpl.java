package com.huawei.sharedrive.uam.system.service.impl;

import java.util.List;

import org.apache.commons.collections.CollectionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.huawei.sharedrive.uam.system.dao.SystemConfigDAO;
import com.huawei.sharedrive.uam.system.service.LoginTimesService;
import com.huawei.sharedrive.uam.util.Constants;

import pw.cdmi.common.config.service.ConfigListener;
import pw.cdmi.common.config.service.ConfigManager;
import pw.cdmi.common.domain.SystemConfig;
import pw.cdmi.common.domain.SystemLoginTimesConfig;
import pw.cdmi.common.domain.UserLoginTimesConfig;

@Component
public class LoginTimesServiceImpl implements LoginTimesService, ConfigListener
{
    private static final Logger LOGGER = LoggerFactory.getLogger(LoginTimesServiceImpl.class);
    
    private SystemLoginTimesConfig systemLocalCache;
    
    private UserLoginTimesConfig userLocalCache;
    
    @Autowired
    private SystemConfigDAO systemConfigDAO;
    
    @Autowired
    private ConfigManager configManager;
    
    @Override
    public SystemLoginTimesConfig getSystemLoginTimesConfig()
    {
        if (systemLocalCache == null)
        {
            List<SystemConfig> itemList = systemConfigDAO.getByPrefix(Constants.UAM_DEFAULT_APP_ID,
                null,
                SystemLoginTimesConfig.LOGINTIMES_SYSTEM_PREFIX);
            if (CollectionUtils.isNotEmpty(itemList))
            {
                systemLocalCache = SystemLoginTimesConfig.buildSystemLoginTimesConfig(itemList);
            }
        }
        return systemLocalCache;
    }
    
    @Override
    @Transactional(propagation = Propagation.REQUIRED)
    public void saveSystemLoginTimesConfig(SystemLoginTimesConfig systemLoginTimesConfig)
    {
        systemLoginTimesConfig.setAppId(Constants.UAM_DEFAULT_APP_ID);
        List<SystemConfig> itemList = systemLoginTimesConfig.toConfigItem();
        for (SystemConfig systemConfig : itemList)
        {
            if (systemConfigDAO.getByPriKey(Constants.UAM_DEFAULT_APP_ID, systemConfig.getId()) == null)
            {
                systemConfigDAO.create(systemConfig);
            }
            else
            {
                systemConfigDAO.update(systemConfig);
            }
        }
        systemLocalCache = systemLoginTimesConfig;
        configManager.setConfig(SystemLoginTimesConfig.class.getSimpleName(), systemLoginTimesConfig);
    }
    
    @Override
    public void configChanged(String key, Object value)
    {
        if (key.equals(SystemLoginTimesConfig.class.getSimpleName()))
        {
            LOGGER.info("Change SystemLoginTimesConfig By Cluseter Notify.");
            systemLocalCache = (SystemLoginTimesConfig) value;
        }
        else if (key.equals(UserLoginTimesConfig.class.getSimpleName()))
        {
            LOGGER.info("Change UserLoginTimesConfig By Cluseter Notify.");
            userLocalCache = (UserLoginTimesConfig) value;
        }
    }
    
    @Override
    public UserLoginTimesConfig getUserLoginTimesConfig()
    {
        if (userLocalCache == null)
        {
            List<SystemConfig> itemList = systemConfigDAO.getByPrefix(Constants.UAM_DEFAULT_APP_ID,
                null,
                UserLoginTimesConfig.LOGINTIMES_USER_PREFIX);
            if (CollectionUtils.isNotEmpty(itemList))
            {
                userLocalCache = UserLoginTimesConfig.buildUserLoginTimesConfig(itemList);
            }
        }
        return userLocalCache;
    }
    
    @Override
    public void saveUserLoginTimesConfig(UserLoginTimesConfig userLoginTimesConfig)
    {
        userLoginTimesConfig.setAppId(Constants.UAM_DEFAULT_APP_ID);
        List<SystemConfig> itemList = userLoginTimesConfig.toConfigItem();
        for (SystemConfig systemConfig : itemList)
        {
            if (systemConfigDAO.getByPriKey(Constants.UAM_DEFAULT_APP_ID, systemConfig.getId()) == null)
            {
                systemConfigDAO.create(systemConfig);
            }
            else
            {
                systemConfigDAO.update(systemConfig);
            }
        }
        userLocalCache = userLoginTimesConfig;
        configManager.setConfig(UserLoginTimesConfig.class.getSimpleName(), userLoginTimesConfig);
    }
}