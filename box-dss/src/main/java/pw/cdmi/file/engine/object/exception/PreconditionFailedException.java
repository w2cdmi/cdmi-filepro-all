/*
 * 版权声明(Copyright Notice)：
 *      Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 *      Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved. 
 * 
 *      警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业目
 */ 
package pw.cdmi.file.engine.object.exception;

import pw.cdmi.file.engine.core.exception.BusinessException;

/**
 * 前置条件不满足异常
 * 
 * @author s90006125
 * 
 */
public class PreconditionFailedException extends BusinessException
{
    private static final long serialVersionUID = 93684069247547203L;
    
    public PreconditionFailedException(String code, String message)
    {
        super(code, message);
    }
    
    public PreconditionFailedException(String code, String message, Exception e)
    {
        super(code, message, e);
    }
}
