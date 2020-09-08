/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.user.domain.MessageTemplate;
import com.huawei.sharedrive.uam.user.service.MessageTemplateService;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.domain.WxWorkCorpApp;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxWorkOauth2SuiteProxy;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseService;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseUserService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkUserManager;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pw.cdmi.common.cache.CacheClient;

import java.util.List;

/************************************************************
 * @Description:
 * <pre>企业信息用户账户管理</pre>
 * @author Rox
 * @version 3.0.1
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/11/25
 ************************************************************/
@Service
public class WxWorkUserManagerImpl implements WxWorkUserManager {
    private static Logger logger = LoggerFactory.getLogger(WxWorkUserManagerImpl.class);

    @Autowired
    private WxEnterpriseService wxEnterpriseService;

    @Autowired
    private WxEnterpriseUserService wxEnterpriseUserService;

    @Autowired
    WxWorkOauth2SuiteProxy wxOauth2SuiteProxy;

    @Autowired
    MessageTemplateService messageTemplateService;

    @Autowired
    CacheClient cacheClient;

    @Override
    public void openAccount(String enterpriseName, WxEnterpriseUser user, List<WxWorkCorpApp> appList) {
        WxEnterpriseUser dbWxUser = wxEnterpriseUserService.get(user.getCorpId(), user.getUserId());
        if(dbWxUser == null) {
            WxEnterprise wxEnterprise = wxEnterpriseService.get(user.getCorpId());
            user.setBoxEnterpriseId(wxEnterprise.getBoxEnterpriseId());

            EnterpriseUser enterpriseUser = wxEnterpriseUserService.create(user);

            //给用户发送消息
            if(enterpriseUser != null) {
                if(appList != null && !appList.isEmpty()) {
                    for(WxWorkCorpApp app : appList) {
                        sendUserMessage(app, enterpriseName, user.getUserId(), enterpriseUser);
                    }
                }
            }
        }
    }

    private void sendUserMessage(WxWorkCorpApp app, String enterpriseName, String userId, EnterpriseUser user) {
        //通过消息模板来构造消息
        String template = getMessageTemplate("createUser");
        if(StringUtils.isNotBlank(template)) {
            String message = template.replaceAll("(\\$\\{username})", user.getName());
            message = message.replaceAll("(\\$\\{password})", user.getPassword());
            message = message.replaceAll("(\\$\\{enterpriseName})", enterpriseName);

            wxOauth2SuiteProxy.sendTextMessage(app.getCorpId(), app.getAgentId(), userId, message);
        }
    }

    private String getMessageTemplate(String id) {
        String key = "MessageTemplate." + id;
        String content = (String)cacheClient.getCache(key);
        if(content == null) {
            MessageTemplate template = messageTemplateService.getById(id);
            if(template != null) {
                content = template.getContent();
                cacheClient.setCache(key, content, 60000);
            } else {
                content = "您好，您的文件宝账号已经开通：<br>企业名称：${enterpriseName}<br>用户名：${username}<br> 密码: ${password}<br>" +
                        "您可以在微信小程序中搜索“企业云盘”，进入小程序进行绑定。绑定后你可以访问<a href=\"http://www.jmapi.cn\">www.jmapi.cn</a>。通过微信扫描登陆管理您的知识文档，与同事进行工作协同。" +
                        "您也可以登陆<a href=\"http://www.jmapi.cn\">www.jmapi.cn</a>。首次登陆通过企业微信扫描登陆，然后在设置->用户信息中绑定您的微信号码。";
                logger.warn("No message template found in db: id={}", id);
            }
        }

        return content;
    }
}
