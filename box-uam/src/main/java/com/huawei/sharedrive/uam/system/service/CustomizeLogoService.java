package com.huawei.sharedrive.uam.system.service;

import pw.cdmi.common.domain.CustomizeLogo;

public interface CustomizeLogoService
{
    
    CustomizeLogo getCustomize();
    
    String getAppEmailTitle();
    
    /**
     * 
     * @param customize
     */
    void updateCustomize(CustomizeLogo customize);
}
