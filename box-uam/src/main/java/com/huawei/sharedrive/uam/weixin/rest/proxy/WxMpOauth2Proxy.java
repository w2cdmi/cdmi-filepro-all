package com.huawei.sharedrive.uam.weixin.rest.proxy;
/*
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-${year} 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-${year} www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */

import com.huawei.sharedrive.uam.weixin.rest.WxMpSessionKey;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.huawei.sharedrive.uam.core.web.JsonMapper;
import com.huawei.sharedrive.uam.util.HttpClientUtils;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description:
 * <pre>微信开放平台中，微信小程序，与微信平台相关的功能接口, 主要用于获取用户鉴权信息</pre>
 * @Project Alpha CDMI Service Platform, ${project_name} Component. ${date}
 ************************************************************/
@Component
public class WxMpOauth2Proxy {
    private static final Logger logger = LoggerFactory.getLogger(WxMpOauth2Proxy.class);

    //云盘小程序ID
    private String appId = "wx44a25d378f40e564";
    //云盘小程序secret
    private String appSecret = "00e77a26d6927cf9fbc5c0bcc5056934";

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getAppSecret() {
        return appSecret;
    }

    public void setAppSecret(String appSecret) {
        this.appSecret = appSecret;
    }

    /**
     * 使用登录凭证 code 获取登录微信用户的session_key 和 openid。
     * @param code 登录凭证码
     * @return session信息
     */
    public WxMpSessionKey getSessionKeyByCode(String code) {
        String json = HttpClientUtils.httpPostWithJsonBody("https://api.weixin.qq.com/sns/jscode2session?appid=" + appId + "&secret=" + appSecret + "&js_code=" + code + "&grant_type=authorization_code", null);

        return JsonMapper.nonEmptyCamelMapper().fromJson(json, WxMpSessionKey.class);
    }
}