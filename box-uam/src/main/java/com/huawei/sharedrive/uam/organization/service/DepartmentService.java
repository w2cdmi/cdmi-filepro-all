package com.huawei.sharedrive.uam.organization.service;

import java.util.List;

import com.huawei.sharedrive.uam.organization.domain.Department;

public interface DepartmentService {
	Long create(Department DepartmentInfo);
	
	void delete(Long departmentId);
	
	public void update(Department dept);

	public List<Department> listDeptTreeByEnterpriseId(Long enterpriseId);

	public Department getEnpDeptByNameAndParent(Long enterpriseid, String name, Long pId);

	Department getDeptById(Long id);
	
	List<Department> listRootDepartmentByEnterpriseId(Long enterpriseId);
	
	List<Department> listAllDepartmentByEnterpriseId(long enterpriseId);

	List<Department> listDepByParentDepId(long parentDepId, long enterpriseId);
	
	List<Long> listDeptIdByParentDepId(long parentDepId, long enterpriseId);

	//返回从当前剖部门（deptId)到最高部门的ID列表。如果指定的部门不存在，返回空列表。
	List<Long> listDeptHierarchyOfDept(long deptId);
}
