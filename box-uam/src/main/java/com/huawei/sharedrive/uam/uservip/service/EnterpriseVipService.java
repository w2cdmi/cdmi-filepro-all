package com.huawei.sharedrive.uam.uservip.service;

import java.util.List;

import com.huawei.sharedrive.uam.uservip.domian.EnterpriseVip;

public interface EnterpriseVipService {
	

	void create(EnterpriseVip enterpriseVip);

	void update(EnterpriseVip enterpriseVip);

	EnterpriseVip get(EnterpriseVip enterpriseVip);

	List<EnterpriseVip> listAll();

}
