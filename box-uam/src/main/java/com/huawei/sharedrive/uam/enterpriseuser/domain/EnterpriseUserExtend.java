package com.huawei.sharedrive.uam.enterpriseuser.domain;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.BeanUtils;
import org.springframework.web.util.HtmlUtils;

public class EnterpriseUserExtend extends EnterpriseUser
{
    
    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    
    private List<String> authAppIdList = new ArrayList<String>(10);
    
    public static void htmlEscape(List<EnterpriseUserExtend> list)
    {
        if (null == list)
        {
            return;
        }
        List<String> appList;
        for (EnterpriseUserExtend iter : list)
        {
            iter.setPassword(null);
            iter.setSalt(null);
            iter.setResetPasswordAt(null);
            iter.setAlias(HtmlUtils.htmlEscape(iter.getAlias()).replaceAll(" ", "&nbsp;"));
            iter.setDescription(HtmlUtils.htmlEscape(iter.getDescription()));
            iter.setEmail(HtmlUtils.htmlEscape(iter.getEmail()));
            iter.setMobile(HtmlUtils.htmlEscape(iter.getMobile()));
            iter.setName(HtmlUtils.htmlEscape(iter.getName()).replaceAll(" ", "&nbsp;"));
            iter.setObjectSid(HtmlUtils.htmlEscape(iter.getObjectSid()));
            
            appList = iter.getAuthAppIdList();
            if (null != appList)
            {
                for (int i = 0; i < appList.size(); i++)
                {
                    appList.set(i, HtmlUtils.htmlEscape(appList.get(i)));
                }
            }
        }
    }
    
    public List<String> getAuthAppIdList()
    {
        return authAppIdList;
    }
    
    public void setAuthAppIdList(List<String> authAppIdList)
    {
        this.authAppIdList = authAppIdList;
    }
    
    public static EnterpriseUser copyEnterpriseUserExtendPro(EnterpriseUserExtend enterpriseUserExtend)
    {
        EnterpriseUser enterpriseUser = new EnterpriseUser();
        BeanUtils.copyProperties(enterpriseUserExtend, enterpriseUser);
        return enterpriseUser;
    }
    
    public static EnterpriseUserExtend copyEnterpriseUserPro(EnterpriseUser enterpriseUser)
    {
        EnterpriseUserExtend enterpriseUserExtend = new EnterpriseUserExtend();
        BeanUtils.copyProperties(enterpriseUser, enterpriseUserExtend);
        return enterpriseUserExtend;
    }
}
