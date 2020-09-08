package com.huawei.sharedrive.uam.enterpriseuser.service.impl;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.service.UserAccountService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterpriseuser.dao.EnterpriseSecurityPrivilegeDao;
import com.huawei.sharedrive.uam.enterpriseuser.dao.EnterpriseUserDao;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseSecurityPrivilege;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseSecurityPrivilegeService;
import com.huawei.sharedrive.uam.organization.domain.DepartmentAccount;
import com.huawei.sharedrive.uam.organization.service.DepartmentAccountService;
import com.huawei.sharedrive.uam.teamspace.domain.ChangeOwnerRequest;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamMember;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamMemberCreateRequest;
import com.huawei.sharedrive.uam.teamspace.service.TeamSpaceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import pw.cdmi.box.domain.Limit;
import pw.cdmi.box.domain.Order;
import java.util.List;

@Component
public class EnterpriseSecurityPrivilegeServiceImpl implements EnterpriseSecurityPrivilegeService {
    @Autowired
    EnterpriseSecurityPrivilegeIdGenerator enterpriseSecurityPrivilegeIdGenerator;

    @Autowired
    private EnterpriseSecurityPrivilegeDao privilegeDao;

    @Autowired
    private EnterpriseUserDao enterpriseUserDao;
    
    @Autowired
    private EnterpriseAccountService enterpriseAccountService;
    
    @Autowired
    private DepartmentAccountService  departmentAccountService;
    
 	@Autowired
    private UserAccountService userAccountService;
 	
    @Autowired
    private TeamSpaceService teamSpaceService;
    
    @Autowired
    private DepartmentAccountService deptAccountService;

    @Override
    public long create(EnterpriseSecurityPrivilege privilege) {
        return privilegeDao.create(privilege);
    }

    @Override
    public void update(EnterpriseSecurityPrivilege privilege) {

    }

    @Override
    public void deleteBy(long enterpriseId) {
    	
    }

    @Override
    public void deleteBy(long enterpriseId, long departmentId) {

    }

    @Override
    public void deleteBy(long enterpriseId, long departmentId, byte role) {

    }

    @Override
    public EnterpriseUser getInfoSecurityManager(long enterpriseId) {
        List<EnterpriseUser> userList = privilegeDao.getUserByEnterpriseAndDepartmentAndRole(enterpriseId, 0L, EnterpriseSecurityPrivilege.ROLE_SECURITY_MANAGER);

        if(userList != null && !userList.isEmpty()) {
            return userList.get(0);
        }

        return null;
    }

    public void setInfoSecurityManager(long enterpriseId, long enterpriseUserId) {
        List<EnterpriseSecurityPrivilege> list = privilegeDao.getIdByEnterpriseAndDepartmentAndRole(enterpriseId, 0L, EnterpriseSecurityPrivilege.ROLE_SECURITY_MANAGER);
        if(list != null && !list.isEmpty()) {
            EnterpriseSecurityPrivilege privilege = list.get(0);
            privilege.setEnterpriseUserId(enterpriseUserId);
            privilegeDao.update(privilege);
        } else {
            EnterpriseSecurityPrivilege privilege = new EnterpriseSecurityPrivilege();
            privilege.setId(enterpriseSecurityPrivilegeIdGenerator.getNextId());
            privilege.setEnterpriseId(enterpriseId);
            privilege.setDepartmentId(0L); //0表示公司
            privilege.setRole(EnterpriseSecurityPrivilege.ROLE_SECURITY_MANAGER);
            privilege.setEnterpriseUserId(enterpriseUserId);

            privilegeDao.create(privilege);
        }
    }

    @Override
    public int countArchiveOwnerCountWithFilter(long enterpriseId, Long deptId, String authServerId, String filter) {
        return privilegeDao.countWithFilter(enterpriseId, deptId, authServerId, filter, EnterpriseSecurityPrivilege.ROLE_ARCHIVE_MANAGER);
    }

    @Override
    public List<EnterpriseUser> getArchiveOwnerWithFilter(long enterpriseId, Long deptId, String authServerId, String filter, Order order, Limit limit) {
        return privilegeDao.getWithFilter(enterpriseId, deptId, authServerId, filter, EnterpriseSecurityPrivilege.ROLE_ARCHIVE_MANAGER, order, limit);
    }

    @Override
    public void addArchiveOwner(long enterpriseId, long deptId, long enterpriseUserId,String appId) {
        EnterpriseUser user = enterpriseUserDao.get(enterpriseUserId, enterpriseId);
        if(user != null) {
        	
        	long accountId = enterpriseAccountService.getByEnterpriseApp(enterpriseId, appId).getAccountId();
			UserAccount userAccount = userAccountService.get(enterpriseUserId, accountId);
			DepartmentAccount departmentAccount =departmentAccountService.getByDeptIdAndAccountId(deptId, accountId);
         
            List<EnterpriseSecurityPrivilege> privilegeList=  privilegeDao.getIdByEnterpriseAndDepartmentAndRole(enterpriseId, deptId, EnterpriseSecurityPrivilege.ROLE_ARCHIVE_MANAGER);
            for(int i=0;i<privilegeList.size();i++){
                //首先删除原有的空间管理员
                teamspaceDeleteManager(userAccount,privilegeList.get(i),departmentAccount,appId);
            }
            
            privilegeDao.deleteByDeptAndRole(enterpriseId, deptId, EnterpriseSecurityPrivilege.ROLE_ARCHIVE_MANAGER);
            
            EnterpriseSecurityPrivilege privilege = new EnterpriseSecurityPrivilege();
            privilege.setId(enterpriseSecurityPrivilegeIdGenerator.getNextId());
            privilege.setEnterpriseId(enterpriseId);
            privilege.setDepartmentId(deptId);
            privilege.setRole(EnterpriseSecurityPrivilege.ROLE_ARCHIVE_MANAGER);
            privilege.setEnterpriseUserId(enterpriseUserId);
            privilegeDao.create(privilege);
      
            //添加新的管理员
            teamspaceAddManager(enterpriseUserId,enterpriseId,deptId,appId);
        }
    }

	@Override
	public void deleteArchiveOwner(long enterpriseId,long enterpriseUserId) {
		// TODO Auto-generated method stub
		privilegeDao.delete(enterpriseId,enterpriseUserId);
	}

	@Override
	public void delete(long id) {
		// TODO Auto-generated method stub
		
	}
	
	
	private void teamspaceAddManager(long enterpriseUserId,long enterpriseId,long deptId,String appId){
			long accountId = enterpriseAccountService.getByEnterpriseApp(enterpriseId, appId).getAccountId();
			UserAccount userAccount = userAccountService.get(enterpriseUserId, accountId);
			DepartmentAccount dbDeptAccount = deptAccountService.getByDeptIdAndAccountId(deptId, accountId);
			if(dbDeptAccount!=null){
				    RestTeamMember restTeamMember=new RestTeamMember();
				    restTeamMember.setId(userAccount.getCloudUserId()+"");
			        restTeamMember.setLoginName(userAccount.getName());
			        restTeamMember.setName(userAccount.getName());
			        restTeamMember.setType(RestTeamMember.TYPE_USER);
			        RestTeamMemberCreateRequest memberRequest=new RestTeamMemberCreateRequest();
			        memberRequest.setMember(restTeamMember);
			        memberRequest.setTeamRole(RestTeamMemberCreateRequest.ROLE_MANAGER);
			        memberRequest.setRole("auther");
			        teamSpaceService.addTeamSpaceMember(enterpriseId, appId,dbDeptAccount.getCloudUserId(), memberRequest);	
			}
		}
	  
	  
	  
	   
	   private void teamspaceDeleteManager(UserAccount userAccount,EnterpriseSecurityPrivilege enterpriseSecurityPrivilege,DepartmentAccount departmentAccount,String appId){
			teamSpaceService.deleteTeamSpaceMemberByCloudUserId(departmentAccount.getEnterpriseId(), appId, departmentAccount.getCloudUserId(), userAccount.getCloudUserId());
		}
}
