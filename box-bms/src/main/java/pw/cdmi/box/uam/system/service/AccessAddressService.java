package pw.cdmi.box.uam.system.service;

import pw.cdmi.common.domain.AccessAddressConfig;

public interface AccessAddressService
{
    
    AccessAddressConfig getAccessAddress();
    
    /**
     * 
     * @param accessAddressConfig
     */
    void saveAccessAddress(AccessAddressConfig accessAddressConfig);
    
}
