package com.huawei.sharedrive.uam.organization.domain;

import java.io.Serializable;

public class Department implements Serializable {

	private static final long serialVersionUID = -6520281177878024379L;

	public final static byte STATE_DEFAULT = 0;
	public final static byte STATE_DELETE = 1;
	private long id;
	private long enterpriseid;
	private long parentid;
	private String domain;
	private String name;
	private Byte state;

	public Department() {
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getEnterpriseid() {
		return enterpriseid;
	}

	public void setEnterpriseid(long enterpriseid) {
		this.enterpriseid = enterpriseid;
	}

	public long getParentid() {
		return parentid;
	}

	public void setParentid(long parentid) {
		this.parentid = parentid;
	}

	public String getDomain() {
		return domain;
	}

	public void setDomain(String domain) {
		this.domain = domain;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Byte getState() {
		return state;
	}

	public void setState(Byte state) {
		this.state = state;
	}

}
