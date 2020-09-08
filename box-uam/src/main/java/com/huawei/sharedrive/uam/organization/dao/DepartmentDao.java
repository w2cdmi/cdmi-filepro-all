package com.huawei.sharedrive.uam.organization.dao;

import java.util.List;

import com.huawei.sharedrive.uam.organization.domain.Department;

public interface DepartmentDao {

	Long createDept(Department DepartmentInfo);

    void updateDept(Department dept);

	void updateState();
	
	void deleteDept(Long departmentId);

	Department getById(long id);

	List<Department> queryDeptByEnterpriseId(Long enterpriseId);

	Department getEnpDeptByNameAndParent(Long enterpriseid, String name, Long pId);

	long queryMaxExecuteRecordId();

	List<Department> listRootDeptByEnterpriseId(Long enterpriseId);

	List<Department> listAllDeptByEnterpriseId(long enterpriseId);

	List<Department> listDepByParentDepId(long parentDepId, long enterpriseId);
	
	List<Long> listDeptIdByParentDepId(long parentDepId, long enterpriseId);
	
}
