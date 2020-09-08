package com.huawei.sharedrive.uam.log.dao;

import java.util.List;

import com.huawei.sharedrive.uam.log.domain.QueryCondition;

import pw.cdmi.box.domain.Limit;
import pw.cdmi.common.log.SystemLog;

public interface SystemLogDao
{
    
    void create(SystemLog systemLog);
    
    int getFilterdCount(QueryCondition filter);
    
    List<SystemLog> getFilterd(QueryCondition filter);
    
    int getCountByLoginName(SystemLog systemLog);
    
    List<SystemLog> getByLoginName(SystemLog systemLog, Limit limit);
    
    void updateSuccess(String id);
    
    void deleteById(String id);
    
}
