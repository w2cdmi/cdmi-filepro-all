/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.weixin.event.SuiteDeleteUserEvent;
import com.huawei.sharedrive.uam.weixin.service.WxEnterpriseUserService;
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
public class SuiteDeleteUserTask extends SuiteTask {
    private static Logger logger = LoggerFactory.getLogger(SuiteDeleteUserTask.class);

    @Autowired
    private WxEnterpriseUserService wxEnterpriseUserService;

    public SuiteDeleteUserTask() {
    }

    @Override
    public void run() {
        SuiteDeleteUserEvent deleteEvent = (SuiteDeleteUserEvent)event;

        try {
            wxEnterpriseUserService.delete(deleteEvent.getAuthCorpId(), deleteEvent.getUserID());
        } catch (Exception e) {
            logger.error("Failed to delete WxWork user: corpId={}, userId={}", deleteEvent.getAuthCorpId(), deleteEvent.getUserID());
            logger.error("Failed to delete WxWork user:", e);
//            e.printStackTrace();
        }
    }
}
