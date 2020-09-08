package com.huawei.sharedrive.uam.enterpriseuser.service;

import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseSecurityPrivilege;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import pw.cdmi.box.domain.Limit;
import pw.cdmi.box.domain.Order;

import java.util.List;

public interface EnterpriseSecurityPrivilegeService {
    long create(EnterpriseSecurityPrivilege privilege);

    void update(EnterpriseSecurityPrivilege privilege);

    void delete(long id);

    void deleteBy(long enterpriseId);

    void deleteBy(long enterpriseId, long departmentId);

    void deleteBy(long enterpriseId, long departmentId, byte role);

    EnterpriseUser getInfoSecurityManager(long enterpriseId);

    void setInfoSecurityManager(long enterpriseId, long enterpriseUserId);

    int countArchiveOwnerCountWithFilter(long enterpriseId, Long deptId, String authServerId, String filter);

    List<EnterpriseUser> getArchiveOwnerWithFilter(long enterpriseId, Long deptId, String authServerId, String filter, Order order, Limit limit);

    void addArchiveOwner(long enterpriseId, long deptId, long enterpriseUserId, String appId);

	void deleteArchiveOwner(long enterpriseId,long enterpriseUserId);
}
