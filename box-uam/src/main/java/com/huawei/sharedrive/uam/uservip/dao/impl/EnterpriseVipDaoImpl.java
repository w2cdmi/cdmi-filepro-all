package com.huawei.sharedrive.uam.uservip.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;
import com.huawei.sharedrive.uam.uservip.dao.EnterpriseVipDao;
import com.huawei.sharedrive.uam.uservip.domian.EnterpriseVip;

import pw.cdmi.box.dao.impl.CacheableSqlMapClientDAO;

@Repository
public class EnterpriseVipDaoImpl extends CacheableSqlMapClientDAO implements EnterpriseVipDao{
	
	@Override
	public void create(EnterpriseVip enterpriseVip){
		
		sqlMapClientTemplate.insert("EnterpriseVip.create",enterpriseVip);
	}
	
	@Override
	public void update(EnterpriseVip enterpriseVip){
		
		sqlMapClientTemplate.update("EnterpriseVip.update",enterpriseVip);
		
	}
	
	@Override
	public EnterpriseVip get(EnterpriseVip enterpriseVip){
		
		 return (EnterpriseVip) sqlMapClientTemplate.queryForObject("EnterpriseVip.get",enterpriseVip);
		
	}
	
	@Override
	public List<EnterpriseVip> listAll(){
		
		return sqlMapClientTemplate.queryForList("EnterpriseVip.listAll");
		
	}
	

}
