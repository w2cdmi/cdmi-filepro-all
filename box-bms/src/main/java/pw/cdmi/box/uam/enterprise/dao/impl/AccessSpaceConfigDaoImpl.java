package pw.cdmi.box.uam.enterprise.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Component;

import pw.cdmi.box.dao.impl.CacheableSqlMapClientDAO;
import pw.cdmi.box.domain.Limit;
import pw.cdmi.box.domain.Order;
import pw.cdmi.box.uam.enterprise.dao.AccessSpaceConfigDao;
import pw.cdmi.box.uam.enterprise.domain.AccessSpaceConfig;
import pw.cdmi.box.uam.exception.ExistAccessConfigConflictException;

@SuppressWarnings({"unchecked", "deprecation"})
@Component
public class AccessSpaceConfigDaoImpl extends CacheableSqlMapClientDAO implements AccessSpaceConfigDao
{
    
    @Override
    public void create(AccessSpaceConfig netRegion)
    {
        sqlMapClientTemplate.insert("AccessSpaceConfig.insert", netRegion);
    }
    
    @Override
    public void delete(String id)
    {
        sqlMapClientTemplate.delete("AccessSpaceConfig.delete", id);
    }
    
    @Override
    public long getByDomainExclusiveId(AccessSpaceConfig netRegion)
    {
        long count = (long) sqlMapClientTemplate.queryForObject("AccessSpaceConfig.getByDomainExclusiveId",
            netRegion);
        return count;
    }
    
    @Override
    public AccessSpaceConfig getById(String id)
    {
        return (AccessSpaceConfig) sqlMapClientTemplate.queryForObject("AccessSpaceConfig.getById", id);
    }
    
    @Override
    public List<AccessSpaceConfig> getFilterd(AccessSpaceConfig filter, Order order, Limit limit)
    {
        Map<String, Object> map = new HashMap<String, Object>(3);
        map.put("filter", filter);
        map.put("order", order);
        map.put("limit", limit);
        return sqlMapClientTemplate.queryForList("AccessSpaceConfig.getFilterd", map);
    }
    
    @Override
    public int getFilterdCount(AccessSpaceConfig filter)
    {
        Map<String, Object> map = new HashMap<String, Object>(1);
        map.put("filter", filter);
        return (Integer) sqlMapClientTemplate.queryForObject("AccessSpaceConfig.getFilterdCount", map);
    }
    
    @Override
    public List<AccessSpaceConfig> getListByOperation(long accountId, long intValue)
    {
        Map<String, Object> map = new HashMap<String, Object>(2);
        map.put("accountId", accountId);
        map.put("operation", intValue);
        return sqlMapClientTemplate.queryForList("AccessSpaceConfig.getListByOperation", map);
    }
    
    @Override
    public AccessSpaceConfig getObject(AccessSpaceConfig spaceConfig)
    {
        return (AccessSpaceConfig) sqlMapClientTemplate.queryForObject("AccessSpaceConfig.getObject",
            spaceConfig);
    }
    
    @Override
    public boolean isDuplicateValues(AccessSpaceConfig accessSpaceConfig)
    {
        int count = (int) sqlMapClientTemplate.queryForObject("AccessSpaceConfig.getDuplicateValues",
            accessSpaceConfig);
        if (count > 0)
        {
            return true;
        }
        return false;
    }
    
    @Override
    public void update(AccessSpaceConfig accessSpaceConfig)
    {
        try
        {
            sqlMapClientTemplate.update("AccessSpaceConfig.modify", accessSpaceConfig);
        }
        catch (DataAccessException e)
        {
            throw new ExistAccessConfigConflictException(e);
        }
    }
    
    @Override
    public void deleteByCondition(AccessSpaceConfig accessSpaceConfig)
    {
        sqlMapClientTemplate.delete("AccessSpaceConfig.deleteByCondition", accessSpaceConfig);
    }
}
