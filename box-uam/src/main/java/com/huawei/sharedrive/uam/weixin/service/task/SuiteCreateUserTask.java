/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.domain.WxWorkCorpApp;
import com.huawei.sharedrive.uam.weixin.event.SuiteCreateUserEvent;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkCorpAppService;
import com.huawei.sharedrive.uam.weixin.service.WxWorkUserManager;
import com.huawei.sharedrive.uam.weixin.service.impl.WxDomainUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>企业管理员授权后，为企业开户，并初始化部门和用户数据</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Component
public class SuiteCreateUserTask extends SuiteTask {
    private static Logger logger = LoggerFactory.getLogger(SuiteCreateUserTask.class);

    @Autowired
    private WxEnterpriseService wxEnterpriseService;

    @Autowired
    private WxWorkUserManager wxWorkUserManager;

    @Autowired
    private WxWorkCorpAppService wxWorkCorpAppService;

    public SuiteCreateUserTask() {
    }

    @Override
    public void run() {
        SuiteCreateUserEvent suiteCreateUserEvent = (SuiteCreateUserEvent)event;
        try {
            WxEnterprise wxEnterprise = wxEnterpriseService.get(suiteCreateUserEvent.getAuthCorpId());
            WxEnterpriseUser user = WxDomainUtils.toWxEnterpriseUser(suiteCreateUserEvent);

            //暂不发送消息通知用户
            List<WxWorkCorpApp> appList = wxWorkCorpAppService.getByCorpIdAndSuiteId(user.getCorpId(), event.getSuiteId());
            wxWorkUserManager.openAccount(wxEnterprise.getName(), user, appList);
        } catch (Exception e) {
            logger.error("Failed to open account: corpId={}, userId={}", suiteCreateUserEvent.getAuthCorpId(), suiteCreateUserEvent.getUserID());
            logger.error("Failed to open account:", e);
//            e.printStackTrace();
        }
    }
}
