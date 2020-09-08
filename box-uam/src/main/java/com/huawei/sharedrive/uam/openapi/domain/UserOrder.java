package com.huawei.sharedrive.uam.openapi.domain;

import java.io.Serializable;
import java.security.InvalidParameterException;

import org.apache.commons.lang.StringUtils;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class UserOrder implements Serializable
{
    private static final long serialVersionUID = 3015209201655530475L;
    
    private static final String DEFAULT_DIRECTION = "ASC";
    
    private static final String[] SUPPORTED_DIRECTION = {"ASC", "DESC"};
    
    private static final String[] SUPPORTED_ORDERBY = {"loginName", "createdAt", "status", "regionId"};
    
    private String direction;
    
    private String field;
    
    public UserOrder()
    {
        this.direction = DEFAULT_DIRECTION;
    }
    
    public UserOrder(String field, String direction)
    {
        this.field = field;
        this.direction = direction != null ? direction : DEFAULT_DIRECTION;
    }
    
    public void checkParameter() throws InvalidParameterException
    {
        if (!isFieldValid())
        {
            throw new InvalidParameterException();
        }
        if (direction != null && !isDirectionValid())
        {
            throw new InvalidParameterException();
        }
    }
    
    @JsonIgnore
    private boolean isFieldValid()
    {
        if (StringUtils.isBlank(field))
        {
            return false;
        }
        for (String temp : SUPPORTED_ORDERBY)
        {
            if (temp.equalsIgnoreCase(field))
            {
                return true;
            }
        }
        return false;
    }
    
    @JsonIgnore
    private boolean isDirectionValid()
    {
        for (String temp : SUPPORTED_DIRECTION)
        {
            if (temp.equalsIgnoreCase(direction))
            {
                return true;
            }
            
        }
        return false;
    }
    
    public String getDirection()
    {
        return direction;
    }
    
    public String getField()
    {
        return field;
    }
    
    @JsonIgnore
    public boolean isDesc()
    {
        return "DESC".equalsIgnoreCase(this.direction);
    }
    
    public void setDirection(String direction)
    {
        this.direction = direction;
    }
    
    public void setField(String field)
    {
        this.field = field;
    }
    
}
