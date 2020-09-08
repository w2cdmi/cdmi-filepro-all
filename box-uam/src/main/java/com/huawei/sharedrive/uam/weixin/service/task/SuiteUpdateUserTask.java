/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.event.SuiteUpdateUserEvent;
import com.huawei.sharedrive.uam.weixin.rest.User;
import com.huawei.sharedrive.uam.weixin.rest.proxy.WxWorkOauth2SuiteProxy;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseService;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseUserService;
import com.huawei.sharedrive.uam.weixin.service.impl.WxDomainUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>企业管理员授权后，为企业开户，并初始化部门和用户数据</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Component
public class SuiteUpdateUserTask extends SuiteTask {
    private static Logger logger = LoggerFactory.getLogger(SuiteUpdateUserTask.class);

    @Autowired
    private WxWorkOauth2SuiteProxy wxWorkOauth2SuiteProxy;

    @Autowired
    private WxEnterpriseService wxEnterpriseService;

    @Autowired
    private WxEnterpriseUserService wxEnterpriseUserService;

    public SuiteUpdateUserTask() {
    }

    @Override
    public void run() {
        SuiteUpdateUserEvent updateEvent = (SuiteUpdateUserEvent)event;
        try {
            //Update事件中只传递了修改过的字段，为了简便起见，重新获取用户信息，进行更新。
            User userInfo = wxWorkOauth2SuiteProxy.getUserInfo(corpId, updateEvent.getUserID());
            if(userInfo == null) {
                logger.error("Failed to query user info: corpId={}, userId={}", corpId, updateEvent.getUserID());
                return;
            }

            if(userInfo.hasError()) {
                logger.error("Failed to query user info: corpId={}, userId={}, code={}, msg={}", corpId, updateEvent.getUserID(), userInfo.getErrcode(), userInfo.getErrmsg());
                return;
            }

            WxEnterpriseUser user = WxDomainUtils.toWxEnterpriseUser(userInfo);
            user.setCorpId(updateEvent.getAuthCorpId());
            WxEnterprise wxEnterprise = wxEnterpriseService.get(updateEvent.getAuthCorpId());
            user.setBoxEnterpriseId(wxEnterprise.getBoxEnterpriseId());
            wxEnterpriseUserService.update(user);
        } catch (Exception e) {
            logger.error("Failed to open account: corpId={}, userId={}", updateEvent.getAuthCorpId(), updateEvent.getUserID());
            logger.error("Failed to open account:", e);
//            e.printStackTrace();
        }
    }
}
