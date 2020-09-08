package com.huawei.sharedrive.uam.enterprise.service.impl;

import javax.annotation.PostConstruct;

import org.apache.curator.framework.CuratorFramework;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.huawei.sharedrive.uam.enterprise.dao.NetworkRegionIpExcelImportDao;
import com.huawei.sharedrive.uam.enterprise.service.NetworkRegionIpExcelGenerateService;
import com.huawei.sharedrive.uam.idgenerate.util.IdGenerateUtil;

import pw.cdmi.core.utils.SeedInitializer;
import pw.cdmi.core.utils.SequenceGenerator;
import pw.cdmi.core.zk.ZookeeperServer;

@Component
public class NetworkRegionIpExcelGenerateGenerateServiceImpl implements SeedInitializer,
    NetworkRegionIpExcelGenerateService
{
    private CuratorFramework client;
    
    private SequenceGenerator sequenceGenerator;
    
    @Value("${zk.root.path}")
    private String rootPath;
    
    @Autowired
    private NetworkRegionIpExcelImportDao excelImportDao;
    
    @Autowired
    private ZookeeperServer zookeeperServer;
    
    @Override
    public long getNextId()
    {
        return sequenceGenerator.getSequence(IdGenerateUtil.NET_REGION_IP_EXCEL_SUB_PATH);
    }
    
    @Override
    public long getSeed(String subPath)
    {
        return excelImportDao.getMaxId();
    }
    
    @PostConstruct
    public void init() throws Exception
    {
        client = zookeeperServer.getClient();
        sequenceGenerator = new SequenceGenerator(client, this, rootPath
            + IdGenerateUtil.NET_REGION_IP_EXCEL_SUB_PATH);
    }
    
}
