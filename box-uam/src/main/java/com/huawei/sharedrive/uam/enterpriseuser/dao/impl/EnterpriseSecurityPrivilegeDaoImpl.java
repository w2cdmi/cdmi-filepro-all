package com.huawei.sharedrive.uam.enterpriseuser.dao.impl;

import com.huawei.sharedrive.uam.enterpriseuser.dao.EnterpriseSecurityPrivilegeDao;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseSecurityPrivilege;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.idgenerate.service.EnterpriseUserGenerateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pw.cdmi.box.dao.impl.CacheableSqlMapClientDAO;
import pw.cdmi.box.domain.Limit;
import pw.cdmi.box.domain.Order;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@SuppressWarnings({"unchecked", "deprecation"})
public class EnterpriseSecurityPrivilegeDaoImpl extends CacheableSqlMapClientDAO implements EnterpriseSecurityPrivilegeDao {
    @Override
    public long getMaxId() {
        long maxId = 1L;

        Long ret = (Long)sqlMapClientTemplate.queryForObject("EnterpriseSecurityPrivilege.getMaxId");
        if(ret != null && ret > maxId) {
            return ret;
        }

        return maxId;
    }

    @Override
    public long create(EnterpriseSecurityPrivilege privilege) {
        sqlMapClientTemplate.insert("EnterpriseSecurityPrivilege.insert", privilege);

        return privilege.getId();
    }

    @Override
    public void update(EnterpriseSecurityPrivilege privilege) {
        sqlMapClientTemplate.update("EnterpriseSecurityPrivilege.update", privilege);
    }

    @Override
    public void delete(long enterpriseId,long enterpriseUserId) {
    	Map<String, Long> prameter=new HashMap<>();
    	prameter.put("enterpriseId", enterpriseId);
    	prameter.put("enterpriseUserId", enterpriseUserId);
    	sqlMapClientTemplate.delete("EnterpriseSecurityPrivilege.delete",prameter);
    }

    @Override
    public void deleteBy(long enterpriseId) {

    }

    @Override
    public void deleteBy(long enterpriseId, long departmentId) {

    }

    @Override
    public void deleteByDeptAndRole(long enterpriseId, long departmentId, byte role) {
    	Map<String, Object> prameter=new HashMap<>();
    	prameter.put("enterpriseId", enterpriseId);
    	prameter.put("departmentId", departmentId);
    	prameter.put("role", role);
    	sqlMapClientTemplate.delete("EnterpriseSecurityPrivilege.deleteByDeptAndRole",prameter);
    }

    @Override
    public List<EnterpriseSecurityPrivilege> getIdByEnterpriseAndDepartmentAndRole(long enterpriseId, long departmentId, byte role) {
        Map<String, Object> map = new HashMap<>();
        map.put("tableSuffix", EnterpriseUserDaoImpl.getTableSuffix(enterpriseId));
        map.put("enterpriseId", enterpriseId);
        map.put("departmentId", departmentId);
        map.put("role", role);

        return sqlMapClientTemplate.queryForList("EnterpriseSecurityPrivilege.getIdByEnterpriseAndDepartmentAndRole", map);
    }

    @Override
    public List<EnterpriseUser> getUserByEnterpriseAndDepartmentAndRole(long enterpriseId, long departmentId, byte role) {
        Map<String, Object> map = new HashMap<>();
        map.put("tableSuffix", EnterpriseUserDaoImpl.getTableSuffix(enterpriseId));
        map.put("enterpriseId", enterpriseId);
        map.put("departmentId", departmentId);
        map.put("role", role);

        return sqlMapClientTemplate.queryForList("EnterpriseSecurityPrivilege.getUserByEnterpriseAndDepartmentAndRole", map);
    }

    @Override
    public List<EnterpriseUser> getByEnterpriseAndRole(long enterpriseId, byte role) {
        return null;
    }

    @Override
    public int countWithFilter(long enterpriseId, Long deptId, String authServerId, String filter, byte role) {
        Map<String, Object> map = new HashMap<>();
        map.put("tableSuffix", EnterpriseUserDaoImpl.getTableSuffix(enterpriseId));
        map.put("enterpriseId", enterpriseId);
        map.put("departmentId", deptId);
        map.put("authServerId", authServerId);
        map.put("filter", filter);
        map.put("role", role);

        return (int)sqlMapClientTemplate.queryForObject("EnterpriseSecurityPrivilege.countWithFilter", map);
    }

    @Override
    public List<EnterpriseUser> getWithFilter(long enterpriseId, Long deptId, String authServerId, String filter, byte role, Order order, Limit limit) {
        Map<String, Object> map = new HashMap<>();
        map.put("tableSuffix", EnterpriseUserDaoImpl.getTableSuffix(enterpriseId));
        map.put("enterpriseId", enterpriseId);
        map.put("departmentId", deptId);
        map.put("authServerId", authServerId);
        map.put("filter", filter);
        map.put("role", role);
        map.put("order", order);
        map.put("limit", limit);

        return sqlMapClientTemplate.queryForList("EnterpriseSecurityPrivilege.getWithFilter", map);
    }

	@Override
	public void deleteBy(long enterpriseId, long departmentId, byte role) {
		// TODO Auto-generated method stub
		
	}
}
