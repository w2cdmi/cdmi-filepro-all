package com.huawei.sharedrive.uam.organization.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.organization.dao.DepartmentDao;
import com.huawei.sharedrive.uam.organization.domain.Department;

import pw.cdmi.box.dao.impl.CacheableSqlMapClientDAO;

@SuppressWarnings({ "unchecked", "deprecation" })
@Service
public class DepartmentDaoImpl extends CacheableSqlMapClientDAO implements DepartmentDao {

	@Override
	public Long createDept(Department departmentInfo) {
		sqlMapClientTemplate.insert("Department.addDept", departmentInfo);
		return departmentInfo.getId();
	}

	@Override
	public void updateDept(Department dept) {
		Map<String, Object> map = new HashMap<String, Object>(5);
        map.put("enterpriseId", dept.getEnterpriseid());
        map.put("id", dept.getId());
        map.put("name", dept.getName());
        map.put("state", dept.getState());
		map.put("parentId", dept.getParentid());

		sqlMapClientTemplate.update("Department.updateDept", map);
	}

	public void updateState() {

	}

	@Override
	public Department getById(long id) {
		Map<String, Object> map = new HashMap<String, Object>(1);
		map.put("id", id);
		return (Department) sqlMapClientTemplate.queryForObject("Department.getDeptById", map);
	}

	@Override
	public List<Department> queryDeptByEnterpriseId(Long enterpriseid) {
		return sqlMapClientTemplate.queryForList("Department.queryByEnterpriseId", enterpriseid);
	}

	@Override
	public Department getEnpDeptByNameAndParent(Long enterpriseid, String name, Long pId) {

		Map<String, Object> map = new HashMap<String, Object>(3);
		map.put("enterpriseid", enterpriseid);
		map.put("name", name);
		map.put("parentid", pId);
		return (Department) sqlMapClientTemplate.queryForObject("Department.getEnpDeptByNameAndParent", map);
	}

	@Override
	public List<Department> listRootDeptByEnterpriseId(Long enterpriseId) {
		List<Department> list = sqlMapClientTemplate.queryForList("Department.listRootDept", enterpriseId); 
		return list;
	}

	@Override
	public List<Department> listAllDeptByEnterpriseId(long enterpriseId) {
		Map<String, Object> map = new HashMap<String, Object>(3);
		map.put("enterpriseid", enterpriseId);
		List<Department> list = sqlMapClientTemplate.queryForList("Department.deptList", map);
		return list;
	}

	@Override
	public List<Department> listDepByParentDepId(long parentDepId, long enterpriseId) {
		Map<String, Object> map = new HashMap<String, Object>(3);
		map.put("parentid", parentDepId);
		map.put("enterpriseid", enterpriseId);
		List<Department> list = sqlMapClientTemplate.queryForList("Department.listDepByParentDepId", map); 
		return list;
	}

	@Override
	public long queryMaxExecuteRecordId() {
		Object maxId = sqlMapClientTemplate.queryForObject("Department.getMaxId");
		if (maxId == null) {
			return 0L;
		}
		return (Long) maxId;
	}

	@Override
	public void deleteDept(Long departmentId) {
		
		sqlMapClientTemplate.delete("Department.deleteDept", departmentId);
		
	}

	@Override
	public List<Long> listDeptIdByParentDepId(long parentDepId, long enterpriseId) {
		Map<String,Long> map = new HashMap<String,Long>(3);
		map.put("parentid", parentDepId);
		map.put("enterpriseid", enterpriseId);
		List<Long> list = sqlMapClientTemplate.queryForList("Department.listDeptIdByParentDepId",map);
		return list;
	}

}
