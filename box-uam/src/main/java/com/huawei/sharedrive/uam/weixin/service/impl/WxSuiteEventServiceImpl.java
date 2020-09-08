package com.huawei.sharedrive.uam.weixin.service.impl;
/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */

import com.huawei.sharedrive.uam.weixin.service.task.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.huawei.sharedrive.uam.weixin.domain.WxDepartment;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.event.*;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxWorkOauth2SuiteProxy;
import com.huawei.sharedrive.uam.weixin.service.*;

import pw.cdmi.common.deamon.DeamonService;
import pw.cdmi.core.utils.SpringContextUtil;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>WeixinEventService实现类</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/26
 ************************************************************/

@Service
public class WxSuiteEventServiceImpl implements WxSuiteEventService {
    private static final Logger logger = LoggerFactory.getLogger(WxWorkOauth2SuiteServiceImpl.class);
    @Autowired
    WxEnterpriseService weixinEnterpriseService;

    @Autowired
    WxEnterpriseUserService weixinEnterpriseUserService;

    @Autowired
    WxDepartmentService weixinDepartmentService;

    @Autowired
    WxWorkOauth2SuiteProxy wxOauth2SuiteProxy;

    @Autowired
    DeamonService deamonService;

    @Override
    public void handle(WxSuiteEvent e) {
        if(e instanceof SuiteTicketEvent) {
            onSuiteTicket((SuiteTicketEvent)e);
        } else if(e instanceof SuiteCreateAuthEvent) {
            onSuiteCreateAuth((SuiteCreateAuthEvent) e);
        } else if(e instanceof SuiteChangeAuthEvent) {
            onSuiteChangeAuth((SuiteChangeAuthEvent) e);
        } else if(e instanceof SuiteCancelAuthEvent) {
            onSuiteCancelAuth((SuiteCancelAuthEvent) e);
        } else if(e instanceof SuiteCreateUserEvent) {
            onSuiteCreateUser((SuiteCreateUserEvent) e);
        } else if(e instanceof SuiteUpdateUserEvent) {
            onSuiteUpdateUser((SuiteUpdateUserEvent) e);
        } else if(e instanceof SuiteDeleteUserEvent) {
            onSuiteDeleteUser((SuiteDeleteUserEvent) e);
        } else if(e instanceof SuiteCreatePartyEvent) {
            onSuiteCreateParty((SuiteCreatePartyEvent) e);
        } else if(e instanceof SuiteUpdatePartyEvent) {
            onSuiteUpdateParty((SuiteUpdatePartyEvent) e);
        } else if(e instanceof SuiteDeletePartyEvent) {
            onSuiteDeleteParty((SuiteDeletePartyEvent) e);
        } else if(e instanceof SuiteUpdateTagEvent) {
            onSuiteUpdateTag((SuiteUpdateTagEvent) e);
        }
    }

    //缓存ticket
    void onSuiteTicket(SuiteTicketEvent e) {
        String ticket = e.getSuiteTicket();
        //此处不主动获取Suite Access Token，等需要使用时再获取
        wxOauth2SuiteProxy.setSuiteTicket(ticket);
    }

    //企业管理员对App进行授权
    void onSuiteCreateAuth(SuiteCreateAuthEvent e) {
        InitEnterpriseAccountTask task = SpringContextUtil.getBean(InitEnterpriseAccountTask.class);
        task.setSuiteId(e.getSuiteId());
        task.setAuthCode(e.getAuthCode());

        //开户操作放入后台执行
        deamonService.execute(task);
    }

    void onSuiteChangeAuth(SuiteChangeAuthEvent e) {
    }

    void onSuiteCancelAuth(SuiteCancelAuthEvent e) {
        String corpId = e.getAuthCorpId();

        //销户操作放入后台执行
        CloseEnterpriseAccountTask task = SpringContextUtil.getBean(CloseEnterpriseAccountTask.class);
        task.setCorpId(corpId);
        task.setSuiteId(e.getSuiteId());
        task.setEvent(e);

        deamonService.execute(task);
    }

    void onSuiteCreateUser(SuiteCreateUserEvent e) {
        SuiteCreateUserTask task = SpringContextUtil.getBean(SuiteCreateUserTask.class);
        task.setCorpId(e.getAuthCorpId());
        task.setSuiteId(e.getSuiteId());
        task.setEvent(e);

        deamonService.execute(task);
    }

    void onSuiteUpdateUser(SuiteUpdateUserEvent e) {
        SuiteUpdateUserTask task = SpringContextUtil.getBean(SuiteUpdateUserTask.class);
        task.setCorpId(e.getAuthCorpId());
        task.setSuiteId(e.getSuiteId());
        task.setEvent(e);

        deamonService.execute(task);
    }

    void onSuiteDeleteUser(SuiteDeleteUserEvent e) {
        SuiteDeleteUserTask task = SpringContextUtil.getBean(SuiteDeleteUserTask.class);
        task.setCorpId(e.getAuthCorpId());
        task.setSuiteId(e.getSuiteId());
        task.setEvent(e);

        deamonService.execute(task);
    }

    void onSuiteCreateParty(SuiteCreatePartyEvent e) {
        WxDepartment dept = WxDomainUtils.toWxDepartment(e);
        WxEnterprise wxEnterprise = weixinEnterpriseService.get(e.getAuthCorpId());
        dept.setBoxEnterpriseId(wxEnterprise.getBoxEnterpriseId());
        weixinDepartmentService.create(dept);
    }

    void onSuiteUpdateParty(SuiteUpdatePartyEvent e) {
        WxDepartment dept = WxDomainUtils.toWxDepartment(e);
        WxEnterprise wxEnterprise = weixinEnterpriseService.get(e.getAuthCorpId());
        dept.setBoxEnterpriseId(wxEnterprise.getBoxEnterpriseId());
        weixinDepartmentService.update(dept);
    }

    void onSuiteDeleteParty(SuiteDeletePartyEvent e) {
        weixinDepartmentService.delete(e.getAuthCorpId(), e.getId());
    }

    void onSuiteUpdateTag(SuiteUpdateTagEvent e) {
    }
}
