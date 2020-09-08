/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import java.io.IOException;
import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.anon.service.EnterpriseBySelfService;
import com.huawei.sharedrive.uam.openapi.domain.RestEnterpriseAccountRequest;
import com.huawei.sharedrive.uam.weixin.dao.WxEnterpriseDao;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseService;

import pw.cdmi.common.domain.enterprise.Enterprise;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>微信企业Service</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Service
public class WxEnterpriseServiceImpl implements WxEnterpriseService {
    private static Logger logger = LoggerFactory.getLogger(WxEnterpriseService.class);

    @Autowired
    WxEnterpriseDao wxEnterpriseDao;

    @Autowired
    private EnterpriseBySelfService enterpriseBySelfService;

    @Override
    public void create(WxEnterprise wxEnterprise) {
        try {
            //首先保存公司信息
            wxEnterprise.setState(WxEnterprise.STATE_INITIAL); //设置为初始状态
            wxEnterpriseDao.create(wxEnterprise);

            //企业账号开户
            Enterprise enterprise = registerEnterprise(wxEnterprise);

            //开户成功，设置内部的
            wxEnterprise.setState(WxEnterprise.STATE_NORMAL); //设置为完成
            wxEnterprise.setBoxEnterpriseId(enterprise.getId());
            wxEnterpriseDao.update(wxEnterprise);
        } catch (Exception e) {
            logger.error("Failed to register enterprise=" + wxEnterprise.getId() + ": ", e);
//            e.printStackTrace();
//            throw new RuntimeException(e);
        }
    }

    protected Enterprise registerEnterprise(WxEnterprise wxEnterprise) throws IOException {
        //使用原有自注册流程
        Enterprise enterprise = new Enterprise();
        enterprise.setContactEmail(wxEnterprise.getEmail());
        enterprise.setContactPerson(wxEnterprise.getUserId());
        enterprise.setContactPhone(wxEnterprise.getMobile());
        enterprise.setDomainName(wxEnterprise.getId());
        enterprise.setName(wxEnterprise.getName());
        enterprise.setIsdepartment(true);
        enterprise.setPwdLevel("3");//默认初级限制，只要求不少于6位

        RestEnterpriseAccountRequest enterpriseAccountRequest = new RestEnterpriseAccountRequest();
        enterpriseAccountRequest.setMaxMember(30);//默认100人
        enterpriseAccountRequest.setMaxSpace(20 *1024);//默认20G, 单位为M
        enterpriseAccountRequest.setMaxTeamspace(100);//默认100个团队空间

        //注册时，会为企业生成一个对应的enterpriseUser, 其name使用account赋值
        String accountId = getAccountId(wxEnterprise);

        //原有的流程中使用了HttpServletRequest参数（获取IP和Locale）, 为了使用既有流程此处构造一个Request。
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("x-forwarded-for", "qyapi.weixin.qq.com");
        request.addPreferredLocale(Locale.SIMPLIFIED_CHINESE);

        enterpriseBySelfService.enterpriseRegister(enterprise, enterpriseAccountRequest, accountId, request);
        return enterprise;
    }

    @Override
    public void update(WxEnterprise wxEnterprise) {
        try {
            //针对异常情况：上次安装时，企业账户开户失败，再次安装时重新开户
            if(wxEnterprise.getBoxEnterpriseId() == null) {
                //企业账号开户
                Enterprise enterprise = registerEnterprise(wxEnterprise);

                //开户成功，设置内部的
                wxEnterprise.setState(WxEnterprise.STATE_NORMAL); //设置为完成
                wxEnterprise.setBoxEnterpriseId(enterprise.getId());
            }

            wxEnterpriseDao.update(wxEnterprise);
        } catch (Exception e) {
            logger.error("Failed to update enterprise=" + wxEnterprise.getId() + ": ", e);
        }
    }

    @Override
    public void updateState(String corpId, Byte state) {
        wxEnterpriseDao.updateState(corpId, state);
    }

    @Override
    public WxEnterprise get(String corpId) {
        return wxEnterpriseDao.get(corpId);
    }

    protected String getAccountId(WxEnterprise wxEnterprise) {
/*
        if(wxEnterprise.getEmail() != null) {
            return wxEnterprise.getEmail();
        }

        if(wxEnterprise.getMobile() != null) {
            return wxEnterprise.getMobile();
        }

        if(wxEnterprise.getUserId() != null) {
            return wxEnterprise.getUserId();
        }
*/

        //如果以上所有的信息都为空，使用企业的ID作为账号。
        return wxEnterprise.getId();
    }
}
