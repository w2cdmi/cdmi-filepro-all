package com.huawei.sharedrive.uam.wxrobot.domain;

import java.util.Map;

public class WxRobotConfig {
	
	//个人消息配置
	public static byte TYPE_USER=1;
	//群组消息配置
	public static byte TYPE_GROUP=2;
	
	public static long VALUE_DEFAULT=1;
	
	public static String NAME_USER="config_user_def";
	
	public static String NAME_GROUP="config_group_def";
	
	private long robotId;
	private String name;
	private long value;
	private byte type;
	public Map<String, Boolean> config;
	
	
	public long getRobotId() {
		return robotId;
	}
	public void setRobotId(long robotId) {
		this.robotId = robotId;
	}
	public byte getType() {
		return type;
	}
	public void setType(byte type) {
		this.type = type;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	} 
    
	public long getValue() {
		return value;
	}
	public void setValue(long value) {
		this.value = value;
	}

}
