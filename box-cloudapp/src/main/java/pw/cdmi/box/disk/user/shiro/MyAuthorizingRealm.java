package pw.cdmi.box.disk.user.shiro;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.annotation.PostConstruct;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.LockedAccountException;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.authc.credential.HashedCredentialsMatcher;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.codec.Hex;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.PrincipalCollection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import pw.cdmi.box.disk.authapp.service.AuthAppService;
import pw.cdmi.box.disk.authserver.service.AuthServerService;
import pw.cdmi.box.disk.enterprisecontrol.EnterpriseAuthControlManager;
import pw.cdmi.box.disk.enterprisecontrol.impl.EnterpriseAuthControlManagerImpl;
import pw.cdmi.box.disk.event.domain.EventType;
import pw.cdmi.box.disk.httpclient.rest.request.RestLoginResponse;
import pw.cdmi.box.disk.httpclient.rest.request.UserLoginRequest;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.user.domain.EnterpriseUser;
import pw.cdmi.box.disk.user.domain.Terminal;
import pw.cdmi.box.disk.user.domain.User;
import pw.cdmi.box.disk.user.service.UserLoginService;
import pw.cdmi.box.disk.user.service.UserService;
import pw.cdmi.common.domain.AuthServer;
import pw.cdmi.core.exception.ADLoginAuthFailedException;
import pw.cdmi.core.exception.DisabledUserApiException;
import pw.cdmi.core.exception.LdapLoginAuthFailedException;
import pw.cdmi.core.exception.SecurityMartixException;
import pw.cdmi.core.exception.UserLockedException;

public class MyAuthorizingRealm extends AuthorizingRealm {

	private static String algorithm = "SHA-256";

	private static Logger logger = LoggerFactory.getLogger(MyAuthorizingRealm.class);

	private static final int INITIAL_SIZE = 10;

	private String realmName;

	private UserLoginService userLoginService;

	private UserService userService;

	private AuthAppService authAppService;

	private EnterpriseAuthControlManager enterpriseAuthControlManager;

	private AuthServerService authServerService;

	public AuthServerService getAuthServerService() {
		return authServerService;
	}

	public void setAuthServerService(AuthServerService authServerService) {
		this.authServerService = authServerService;
	}

	public MyAuthorizingRealm() {
		setRealmName(getName());
	}

	public String getRealmName() {
		return realmName;
	}

	private void setRealmName(String realName) {
		realmName = realName;
	}

	@PostConstruct
	public void initCredentialsMatcher() {
		HashedCredentialsMatcher matcher = new HashedCredentialsMatcher(algorithm);
		setCredentialsMatcher(matcher);
	}

	public void setEnterpriseAuthControlManager(EnterpriseAuthControlManager enterpriseAuthControlManager) {
		this.enterpriseAuthControlManager = enterpriseAuthControlManager;
	}

	public void setUserLoginService(UserLoginService userLoginService) {
		this.userLoginService = userLoginService;
	}

	public void setUserService(UserService userService) {
		this.userService = userService;
	}

	public AuthAppService getAuthAppService() {
		return authAppService;
	}

	public void setAuthAppService(AuthAppService authAppService) {
		this.authAppService = authAppService;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (null == obj) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		AuthServer authServer = (AuthServer) obj;
		if (!AuthServer.AUTH_TYPE_LOCAL.equals(authServer.getType())) {
			return false;
		}
		return true;
	}

	@Override
	public int hashCode() {
		long result = 17;
		result = 17 * result + AuthServer.AUTH_TYPE_LOCAL.hashCode();
		if (result > Integer.MAX_VALUE) {
			return (int) (result % Integer.MAX_VALUE);
		}
		return (int) result;
	}

	@Override
	protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authcToken)
			throws AuthenticationException {
		UsernamePasswordCaptchaToken token = (UsernamePasswordCaptchaToken) authcToken;
		String loginName = token.getUsername();
		String password = new String(token.getPassword());
		String deviceAgent = token.getDeviceAgent();
		String deviceOS = token.getDeviceOS();
		String deviceAddress = token.getDeviceAddress();
		String authToken = token.getToken();
		String refreshToken = token.getRefreshToken();
		long enterpriseId = token.getEnterpriseId();
		long accountId = token.getAccountId();
		Date expire = token.getExpired();

		checkPrincipalValid(token, loginName, password);

		UserToken userToken = new UserToken();
		userToken.setDeviceType(Terminal.CLIENT_TYPE_WEB);
		userToken.setDeviceOS(deviceOS);
		userToken.setDeviceAgent(deviceAgent);
		userToken.setDeviceAddress(deviceAddress);
		try {
			if (!token.isNtlm()) {
				String appId = authAppService.getCurrentAppId();
				Map<String, String> map = enterpriseAuthControlManager.getWebDomainLoginName(loginName);
				String selName = map.get(EnterpriseAuthControlManagerImpl.LOGIN_NAME_KEY);
				String domainName="";
				if(token.getOwnerDomain()!=null&&!token.getOwnerDomain().equals("")){
					domainName=token.getOwnerDomain();
				}else{
					domainName = map.get(EnterpriseAuthControlManagerImpl.DOMAIN_NAME_KEY);	
				}
				
				SecurityUtils.getSubject().getSession().setAttribute("tag", true);

				UserLoginRequest userLoginRequest = new UserLoginRequest();
				userLoginRequest.setAppId(appId);
				userLoginRequest.setLoginName(selName);
				userLoginRequest.setPassword(password);
				userLoginRequest.setDomain(domainName);

				RestLoginResponse restLoginResponse = userLoginService.checkFormUser(userLoginRequest, userToken,
						token.getRegionIp());
				// 密码级别提高，强制修改密码
				if (restLoginResponse.isNeedChangePassword()) {
					userToken.setNeedChangePassword(true);
					userToken.setPwdLevel(restLoginResponse.getPwdLevel());
					SecurityUtils.getSubject().getSession().setAttribute("isNeedChangePassword","true");
				}
				transRestLoginResponse(userToken, restLoginResponse);
				authToken = restLoginResponse.getToken();
				refreshToken = restLoginResponse.getRefreshToken();
				expire = new Date(System.currentTimeMillis() + restLoginResponse.getTimeout() * 1000L);
				EnterpriseUser user = userService.getEnterpriseUserByUserId(userToken.getAccountId(),
						userToken.getId());
				userToken.setName(user.getAlias());
				userToken.setMobile(user.getMobile());
				initLastLoginInfo(restLoginResponse);
			} else {
				userService.getUserTokenBydb(userToken, loginName, enterpriseId, accountId);
			}
			userToken.setToken(authToken);
			userToken.setExpiredAt(expire);
		} catch (UserLockedException e) {
			logger.debug("user locked.", e);
			throw new LockedAccountException(e.getMsg(), e);
		} catch (DisabledUserApiException e) {
			logger.debug("user disabled.", e);
			throw new IncorrectCredentialsException("user disabled.", e);
		} catch (SecurityMartixException e) {
			logger.debug("Security fails, the SecurityMartix deny the request.", e);
			throw new SecurityMartixException("Security fails, the SecurityMartix deny the request.", e);
		} catch (LdapLoginAuthFailedException e) {
			logger.error("AD user authentication fails, the user name or password is incorrect.", e);

			throw new ADLoginAuthFailedException(e);
		} catch (Exception e) {
			logger.error("Authentication fails, the user name or password is incorrect.", e);
			throw new IncorrectCredentialsException("Authentication fails, the user name or password is incorrect.", e);
		}
		if (StringUtils.isBlank(password)) {
			try {
				userToken.setPassword(digest("".getBytes("utf8"), algorithm));
			} catch (UnsupportedEncodingException e) {
				logger.error("UnsupportedEncodingException:", e);
			}
		} else {
			try {
				userToken.setPassword(digest(password.getBytes("utf8"), algorithm));
			} catch (UnsupportedEncodingException e) {
				logger.error("UnsupportedEncodingException:", e);
			}
		}
		if (!token.isNtlm()) {
			renewSession();
		}
		SecurityUtils.getSubject().getSession().setAttribute(User.SESSION_ID_KEY, userToken.getId());
		SecurityUtils.getSubject().getSession().setAttribute("platToken", authToken);
		SecurityUtils.getSubject().getSession().setAttribute("platRefrshToken", refreshToken);
		SecurityUtils.getSubject().getSession().setAttribute("expiredTokenTime", expire);
		SecurityUtils.getSubject().getSession().setAttribute("accountId", userToken.getAccountId());
		SecurityUtils.getSubject().getSession().setAttribute("deviceAddress", deviceAddress);
		EnterpriseUser enterpriseUser = userService.getEnterpriseUserByUserId(userToken.getAccountId(),
				userToken.getId());
		AuthServer authServer = authServerService.getAuthServer(enterpriseUser.getUserSource());
		SecurityUtils.getSubject().getSession().setAttribute("isLocalAuth",
				AuthServer.AUTH_TYPE_LOCAL.equals(authServer.getType()));
		SecurityUtils.getSubject().getSession().setAttribute("loadTag", true);
		userService.createEvent(userToken, EventType.USER_LOGIN, userToken.getId());
		logger.info("[loginLog] end login  ");
		return new SimpleAuthenticationInfo(userToken, userToken.getPassword().toCharArray(), getName());
	}

	private void initLastLoginInfo(RestLoginResponse restLoginResponse) {
		if (null == restLoginResponse.getLastAccessTerminal()) {
			return;
		}
		if (null == restLoginResponse.getLastAccessTerminal().getLastAccessIP()) {
			return;
		}
		if (null == restLoginResponse.getLastAccessTerminal().getLastAccessAt()) {
			return;
		}
		if (null == restLoginResponse.getLastAccessTerminal().getDeviceType()) {
			return;
		}
		SecurityUtils.getSubject().getSession().setAttribute("lastLoginTime",
				restLoginResponse.getLastAccessTerminal().getLastAccessAt());
		SecurityUtils.getSubject().getSession().setAttribute("lastLoginIP",
				restLoginResponse.getLastAccessTerminal().getLastAccessIP());
		SecurityUtils.getSubject().getSession().setAttribute("terminalType",
				restLoginResponse.getLastAccessTerminal().getDeviceType());
	}

	private void checkPrincipalValid(UsernamePasswordCaptchaToken token, String loginName, String password) {
		if (StringUtils.isBlank(loginName) || (StringUtils.isBlank(password) && !token.isNtlm())) {
			logger.error("Null usernames are not allowed by this realm.");
			throw new UnknownAccountException("Null usernames are not allowed by this realm.");
		}
		if (loginName.length() > 255 || (!token.isNtlm() && password.length() > 127)) {
			logger.error("username or password out of range.");
			throw new UnknownAccountException("Null usernames are not allowed by this realm.");
		}
	}

	@Override
	protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
		Object obj = principals.fromRealm(getName()).iterator().next();
		if (obj == null) {
			return null;
		}
		SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();

		info.addRole("user");
		return info;
	}

	/**
	 * 
	 * @param input
	 * @param algorithm
	 * @return
	 */
	private String digest(byte[] input, String algorithm) {
		try {
			MessageDigest digest = MessageDigest.getInstance(algorithm);
			byte[] result = digest.digest(input);
			return Hex.encodeToString(result);
		} catch (GeneralSecurityException e) {
			logger.error("Error in digest password!", e);
			return null;
		}
	}

	private void transRestLoginResponse(UserToken userToken, RestLoginResponse restLoginResponse) {
		userToken.setLoginName(restLoginResponse.getLoginName());
		userToken.setCloudUserId(restLoginResponse.getCloudUserId());
		userToken.setEnterpriseId(restLoginResponse.getEnterpriseId());
		userToken.setAccountId(restLoginResponse.getAccountId());
		userToken.setName(restLoginResponse.getLoginName());
		userToken.setId(restLoginResponse.getUserId());
		userToken.setType(restLoginResponse.getType());
		userToken.setStaffLevel(restLoginResponse.getStaffLevel());
	}

	private void renewSession() {
		Session sessionOld = SecurityUtils.getSubject().getSession(false);
		if (sessionOld != null) {
			Map<Object, Object> tmp = new HashMap<Object, Object>(INITIAL_SIZE);
			for (Object key : sessionOld.getAttributeKeys()) {
				tmp.put(key, sessionOld.getAttribute(key));
			}
			SecurityUtils.getSubject().logout();
			Session sessionNew = SecurityUtils.getSubject().getSession(true);
			for (Entry<Object, Object> entry : tmp.entrySet()) {
				sessionNew.setAttribute(entry.getKey(), entry.getValue());
			}
		}
	}
}
