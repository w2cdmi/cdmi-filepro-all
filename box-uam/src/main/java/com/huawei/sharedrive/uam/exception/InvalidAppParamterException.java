package com.huawei.sharedrive.uam.exception;

import org.springframework.http.HttpStatus;

public class InvalidAppParamterException extends BaseRunException
{
    
    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    
    public InvalidAppParamterException()
    {
        super(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_PARAMTER.getCode(),
            ErrorCode.INVALID_PARAMTER.getMessage());
    }
    
}
