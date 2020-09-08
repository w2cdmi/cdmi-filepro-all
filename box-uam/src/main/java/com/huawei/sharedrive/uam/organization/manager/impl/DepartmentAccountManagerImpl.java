package com.huawei.sharedrive.uam.organization.manager.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.huawei.sharedrive.uam.enterprise.domain.AccountBasicConfig;
import com.huawei.sharedrive.uam.enterprise.manager.AccountBasicConfigManager;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterpriseuser.manager.EnterpriseUserManager;
import com.huawei.sharedrive.uam.exception.AccountAuthFailedException;
import com.huawei.sharedrive.uam.exception.BusinessErrorCode;
import com.huawei.sharedrive.uam.exception.BusinessException;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.domain.DepartmentAccount;
import com.huawei.sharedrive.uam.organization.manager.DepartmentAccountManager;
import com.huawei.sharedrive.uam.organization.service.DepartmentAccountService;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;
import com.huawei.sharedrive.uam.system.service.AppBasicConfigService;
import com.huawei.sharedrive.uam.util.Constants;

import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageImpl;
import pw.cdmi.box.domain.PageRequest;
import pw.cdmi.common.domain.AppBasicConfig;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;

@Component
public class DepartmentAccountManagerImpl implements DepartmentAccountManager {
    private static final Logger LOGGER = LoggerFactory.getLogger(EnterpriseUserManager.class);

    @Autowired
    private EnterpriseAccountService enterpriseAccountService;

    @Autowired
    private AppBasicConfigService appBasicConfigService;

    @Autowired
    private AccountBasicConfigManager accountBasicConfigManager;

    @Autowired
    private DepartmentService departmentService;

    @Autowired
    private DepartmentAccountService deptAccountService;

    @Override
    public void create(String authAppId, long enterpriseId, long deptId, long cloudUserId) {
        Department dept = departmentService.getDeptById(deptId);
        if (null == dept) {
            LOGGER.error("[deptAccount] find department failed" + " deptId:" + deptId + " enterpriseId:" + enterpriseId);
            throw new BusinessException(BusinessErrorCode.INTERNAL_SERVER_ERROR, "find department failed");
        }

        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(enterpriseId, authAppId);
        if (null == enterpriseAccount) {
            LOGGER.error("[deptAccount] find enterpriseAccount failed" + " enterpriseId:" + enterpriseId + " authAppId:" + authAppId);
            throw new BusinessException(BusinessErrorCode.INTERNAL_SERVER_ERROR, "find enterpriseAccount failed");
        }

        if (Constants.STATUS_OF_ACCOUNT_ENABLE != enterpriseAccount.getStatus()) {
            LOGGER.error("enterpriseAccount status is disable, enterpriseId: " + enterpriseId + "authAppId: " + authAppId);
            throw new AccountAuthFailedException("enterpriseAccount status is disable");
        }

        DepartmentAccount dbDeptAccount = deptAccountService.getByDeptIdAndAccountId(deptId, enterpriseAccount.getAccountId());
        if (dbDeptAccount != null) {
            //已经存在
            return;
        }

        //
        DepartmentAccount deptAccount = new DepartmentAccount(enterpriseAccount.getAccountId(), enterpriseId, deptId);
        fillDeptAccountWithAppConfig(deptAccount, authAppId);
        deptAccount.setCloudUserId(cloudUserId);
        deptAccountService.create(deptAccount);
    }

    @Override
    public void update(DepartmentAccount deptAccount, String authAppId) {
        Department dept = departmentService.getDeptById(deptAccount.getDeptId());
        if (dept == null) {
            LOGGER.error("[deptAccount] find department failed" + " deptId:" + deptAccount.getDeptId() + " enterpriseId:" + deptAccount.getEnterpriseId());
            throw new BusinessException(BusinessErrorCode.INTERNAL_SERVER_ERROR, "find department failed");
        }

        EnterpriseAccount enterpriseAccount = enterpriseAccountService.getByEnterpriseApp(deptAccount.getEnterpriseId(), authAppId);
        if (null == enterpriseAccount) {
            LOGGER.error("[deptAccount] find enterpriseAccount failed" + " enterpriseId:" + deptAccount.getEnterpriseId() + " authAppId:" + authAppId);
            throw new BusinessException(BusinessErrorCode.INTERNAL_SERVER_ERROR, "find enterpriseAccount failed");
        }

        if (Constants.STATUS_OF_ACCOUNT_ENABLE != enterpriseAccount.getStatus()) {
            LOGGER.error("enterpriseAccount status is disable, enterpriseId: " + deptAccount.getEnterpriseId() + "authAppId: " + authAppId);
            throw new BusinessException(BusinessErrorCode.INTERNAL_SERVER_ERROR, "enterpriseAccount status disable");
        }
/*
        UserHttpClient userHttpClient = new UserHttpClient(ufmClientService);
        userHttpClient.updateUser(deptAccount, enterpriseUser, enterpriseAccount);
*/
        deptAccountService.update(deptAccount);
    }


    public void fillDeptAccountWithAppConfig(DepartmentAccount account, String authAppId) {
        AppBasicConfig appBasicConfig = appBasicConfigService.getAppBasicConfig(authAppId);
        if (null == appBasicConfig) {
            LOGGER.error("[deptAccount] find appBasicConfig failed" + " authAppId:" + authAppId);
            throw new BusinessException(BusinessErrorCode.NotFoundException, "find userAccount failed");
        }
        AccountBasicConfig accountBasicConfig = new AccountBasicConfig();
        accountBasicConfig.setAccountId(account.getAccountId());
        accountBasicConfig = accountBasicConfigManager.queryAccountBasicConfig(accountBasicConfig, authAppId);
        if (!accountBasicConfig.getUserSpaceQuota().equals("-1")) {
            appBasicConfig.setUserSpaceQuota(Long.parseLong(accountBasicConfig.getUserSpaceQuota()));
        }
        if (!accountBasicConfig.getUserVersions().equals("-1")) {
            appBasicConfig.setMaxFileVersions(Integer.parseInt(accountBasicConfig.getUserVersions()));
        }

        appBasicConfig.setEnableTeamSpace(accountBasicConfig.isEnableTeamSpace());

        if (!accountBasicConfig.getMaxTeamSpaces().equals("-1")) {
            appBasicConfig.setMaxTeamSpaces(Integer.parseInt(accountBasicConfig.getMaxTeamSpaces()));
        }
        if (!accountBasicConfig.getTeamSpaceQuota().equals("-1")) {
            appBasicConfig.setTeamSpaceQuota(Long.parseLong(accountBasicConfig.getTeamSpaceQuota()));
        }
        deptAccountService.buildDepartmentAccount(account, appBasicConfig);
    }

    @Override
    public void delete(long id) {
        deptAccountService.delete(id);
    }

    @Override
    public DepartmentAccount getByDeptIdAndAccountId(long deptId, long accountId) {
        return deptAccountService.getByDeptIdAndAccountId(deptId, accountId);
    }

    @Override
    public Page<DepartmentAccount> getPagedUserAccount(DepartmentAccount deptAccount, String appId, long authServerId, PageRequest pageRequest, String filter) {
        int total = deptAccountService.countFiltered(deptAccount.getAccountId(), deptAccount.getEnterpriseId(), authServerId, filter, deptAccount.getStatus());
        DepartmentAccount tmpUserAccount = new DepartmentAccount();
        tmpUserAccount.setEnterpriseId(deptAccount.getEnterpriseId());
        tmpUserAccount.setStatus(deptAccount.getStatus());
        tmpUserAccount.setAccountId(deptAccount.getAccountId());
        List<DepartmentAccount> content = deptAccountService.getFiltered(tmpUserAccount, authServerId, pageRequest.getLimit(), filter);

        return new PageImpl<>(content, pageRequest, total);
    }
}
