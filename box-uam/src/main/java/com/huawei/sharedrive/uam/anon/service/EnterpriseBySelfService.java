package com.huawei.sharedrive.uam.anon.service;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;

import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.openapi.domain.RestEnterpriseAccountRequest;

import pw.cdmi.common.domain.enterprise.Enterprise;

/**
 * Created by hepan on 2017/4/15.
 */
public interface EnterpriseBySelfService{

    void enterpriseRegister(Enterprise enterprise, RestEnterpriseAccountRequest enterpriseAccountRequest,String accountId, HttpServletRequest request) throws IOException;

    void enterpriseUserRegister(String domain, EnterpriseUser enterpriseUser, HttpServletRequest request) throws Exception;

	void createDefaultTeamSpace(long enterpriseId, String appId, int type, String name,String role);
}
