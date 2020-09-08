/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxWorkCorpApp;
import com.huawei.sharedrive.uam.weixin.rest.Agent;
import com.huawei.sharedrive.uam.weixin.rest.PermanentCodeInfo;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxWorkOauth2SuiteProxy;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkCorpAppService;
import com.huawei.sharedrive.uam.weixin.service.impl.WxDomainUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import pw.cdmi.core.utils.SpringContextUtil;

import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>企业管理员授权后，为企业开户，并初始化部门和用户数据</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Component
public class InitEnterpriseAccountTask extends SuiteTask {
    private static Logger logger = LoggerFactory.getLogger(InitEnterpriseAccountTask.class);

    @Autowired
    private WxEnterpriseService wxEnterpriseService;

    @Autowired
    WxWorkOauth2SuiteProxy wxOauth2SuiteProxy;

    @Autowired
    WxWorkCorpAppService wxWorkCorpAppService;

    private String authCode;

    public InitEnterpriseAccountTask() {
    }

    public String getAuthCode() {
        return authCode;
    }

    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    @Override
    public void run() {
        String suiteToken = wxOauth2SuiteProxy.getSuiteToken();
        if(suiteToken == null) {
            logger.error("Can't get suite token, auth code: " + authCode);
            return;
        }

        //获取永久授权码
        PermanentCodeInfo codeInfo = wxOauth2SuiteProxy.getPermanentCode(suiteToken, authCode);
        if(codeInfo.getErrcode() != null && codeInfo.getErrcode() != 0) {
            logger.error("Can't get permanent code of corporation, auth code={}, errcode={}, errmsg={}", authCode, codeInfo.getErrcode(), codeInfo.getErrmsg());
            return;
        }

        //永久授权码放入缓存, 同时更新access token
        String corpId = codeInfo.getAuthCorpInfo().getCorpid();
        //只有通过永久授权码才能查询到企业ID
        setCorpId(corpId);
        wxOauth2SuiteProxy.setCorpPermanentCode(corpId, codeInfo.getPermanentCode());
        wxOauth2SuiteProxy.setCorpToken(corpId, codeInfo.getAccessToken(), codeInfo.getExpiresIn());

        //保存企业安装的应用信息
        List<Agent> agentList = codeInfo.getAuthInfo().getAgent();
        for(Agent agent : agentList) {
            WxWorkCorpApp corpApp = new WxWorkCorpApp();
            corpApp.setCorpId(corpId);
            corpApp.setSuiteId(suiteId);
            corpApp.setAppId(agent.getAppid());
            corpApp.setAgentId(agent.getAgentid());
            corpApp.setName(agent.getName());
            corpApp.setRoundLogoUrl(agent.getRoundLogoUrl());
            corpApp.setSquareLogoUrl(agent.getSquareLogoUrl());

            WxWorkCorpApp dbOne = wxWorkCorpAppService.getByCorpIdAndAgentId(corpId, agent.getAgentid());
            if(dbOne != null) {
                wxWorkCorpAppService.create(corpApp);
            }
        }

        //保存企业信息
        WxEnterprise enterprise = WxDomainUtils.toWxEnterprise(codeInfo);
        WxEnterprise dbEnterprise = wxEnterpriseService.get(enterprise.getId());
        if(dbEnterprise == null) {
            createEnterpriseAccount(enterprise);
        } else {
            enterprise.setBoxEnterpriseId(dbEnterprise.getBoxEnterpriseId());
            updateEnterpriseAccount(enterprise);
        }
    }

    private void createEnterpriseAccount(WxEnterprise enterprise) {
        try {
            wxEnterpriseService.create(enterprise);

            //执行初始化通信录任务
            SyncAddressListTask task = SpringContextUtil.getBean(SyncAddressListTask.class);
            task.setCorpId(corpId);
            task.setSuiteId(suiteId);
            task.setEnterprise(enterprise);

            task.run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void updateEnterpriseAccount(WxEnterprise enterprise) {
        try {
            enterprise.setState(WxEnterprise.STATE_INITIAL); //设置为初始状态
            wxEnterpriseService.update(enterprise);

            //执行同步通信录任务
            SyncAddressListTask task = SpringContextUtil.getBean(SyncAddressListTask.class);
            task.setCorpId(corpId);
            task.setSuiteId(suiteId);
            task.setEnterprise(enterprise);

            task.run();

            //将企业状态改为正常
            enterprise.setState(WxEnterprise.STATE_NORMAL);
            wxEnterpriseService.update(enterprise);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
