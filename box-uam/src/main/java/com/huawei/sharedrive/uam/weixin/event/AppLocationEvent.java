package com.huawei.sharedrive.uam.weixin.event;
/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>App位置事件</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/27
 ************************************************************/
public class AppLocationEvent extends WxAppEvent {
    Float latitude;
    Float longitude;
    Float precision;

    public Float getLatitude() {
        return latitude;
    }

    public void setLatitude(Float latitude) {
        this.latitude = latitude;
    }

    public Float getLongitude() {
        return longitude;
    }

    public void setLongitude(Float longitude) {
        this.longitude = longitude;
    }

    public Float getPrecision() {
        return precision;
    }

    public void setPrecision(Float precision) {
        this.precision = precision;
    }
}
