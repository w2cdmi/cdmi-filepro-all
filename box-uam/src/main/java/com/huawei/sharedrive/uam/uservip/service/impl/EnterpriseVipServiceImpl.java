package com.huawei.sharedrive.uam.uservip.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.uservip.dao.EnterpriseVipDao;
import com.huawei.sharedrive.uam.uservip.domian.EnterpriseVip;
import com.huawei.sharedrive.uam.uservip.service.EnterpriseVipService;

@Service
public class EnterpriseVipServiceImpl implements EnterpriseVipService{
	
	
	@Autowired
	private EnterpriseVipDao enterpriseVipDao;

	@Override
	public void create(EnterpriseVip enterpriseVip) {
		// TODO Auto-generated method stub
		enterpriseVipDao.create(enterpriseVip);
	}

	@Override
	public void update(EnterpriseVip enterpriseVip) {
		// TODO Auto-generated method stub
		enterpriseVipDao.update(enterpriseVip);
		
	}

	@Override
	public EnterpriseVip get(EnterpriseVip enterpriseVip) {
		// TODO Auto-generated method stub
		return enterpriseVipDao.get(enterpriseVip);
	}

	@Override
	public List<EnterpriseVip> listAll() {
		// TODO Auto-generated method stub
		return enterpriseVipDao.listAll();
	}
	
	

}
