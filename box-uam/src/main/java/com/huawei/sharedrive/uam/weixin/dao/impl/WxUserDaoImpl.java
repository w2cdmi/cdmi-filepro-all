package com.huawei.sharedrive.uam.weixin.dao.impl;
/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.weixin.dao.WxUserDao;
import com.huawei.sharedrive.uam.weixin.domain.WxUser;

import pw.cdmi.box.dao.impl.CacheableSqlMapClientDAO;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>WxUserDao实现类</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/26
 ************************************************************/

@Service
public class WxUserDaoImpl extends CacheableSqlMapClientDAO implements WxUserDao {
    @Override
    public void create(WxUser user) {
        sqlMapClientTemplate.insert("WxUser.insert", user);
    }

    @Override
    public void update(WxUser user) {
        sqlMapClientTemplate.update("WxUser.update", user);
    }

    @Override
    public void deleteByUnionId(String openId) {
        sqlMapClientTemplate.delete("WxUser.deleteByUnionId", openId);
    }

    @Override
    public WxUser getByOpenId(String openId) {
        return (WxUser)sqlMapClientTemplate.queryForObject("WxUser.getByOpenId", openId);
    }

    @Override
    public WxUser getByUnionId(String unionId) {
        return (WxUser)sqlMapClientTemplate.queryForObject("WxUser.getByUnionId", unionId);
    }

	@Override
	public WxUser getByUin(String uin) {
		// TODO Auto-generated method stub
		return (WxUser)sqlMapClientTemplate.queryForObject("WxUser.getByUin", uin);
	}

	@Override
	public void updateUinByUnionId(String uin, String unionId) {
		// TODO Auto-generated method stub
		Map<String, String> prameter=new HashMap<>();
		prameter.put("uin", uin);
		prameter.put("unionId", unionId);
		sqlMapClientTemplate.update("WxUser.updateUinByUnionId", prameter);
	}
}
