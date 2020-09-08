package com.huawei.sharedrive.uam.log.dao.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.adminlog.dao.impl.LogLanguageHelper;
import com.huawei.sharedrive.uam.log.dao.UserLogDAO;
import com.huawei.sharedrive.uam.log.domain.UserLogListReq;

import pw.cdmi.box.dao.impl.AbstractDAOImpl;
import pw.cdmi.common.log.UserLog;
import pw.cdmi.core.utils.DateUtils;

@SuppressWarnings("deprecation")
@Service
public class UserLogDAOImpl extends AbstractDAOImpl implements UserLogDAO
{
    private static final String EVENT_LOG_DATE_PATTERN = "yyyyMMdd";
    
    @Override
    public void create(UserLog eventLog)
    {
        
        if (!LogLanguageHelper.isSaveUserLog())
        {
            return;
        }
        eventLog.setId(UUID.randomUUID().toString().replaceAll("-", ""));
        eventLog.setCreatedAt(new Date());
        int tableSuffix = Integer.parseInt(DateUtils.dateToString(eventLog.getCreatedAt(),
            EVENT_LOG_DATE_PATTERN));
        eventLog.setTableSuffix(tableSuffix);
        super.getUserLogTemplate().insert("UserLog.insert", eventLog);
    }
    
    @Override
    public void createTable(Date ltDate)
    {
        int tableSuffix = Integer.parseInt(DateUtils.dateToString(ltDate, EVENT_LOG_DATE_PATTERN));
        UserLog eventLog = new UserLog();
        eventLog.setTableSuffix(tableSuffix);
        super.getUserLogTemplate().update("UserLog.createTable", eventLog);
    }
    
    @Override
    public void dropTable(Date ltDate)
    {
        int tableSuffix = Integer.parseInt(DateUtils.dateToString(ltDate, EVENT_LOG_DATE_PATTERN));
        UserLog eventLog = new UserLog();
        eventLog.setTableSuffix(tableSuffix);
        super.getUserLogTemplate().update("UserLog.dropTable", eventLog);
    }
    
    @Override
    public long getTotals(UserLogListReq req, String tableName)
    {
        Map<String, Object> map = new HashMap<String, Object>(2);
        map.put("tableName", tableName);
        map.put("filter", req);
        return (long) super.getUserLogTemplate().queryForObject("UserLog.getTotalForOneLog", map);
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public List<UserLog> getUserLogList(UserLogListReq req, String tableName, long offset, int limit)
    {
        Map<String, Object> map = new HashMap<String, Object>(2);
        map.put("tableName", tableName);
        map.put("filter", req);
        map.put("limit", limit);
        map.put("offset", offset);
        return super.getUserLogTemplate().queryForList("UserLog.getList", map);
    }
}
