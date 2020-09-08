package com.huawei.sharedrive.uam.openapi.domain;

import java.io.Serializable;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;

import com.huawei.sharedrive.uam.exception.InvalidParamterException;
import com.huawei.sharedrive.uam.terminal.service.impl.TerminalServiceImpl;

public class RestWxworkUserLoginRequest implements Serializable {
    private String appId;

    private String corpId;

    private String code;

    private String authCode;

    public void checkParameter(HttpServletRequest request) {
        if (StringUtils.isBlank(appId)) {
            String msg = "invalidate appId:" + appId;
            throw new InvalidParamterException(msg);
        }

        TerminalServiceImpl.checkDeviceParamter(request);
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getCorpId() {
        return corpId;
    }

    public void setCorpId(String corpId) {
        this.corpId = corpId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getAuthCode() {
        return authCode;
    }

    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }
}
