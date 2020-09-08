package com.huawei.sharedrive.uam.organization.domain;

import java.util.List;

public class DeptNode {
	private String id;
	private String userId;
	private String pId;
	private String name;
	private String email;
	private String type;
	private String alias;
	private List<DeptNode> Children;
	private Boolean isParent=true;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getAlias() {
		return alias;
	}

	public void setAlias(String alias) {
		this.alias = alias;
	}


	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getpId() {
		return pId;
	}

	public void setpId(String pId) {
		this.pId = pId;
	}

	public List<DeptNode> getChildren() {
		return Children;
	}

	public void setChildren(List<DeptNode> children) {
		Children = children;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}
	public Boolean getIsParent() {
		return isParent;
	}
	public void setIsParent(Boolean isParent) {
		this.isParent = isParent;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	
}
