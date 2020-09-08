package com.huawei.sharedrive.uam.organization.service.impl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.organization.dao.DepartmentDao;
import com.huawei.sharedrive.uam.organization.dao.impl.DepartmentIdGenerator;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;

@Service
public class DepartmentServiceImpl implements DepartmentService {

	@Autowired
	DepartmentDao departmentDao;
	@Autowired
	private DepartmentIdGenerator departmentIdGenerator;

	@Override
	public Long create(Department departmentInfo) {
		long id= departmentIdGenerator.getNextId()+1L;
		long parentId = departmentInfo.getParentid();
		if(parentId<1){
			departmentInfo.setParentid(-1L);
		}
		departmentInfo.setId(id);
		return departmentDao.createDept(departmentInfo);
	}

	@Override
	public List<Department> listDeptTreeByEnterpriseId(Long enterpriseId) {
		List<Department> list = null;
		if (null != enterpriseId) {
			list = departmentDao.queryDeptByEnterpriseId(enterpriseId);
		}
		return list;
	}

	@Override
	public Department getEnpDeptByNameAndParent(Long enterpriseid, String name, Long pId) {
		Department dept = null;
		if (enterpriseid != null) {
			dept = departmentDao.getEnpDeptByNameAndParent(enterpriseid, name, pId);
		}
		return dept;
	}

	@Override
	public Department getDeptById(Long id) {
		return departmentDao.getById(id);
	}

	@Override
	public void delete(Long departmentId) {
		departmentDao.deleteDept(departmentId);
		
	}
	
	@Override
	public void update(Department dept) {
		departmentDao.updateDept(dept);
		
	}

	public List<Department> listRootDepartmentByEnterpriseId(Long enterpriseId) {
		List<Department> list = null;
		if (null != enterpriseId) {
			list = departmentDao.listRootDeptByEnterpriseId(enterpriseId);
		}
		return list;
	}

	public List<Department> listAllDepartmentByEnterpriseId(long enterpriseId) {
		return departmentDao.listAllDeptByEnterpriseId(enterpriseId);
	}

	@Override
	public List<Department> listDepByParentDepId(long parentDepId, long enterpriseId) {
		return departmentDao.listDepByParentDepId(parentDepId,enterpriseId);
	}

	@Override
	public List<Long> listDeptIdByParentDepId(long parentDepId, long enterpriseId) {
		return departmentDao.listDeptIdByParentDepId(parentDepId, enterpriseId);
	}

	@Override
	public List<Long> listDeptHierarchyOfDept(long deptId) {
		List<Long> hierarchy = new ArrayList<>();

		Department dept = departmentDao.getById(deptId);
		if(dept == null) {
			return hierarchy;
		}

		hierarchy.add(dept.getId());

		while ((dept = getDeptById(dept.getParentid())) != null) {
			hierarchy.add(dept.getId());
		}

		return hierarchy;
	}
}
