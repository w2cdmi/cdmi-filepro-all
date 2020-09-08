package com.huawei.sharedrive.uam.weixin.dao;
/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */

import com.huawei.sharedrive.uam.weixin.domain.WxWorkCorpApp;

import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>WxDepartmentDao</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/26
 ************************************************************/
public interface WxWorkCorpAppDao {
    void create(WxWorkCorpApp department);
    void update(WxWorkCorpApp department);
    void delete(WxWorkCorpApp department);
    void deleteByCorpIdAndSuiteId(String corpId, String suiteId);

    WxWorkCorpApp get(String corpId, String suiteId, Integer appId);
    WxWorkCorpApp getByCorpIdAndAgentId(String corpId, Integer agentId);
    List<WxWorkCorpApp> getByCorpId(String corpId);
    List<WxWorkCorpApp> getByCorpIdAndSuiteId(String corpId, String suiteId);
}
