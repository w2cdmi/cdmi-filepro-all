package com.huawei.sharedrive.uam.weixin.domain;

import pw.cdmi.core.exception.InvalidParamException;

public class RestWxUserOrderRequest {
	
	private String openId;
	
	private long productId;
	//购买类型 新购、续费、升级
	private byte type;
	
	private int duration;

	public String getOpenId() {
		return openId;
	}

	public void setOpenId(String openId) {
		this.openId = openId;
	}

	public long getProductId() {
		return productId;
	}

	public void setProductId(long productId) {
		this.productId = productId;
	}

	public byte getType() {
		return type;
	}

	public void setType(byte type) {
		this.type = type;
	}

	public int getDuration() {
		return duration;
	}

	public void setDuration(int duration) {
		this.duration = duration;
	}

	public void checkParameter() throws InvalidParamException
    {
        if (openId == null)
        {
            throw new InvalidParamException();
        }
        
        if (productId == 0)
        {
            throw new InvalidParamException();
        }
        
        if (type > 3 && type < 1)
        {
            throw new InvalidParamException();
		}
        
        if(duration < 3){
        	throw new InvalidParamException();
        }
	}
}
