/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.task;

import com.huawei.sharedrive.uam.weixin.event.WxSuiteEvent;

/************************************************************
 * @Description:
 * <pre>Suite任务基类</pre>
 * @author Rox
 * @version 3.0.1
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/11/25
 ************************************************************/
public abstract class SuiteTask implements Runnable{
    protected String corpId;

    protected String suiteId;

    protected WxSuiteEvent event;

    public String getCorpId() {
        return corpId;
    }

    public void setCorpId(String corpId) {
        this.corpId = corpId;
    }

    public String getSuiteId() {
        return suiteId;
    }

    public void setSuiteId(String suiteId) {
        this.suiteId = suiteId;
    }

    public WxSuiteEvent getEvent() {
        return event;
    }

    public void setEvent(WxSuiteEvent event) {
        this.event = event;
    }
}
