package com.huawei.sharedrive.uam.organization.manager.impl;

import java.util.ArrayList;
import java.util.List;

import org.apache.shiro.util.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.manager.UserAccountManager;
import com.huawei.sharedrive.uam.accountuser.service.UserAccountService;
import com.huawei.sharedrive.uam.enterprise.manager.EnterpriseAccountManager;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUserExtend;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.exception.BusinessException;
import com.huawei.sharedrive.uam.exception.NoSuchItemException;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.domain.DeptNode;
import com.huawei.sharedrive.uam.organization.manager.DepartmentManager;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;

import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageImpl;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;

@Component
public class DepartmentManagerImpl implements DepartmentManager {

	
	@Autowired
	DepartmentService departmentService;

	@Autowired
	EnterpriseUserService enterpriseUserService;
	@Autowired
	UserAccountService userAccountService;
	@Autowired
	EnterpriseAccountManager enterpriseAccountManager;
	@Autowired
	UserAccountManager userAccountManager;
	
	@Override
	public Long create(Department DepartmentInfo) {
		return departmentService.create(DepartmentInfo);
	}

	/**
	 * List all enterprise User by enterpriseId
	 * 
	 * @param enterpriseId
	 */
	@Override
	public List<DeptNode> getAllByEnterpriseId(long id, long accountId) {
		List<Department> deps = departmentService.listDeptTreeByEnterpriseId(id);
		List<EnterpriseUser> allEnterpriseUser = enterpriseUserService.getAllEnterpriseUser(id);
		List<EnterpriseUser> list = new ArrayList<>();
		for (EnterpriseUser enterpriseUser : allEnterpriseUser) {
			UserAccount userAccount = userAccountService.get(enterpriseUser.getId(), accountId);
			if (userAccount != null) {
				enterpriseUser.setId(userAccount.getCloudUserId());
				list.add(enterpriseUser);
			}
		}
		List<DeptNode> deptTree = convert2NodeList(deps, list);
		return deptTree;
	}

	/**
	 * Convert list into node list that they have dependency relationship for
	 * each other
	 * 
	 * @param deptList
	 */
	private List<DeptNode> convert2NodeList(List<Department> deptList, List<EnterpriseUser> users) {
		List<DeptNode> list = new ArrayList<>();
		for (Department dept : deptList) {
			DeptNode mj = new DeptNode();
			mj.setId(String.valueOf(dept.getId()));
			mj.setpId(String.valueOf(dept.getParentid()));
			mj.setName(dept.getName());
			mj.setType("department");
			list.add(mj);
		}
		if (users != null) {
			for (EnterpriseUser user : users) {
				DeptNode mj = new DeptNode();
				mj.setId(String.valueOf(user.getId()));
				mj.setpId(String.valueOf(user.getDepartmentId()));
				mj.setName(user.getName());
				mj.setEmail(user.getEmail());
				mj.setAlias(user.getAlias());
				mj.setType("user");
				list.add(mj);
			}
		}
		return list;
	}

	/**
	 * Create node list into node tree that their node have dependency
	 * relationship for each other
	 * 
	 * @param deptList
	 *            the bean list
	 */
	public List<DeptNode> createDeptTree(List<Department> deptList, List<EnterpriseUser> users) {
		List<DeptNode> result = new ArrayList<>();
		List<DeptNode> targetList = convert2NodeList(deptList, users);
		for (DeptNode mj1 : targetList) {
			boolean isRoot = true;
			for (DeptNode mj2 : targetList) {
				if (mj2.getId().equals(mj1.getpId())) {
					isRoot = false;
					if (mj2.getChildren() == null) {
						mj2.setChildren(new ArrayList<DeptNode>());
					}
					mj2.getChildren().add(mj1);
					break;
				}
			}
			if (isRoot) {
				result.add(mj1);
			}
		}
		return result;
	}
	public List<DeptNode> createDeptTree(List<Department> deptList) {
		List<DeptNode> targetList = convert2NodeList(deptList,null);
		return targetList;
	}

	@Override
	public Department getDepartmentByPath(long enterpriseId, String deptPath) {
		Department targetDept = null;
		if (null != deptPath && deptPath.trim().length() > 0) {
			targetDept = obtainTartgetDept(enterpriseId, deptPath, -1L);
		}
		return targetDept;
	}

	public Department obtainTartgetDept(long enterpriseId, String depts, long parentid) {
		Department retDept = null;
		int index = depts.indexOf("\\");

		if (index > -1) {
			String topClassDeptNm = depts.substring(0, index);
			Department dept = departmentService.getEnpDeptByNameAndParent(enterpriseId, topClassDeptNm, parentid);

			if (dept != null) {
				String pStr = depts.substring(index + 1, depts.length());
				retDept = obtainTartgetDept(enterpriseId, pStr, dept.getId());
			} else {
				throw new NoSuchItemException("DepartmentNotFoudException");
			}
		} else {
			retDept = departmentService.getEnpDeptByNameAndParent(enterpriseId, depts, parentid);
		}
		return retDept;
	}

	@Override
	public Department getDeptById(long enterpriseId, long id) {
		return departmentService.getDeptById(id);
	}

	public List<DeptNode> listDeptTreeByEnterpriseId(Long enterpriseId) {
		List<Department> list = null;
		List<DeptNode> deptList = null;
		if (null != enterpriseId) {
			list = departmentService.listDeptTreeByEnterpriseId(enterpriseId);
		}
		if (list != null && list.size() > 0) {
			deptList = convert2NodeList(list, null);
		}
		return deptList;
	}

	@Override
	public List<DeptNode> getRootDepartment(long enterpriseId) {
		List<Department> list = departmentService.listRootDepartmentByEnterpriseId(enterpriseId);
		List<DeptNode> targetList = convert2NodeList(list,null);
		return targetList;
	}

	@Override
	public List<Department> listDepByParentDepId(long parentDepId, long enterpriseId) {
		List<Department> list = departmentService.listDepByParentDepId(parentDepId,enterpriseId);
		return list;
	}

	private List<Long> getAllDeptIds(List<Long> deptIds,long deptId,long enterpriseId){
   	 List<Department> listDepByParentDepId = listDepByParentDepId(deptId,enterpriseId);
   	 if(listDepByParentDepId.size()!=0){
   		 for (Department department : listDepByParentDepId) {
   			 long id = department.getId();
   			 deptIds.add(id);
   			 getAllDeptIds(deptIds,id,enterpriseId);
			}
   	 }
   	return deptIds;
   }
	
	@Override
	public Page<EnterpriseUserExtend> delete(Long departmentId,long enterpriseId,long authServerId) {
		List<Long> list = new ArrayList<>();
		list.add(departmentId);
		List<EnterpriseUser> userList = new ArrayList<>();
		int total = 0;
		try {
			
			list = getAllDeptIds(list, departmentId, enterpriseId);
			if(list!=null && list.size()>0 ){
				List<EnterpriseUser> tempList = null;
				for(Long l : list){
					tempList = enterpriseUserService.getFilterd(null, authServerId, l, enterpriseId, null, null);
					userList.addAll(tempList);
					total =total + tempList.size();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		if(CollectionUtils.isEmpty(userList)){
			for(Long l : list){
				departmentService.delete(l);
			}
			return null;
		}
		Page<EnterpriseUser> page = new PageImpl<EnterpriseUser>(userList, null, total);
		List<EnterpriseUser> pageList = page.getContent();
        List<EnterpriseAccount> enterpriseAccountList = enterpriseAccountManager.getByEnterpriseId(enterpriseId);
        List<EnterpriseUserExtend> enterpriseUserExtendList = new ArrayList<EnterpriseUserExtend>(10);
        EnterpriseUserExtend enterpriseUserExtend;
        for (EnterpriseUser enterpriseUser : pageList)
        {
            enterpriseUserExtend = bulidEnterpriseUserExtend(enterpriseUser, enterpriseAccountList);
            enterpriseUserExtendList.add(enterpriseUserExtend);
        }
        Page<EnterpriseUserExtend> enterpriseUserExtendPage = new PageImpl<EnterpriseUserExtend>(
            enterpriseUserExtendList, null, page.getTotalElements());
        
		return enterpriseUserExtendPage;
	}
	
	private EnterpriseUserExtend bulidEnterpriseUserExtend(EnterpriseUser enterpriseUser,
	        List<EnterpriseAccount> enterpriseAccounts)
	    {
	        EnterpriseUserExtend enterpriseUserExtend = EnterpriseUserExtend.copyEnterpriseUserPro(enterpriseUser);
	        List<String> authAppIdList = enterpriseUserExtend.getAuthAppIdList();
	        String authAppId;
	        for (EnterpriseAccount enterpriseAccount : enterpriseAccounts)
	        {
	            authAppId = enterpriseAccount.getAuthAppId();
	            try
	            {
	                UserAccount userAccount = userAccountManager.getUserAccountByApp(enterpriseUser.getId(),
	                    enterpriseUser.getEnterpriseId(),
	                    authAppId);
	                if (null != userAccount)
	                {
	                    authAppIdList.add(authAppId);
	                }
	            }
	            catch (BusinessException e)
	            {
	                continue;
	            }
	        }
	        return enterpriseUserExtend;
	    }
	
	@Override
	public void update(Department dept) {
		
		departmentService.update(dept);
		
	} 

}
