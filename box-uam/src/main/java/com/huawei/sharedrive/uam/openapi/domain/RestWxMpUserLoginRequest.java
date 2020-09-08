package com.huawei.sharedrive.uam.openapi.domain;

import java.io.Serializable;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;

import com.huawei.sharedrive.uam.exception.InvalidParamterException;

public class RestWxMpUserLoginRequest implements Serializable {
    private String code;

    private String appId;

    private Long enterpriseId;

    private String rawData;

    private String encryptedData;

    //
    private String iv;

    private String type;

    private String linkCode;

    private String chatGroupId;

    public void checkParameter(HttpServletRequest request) {
        if (StringUtils.isBlank(code)) {
            String msg = "code is null.";
            throw new InvalidParamterException(msg);
        }

        if (StringUtils.isBlank(appId)) {
            String msg = "appId is null.";
            throw new InvalidParamterException(msg);
        }
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public Long getEnterpriseId() {
        return enterpriseId;
    }

    public void setEnterpriseId(Long enterpriseId) {
        this.enterpriseId = enterpriseId;
    }

    public String getRawData() {
        return rawData;
    }

    public void setRawData(String rawData) {
        this.rawData = rawData;
    }

    public String getEncryptedData() {
        return encryptedData;
    }

    public void setEncryptedData(String encryptedData) {
        this.encryptedData = encryptedData;
    }

    public String getIv() {
        return iv;
    }

    public void setIv(String iv) {
        this.iv = iv;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getLinkCode() {
        return linkCode;
    }

    public void setLinkCode(String linkCode) {
        this.linkCode = linkCode;
    }

    public String getChatGroupId() {
        return chatGroupId;
    }

    public void setChatGroupId(String chatGroupId) {
        this.chatGroupId = chatGroupId;
    }
}
