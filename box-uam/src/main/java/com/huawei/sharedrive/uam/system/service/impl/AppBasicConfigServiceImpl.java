package com.huawei.sharedrive.uam.system.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.huawei.sharedrive.uam.system.dao.SystemConfigDAO;
import com.huawei.sharedrive.uam.system.service.AppBasicConfigService;

import pw.cdmi.common.config.service.ConfigManager;
import pw.cdmi.common.domain.AppBasicConfig;
import pw.cdmi.common.domain.SystemConfig;

@Component
public class AppBasicConfigServiceImpl implements AppBasicConfigService
{
    @Autowired
    private SystemConfigDAO systemConfigDAO;
    
    @Autowired
    private ConfigManager configManager;
    
    /*
     * (non-Javadoc)
     * 
     * @see
     * com.huawei.sharedrive.uam.system.service.AppBasicConfigService#getAppBasicConfig
     * (java.lang.String)
     */
    @Override
    public AppBasicConfig getAppBasicConfig(String appId)
    {
        List<SystemConfig> itemList = systemConfigDAO.getByPrefix(appId,
            null,
            AppBasicConfig.BASIC_CONFIG_PREFIX);
        return AppBasicConfig.buildAppBasicConfig(itemList);
    }
    
    /*
     * (non-Javadoc)
     * 
     * @see
     * com.huawei.sharedrive.uam.system.service.AppBasicConfigService#saveAppBasicConfig
     * (com.huawei.sharedrive.common.domain.AppBasicConfig)
     */
    @Override
    @Transactional(propagation = Propagation.REQUIRED)
    public void saveAppBasicConfig(AppBasicConfig appBasicConfig)
    {
        List<SystemConfig> itemList = appBasicConfig.toConfigItem();
        for (SystemConfig systemConfig : itemList)
        {
            if (systemConfigDAO.getByPriKey(appBasicConfig.getAppId(), systemConfig.getId()) == null)
            {
                systemConfigDAO.create(systemConfig);
            }
            else
            {
                systemConfigDAO.update(systemConfig);
            }
        }
        configManager.setConfig(AppBasicConfig.class.getSimpleName(), appBasicConfig);
    }
    
}