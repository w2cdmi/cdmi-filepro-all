package com.huawei.sharedrive.uam.accountuser.service.impl;

import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.accountuser.dao.UserAccountDao;
import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.service.UserAccountService;
import com.huawei.sharedrive.uam.authserver.dao.AuthServerDao;
import com.huawei.sharedrive.uam.enterprise.dao.SecurityRoleDao;
import com.huawei.sharedrive.uam.enterprise.domain.SecurityRole;
import com.huawei.sharedrive.uam.exception.InvalidParamterException;
import com.huawei.sharedrive.uam.oauth2.service.UserTokenCacheService;

import pw.cdmi.box.domain.Limit;
import pw.cdmi.common.domain.AppBasicConfig;
import pw.cdmi.common.domain.AuthServer;

@Service
public class UserAccountServiceImpl implements UserAccountService {
	private final static int SPACE_UNIT = 1024;

	public static final String AUTH_TYPE_LOCAL = "LocalAuth";

	@Autowired
	private UserAccountDao userAccountDao;

	@Autowired
	private AuthServerDao authServerDao;

	@Autowired
	private SecurityRoleDao securityDao;

	@Autowired
	private UserTokenCacheService userTokenCacheService;

	@Override
	public void create(UserAccount userAccount) {
		userAccountDao.create(userAccount);
	}

	@Override
	public void update(UserAccount userAccount) {
		userAccountDao.update(userAccount);

		if (userAccount.getStatus() == UserAccount.INT_STATUS_DISABLE) {
			userTokenCacheService.deleteUserToken(userAccount.getCloudUserId());
		}
	}

	@Override
	public UserAccount get(long userId, long accountId) {
		return userAccountDao.get(userId, accountId);
	}

	@Override
	public UserAccount getById(long id, long accountId) {
		return userAccountDao.getById(id, accountId);
	}

	@Override
	public UserAccount getByImAccount(String imAccount, long accountId) {
		return userAccountDao.getByImAccount(imAccount, accountId);
	}

	@Override
	public void bulidUserAccount(UserAccount userAccount, AppBasicConfig appBasicConfig) {
		final int UNLIMITED = -1;
		userAccount.setMaxVersions(appBasicConfig.getMaxFileVersions());
		userAccount.setRegionId(appBasicConfig.getUserDefaultRegion());
		if (null == appBasicConfig.getUserSpaceQuota() || appBasicConfig.getUserSpaceQuota() <= 0) {
			userAccount.setSpaceQuota(-1L);
		} else {
			userAccount.setSpaceQuota(appBasicConfig.getUserSpaceQuota() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT);
		}
		if(null==appBasicConfig.getVersionFileSize()||appBasicConfig.getVersionFileSize()<=0){
			userAccount.setVersionFileSize(-1L);
		}else{
			userAccount.setSpaceQuota(appBasicConfig.getVersionFileSize() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT);
		}
		if(appBasicConfig.getVersionFileType()!=null&&appBasicConfig.getVersionFileType().equals("")){
			userAccount.setVersionFileType(appBasicConfig.getVersionFileType());
		}
		if (appBasicConfig.isEnableTeamSpace()) {
			userAccount.setTeamSpaceFlag(0);
			userAccount.setTeamSpaceMaxNum(appBasicConfig.getMaxTeamSpaces());
			if (null == appBasicConfig.getTeamSpaceQuota() || appBasicConfig.getTeamSpaceQuota() <= 0) {
				userAccount.setTeamSpaceQuota(appBasicConfig.getTeamSpaceQuota());
			} else {
				userAccount
						.setTeamSpaceQuota(appBasicConfig.getTeamSpaceQuota() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT);
			}
		} else {
			userAccount.setTeamSpaceFlag(1);
			userAccount.setTeamSpaceMaxNum(UNLIMITED);
			userAccount.setTeamSpaceQuota(Long.valueOf(UNLIMITED));
		}
		userAccount.setUploadBandWidth(appBasicConfig.getUploadBandWidth());
		userAccount.setDownloadBandWidth(appBasicConfig.getDownloadBandWidth());
	}

	@Override
	public int getFilterdCount(long accountId, long enterpriseId, long userSource, String filter, Integer status) {

		return userAccountDao.getFilterdCount(accountId, enterpriseId, userSource, filter, status);
	}

	@Override
	public List<UserAccount> getFilterd(UserAccount userAccount, long userSource, Limit limit, String filter) {

		return userAccountDao.getFilterd(userAccount, userSource, limit, filter);
	}

	@Override
	public void updateStatus(UserAccount userAccount, String ids) {
		userAccountDao.updateStatus(userAccount, ids);

	}

	@Override
	public void updateRole(UserAccount userAccount, String ids) {
		checkSecurityIdRule(userAccount.getAccountId(), userAccount.getRoleId());
		userAccountDao.updateRole(userAccount, ids);

	}

	@Override
	public void delByUserAccountId(UserAccount userAccount) {

		userAccountDao.delByUserAccountId(userAccount);
	}

	@Override
	public UserAccount getBycloudUserAccountId(UserAccount userAccount) {
		return userAccountDao.getBycloudUserAccountId(userAccount);

	}

	@Override
	public void updateLoginTime(UserAccount userAccount) {
		userAccountDao.updateLoginTime(userAccount);

	}

	@Override
	public boolean isLocalAndFirstLogin(long accountId, long userId) {
		UserAccount accountUser = this.userAccountDao.get(userId, accountId);
		if (accountUser.getFirstLogin() == null || accountUser.getFirstLogin() == UserAccount.INT_STATUS_ENABLE) {
			AuthServer authServer = this.authServerDao.get(accountUser.getResourceType());
			if (null == authServer) {
				return false;
			}
			if (StringUtils.equals(authServer.getType(), AUTH_TYPE_LOCAL)) {
				return true;
			}
		}
		return false;
	}

	private void checkSecurityIdRule(long accountId, int secRoleId) {
		SecurityRole sr = new SecurityRole();
		sr.setAccountId(accountId);
		List<SecurityRole> listSecurityRole = securityDao.getFilterd(sr, null, null);
		if (secRoleId == -1 || secRoleId == 0) {
			return;
		}
		boolean isAllowed = false;
		for (SecurityRole s : listSecurityRole) {
			if (s.getId() == secRoleId) {
				isAllowed = true;
				break;
			}
		}
		if (!isAllowed) {
			throw new InvalidParamterException();
		}
	}

	@Override
	public void bulidUserAccountParam(UserAccount userAccount, AppBasicConfig appBasicConfig) {
		final int UNLIMITED = -1;
		userAccount.setRegionId(appBasicConfig.getUserDefaultRegion());
		if (userAccount.getSpaceQuota() !=null&&userAccount.getSpaceQuota() > 0) {
			long spaceQuota = userAccount.getSpaceQuota() == -1 ? -1
					: userAccount.getSpaceQuota() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT;
			userAccount.setSpaceQuota(spaceQuota);
		} else {
			if (null == appBasicConfig.getUserSpaceQuota() || appBasicConfig.getUserSpaceQuota() <= 0) {
				userAccount.setSpaceQuota(appBasicConfig.getUserSpaceQuota());
			} else {
				userAccount.setSpaceQuota(appBasicConfig.getUserSpaceQuota() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT);
			}
		}
		if (userAccount.getMaxVersions()==null||userAccount.getMaxVersions() <= 0) {
			userAccount.setMaxVersions(appBasicConfig.getMaxFileVersions());
		}
		if (userAccount.getTeamSpaceMaxNum()==null||userAccount.getTeamSpaceMaxNum() <= 0) {
			userAccount.setTeamSpaceMaxNum(appBasicConfig.getMaxTeamSpaces());
		}

		if (appBasicConfig.isEnableTeamSpace()) {
			userAccount.setTeamSpaceFlag(0);
			if (null == appBasicConfig.getTeamSpaceQuota() || appBasicConfig.getTeamSpaceQuota() <= 0) {
				userAccount.setTeamSpaceQuota(appBasicConfig.getTeamSpaceQuota());
			} else {
				userAccount
						.setTeamSpaceQuota(appBasicConfig.getTeamSpaceQuota() * SPACE_UNIT * SPACE_UNIT * SPACE_UNIT);
			}
		} else {
			userAccount.setTeamSpaceFlag(1);
			// userAccount.setTeamSpaceMaxNum(UNLIMITED);
			userAccount.setTeamSpaceQuota(Long.valueOf(UNLIMITED));
		}
		userAccount.setUploadBandWidth(appBasicConfig.getUploadBandWidth());
		userAccount.setDownloadBandWidth(appBasicConfig.getDownloadBandWidth());
	}

	@Override
	public void setNoneFirstLogin(long accountId, long userId) {
		UserAccount userAccount = new UserAccount();
		userAccount.setAccountId(accountId);
		userAccount.setUserId(userId);
		userAccount.setFirstLogin(UserAccount.STATUS_NONE_FIRST_LOGIN);
		userAccountDao.updateFirstLogin(userAccount);
	}


    @Override
    public void updateUserIdById(UserAccount userAccount) {
        userAccountDao.updateUserIdById(userAccount);
    }
}
