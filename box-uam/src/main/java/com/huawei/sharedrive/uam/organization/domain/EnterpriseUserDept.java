package com.huawei.sharedrive.uam.organization.domain;

import java.io.Serializable;

public class EnterpriseUserDept implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 3391106675382599992L;
	private String enterpriseUserName;
	private String userName;
	private String userDeptName;
	public String getEnterpriseUserName() {
		return enterpriseUserName;
	}
	public void setEnterpriseUserName(String enterpriseUserName) {
		this.enterpriseUserName = enterpriseUserName;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getUserDeptName() {
		return userDeptName;
	}
	public void setUserDeptName(String userDeptName) {
		this.userDeptName = userDeptName;
	}

	

}
