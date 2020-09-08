package com.huawei.sharedrive.uam.organization.manager;

import com.huawei.sharedrive.uam.organization.domain.DepartmentAccount;
import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageRequest;

public interface DepartmentAccountManager {
    void create(String authAppId, long enterpriseId, long deptId, long cloudUserId) ;

    void update(DepartmentAccount deptAccount, String authAppId) ;

    void delete(long id);

    DepartmentAccount getByDeptIdAndAccountId(long deptId, long accountId);

    Page<DepartmentAccount> getPagedUserAccount(DepartmentAccount deptAccount, String appId, long authServerId, PageRequest pageRequest, String filter);

/*
    boolean createUserAccount(EnterpriseUser user, String authAppId, UserAccount account);

    DepartmentAccount getUserAccountByApp(long userId, long enterpriseId, String authAppId);

    DepartmentAccount getById(long id, long enterpriseId, String authAppId);

    void fillUserAccountParamByApp(UserAccount userAccount, String authAppId);

    DepartmentAccount get(long userId, long accountId);


    void deleteUserAccount(long userId, long accountId);

    boolean update(RestUserUpdateRequest ruser, UserAccount selUserAccount);

    String exportUserList(HttpServletRequest request, HttpServletResponse response, UserAccount userAccount) throws IOException;

    void updateLoginTime(UserAccount userAccount);
*/

}
