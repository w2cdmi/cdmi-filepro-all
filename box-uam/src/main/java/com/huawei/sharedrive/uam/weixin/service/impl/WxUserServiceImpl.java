/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.weixin.dao.WxUserDao;
import com.huawei.sharedrive.uam.weixin.domain.WxUser;
import com.huawei.sharedrive.uam.weixin.service.WxUserService;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>部门员工管理</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Service
public class WxUserServiceImpl implements WxUserService {
    private static final Logger logger = LoggerFactory.getLogger(WxUserServiceImpl.class);
    
    @Autowired
    private WxUserDao wxUserDao;

    @Override
    public void create(WxUser wxUser) {
        wxUserDao.create(wxUser);
    }

    @Override
    public void update(WxUser wxUser) {
        wxUserDao.update(wxUser);
    }

    @Override
    public void delete(String unionId) {
        //删除微信用户信息
        wxUserDao.deleteByUnionId(unionId);
    }

    @Override
    public WxUser getByOpenId(String openId) {
        return wxUserDao.getByOpenId(openId);
    }

    public WxUser getByUnionId(String unionId) {
        return wxUserDao.getByUnionId(unionId);
    }
}
