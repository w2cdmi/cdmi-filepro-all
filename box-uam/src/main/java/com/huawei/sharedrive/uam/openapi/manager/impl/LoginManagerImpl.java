package com.huawei.sharedrive.uam.openapi.manager.impl;

import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.service.UserAccountService;
import com.huawei.sharedrive.uam.authapp.manager.AuthAppNetRegionIpManager;
import com.huawei.sharedrive.uam.authserver.manager.AuthServerManager;
import com.huawei.sharedrive.uam.declare.manager.UserSignDeclareManager;
import com.huawei.sharedrive.uam.enterprise.domain.AccountConfigAttribute;
import com.huawei.sharedrive.uam.enterprise.manager.EnterpriseManager;
import com.huawei.sharedrive.uam.enterprise.service.AccountConfigService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.enterprisecontrol.EnterpriseAuthControlManager;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.enterpriseuseraccount.domain.EnterpriseUserAccount;
import com.huawei.sharedrive.uam.event.domain.EventType;
import com.huawei.sharedrive.uam.exception.*;
import com.huawei.sharedrive.uam.ldapauth.manager.LoginTerminalManager;
import com.huawei.sharedrive.uam.ldapauth.manager.impl.LoginUpdateManagerImpl;
import com.huawei.sharedrive.uam.log.domain.UserLogType;
import com.huawei.sharedrive.uam.log.service.UserLogService;
import com.huawei.sharedrive.uam.log.service.UserLoginLogService;
import com.huawei.sharedrive.uam.logininfo.domain.LoginInfo;
import com.huawei.sharedrive.uam.oauth2.domain.UserToken;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.openapi.domain.*;
import com.huawei.sharedrive.uam.openapi.manager.LoginManager;
import com.huawei.sharedrive.uam.system.domain.MailServer;
import com.huawei.sharedrive.uam.system.service.CustomizeLogoService;
import com.huawei.sharedrive.uam.system.service.MailServerService;
import com.huawei.sharedrive.uam.user.domain.UserLocked;
import com.huawei.sharedrive.uam.user.service.UserLockService;
import com.huawei.sharedrive.uam.user.service.UserService;
import com.huawei.sharedrive.uam.user.service.impl.UserServiceImpl;
import com.huawei.sharedrive.uam.util.Constants;
import com.huawei.sharedrive.uam.util.PasswordValidateUtil;
import com.huawei.sharedrive.uam.util.PropertiesUtils;
import com.huawei.sharedrive.uam.util.RequestUtils;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.domain.WxUser;
import com.huawei.sharedrive.uam.weixin.domain.WxUserEnterprise;
import com.huawei.sharedrive.uam.weixin.rest.WxMpUserInfo;
import com.huawei.sharedrive.uam.weixin.rest.WxUserInfo;
import com.huawei.sharedrive.uam.weixin.rest.WxWorkUserInfo;
import com.huawei.sharedrive.uam.weixin.service.*;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.HtmlUtils;
import pw.cdmi.common.cache.CacheClient;
import pw.cdmi.common.domain.*;
import pw.cdmi.common.domain.enterprise.Enterprise;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;
import pw.cdmi.common.log.UserLog;
import pw.cdmi.uam.domain.AuthApp;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class LoginManagerImpl implements LoginManager
{
    private static final String CLOUDAPP = "cloudapp";
    
    private static final int ONE_FAIL_TIME = 1;
    
    @Autowired
    private AuthAppNetRegionIpManager authAppNetRegionIpManager;
    
	@Autowired
	private MailServerService mailServerService;
	
	@Autowired
	private CustomizeLogoService customizeLogoService;
    
	@Autowired
	private AccountConfigService accountConfigService;
	    
    @Autowired
    private EnterpriseAuthControlManager enterpriseAuthControlManager;
    
	@Autowired
	private EnterpriseManager enterpriseManager;
    
    @Autowired
    private LoginUpdateManagerImpl loginUpdateManagerImpl;
    
    @Autowired
    private UserLockService userLockService;
    
    @Autowired
    private UserLogService userLogService;
    
    @Autowired
    private CacheClient cacheClient;
    
    @Autowired
    private UserLoginLogService userLoginLogService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserTokenHelper userTokenHelper;
    
    @Autowired
    private LoginTerminalManager loginTerminalManager;
    
    @Autowired
    private UserAccountService userAccountService;
    
    @Autowired
    private UserSignDeclareManager userSignDeclareManager;
    
    @Autowired
    private AuthServerManager authServerManager;
    
    @Autowired
    private EnterpriseUserService enterpriseUserService;
    
    @Autowired
    private EnterpriseAccountService enterpriseAccountService;

    @Autowired
    @Qualifier("wxWorkOauth2Service")
    WxWorkOauth2Service wxWorkOauth2Service;

    @Autowired
    WxOauth2Service wxOauth2Service;

    @Autowired
    private WxEnterpriseUserService wxEnterpriseUserService;

    @Autowired
    private WxUserService wxUserService;

    @Autowired
    private WxUserEnterpriseService wxUserEnterpriseService;

    private static final Logger LOGGER = LoggerFactory.getLogger(LoginManagerImpl.class);
    
    public static final int CLIENT_TYPE_ANDROID = 2;
    
    public static final String CLIENT_TYPE_ANDROID_STR = "android";
    
    public static final int CLIENT_TYPE_IOS = 3;
    
    public static final String CLIENT_TYPE_IOS_STR = "ios";
    
    public static final int CLIENT_TYPE_PC = 1;
    
    public static final String CLIENT_TYPE_PC_STR = "pc";
    
    public static final int CLIENT_TYPE_WEB = 0;
    
    public static final String CLIENT_TYPE_WEB_STR = "web";
    
    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public RestLoginResponse userLogin(HttpServletRequest request, RestUserLoginCreateRequest requestDomain, AuthApp authApp) throws IOException {
        String appId = requestDomain.getAppId();
        String loginName = requestDomain.getLoginName();
        String domainName = requestDomain.getDomain();
        UserLog userLog = UserLogType.getUserLog(request, appId, loginName, false);

        //优先使用domain登录，如果没有指定，再尝试使用企业名称
        if(StringUtils.isBlank(domainName)) {
            if(StringUtils.isNotBlank(requestDomain.getEnterpriseName())) {
                Enterprise enterprise = enterpriseManager.getByName(requestDomain.getEnterpriseName());
                if(enterprise != null) {
                    domainName = enterprise.getDomainName();
                }
            }
        }

        LoginInfo loginInfo = getLoginInfo(appId, loginName, domainName, request.getHeader("x-real-ip"), userLog);
        if (loginInfo == null) {
            throw new LoginAuthFailedException();
        }
        if (loginInfo.getUserId() != 0) {
            UserLocked tempLock = this.userLockService.getUserLockWithoutLock(appId, loginInfo.getUserId());
            userLockService.createUserLocked(loginInfo.getUserId(), loginName, domainName, appId, tempLock);
        }
        return loginWithLockTrans(request, requestDomain, userLog, loginInfo);
    }

    @Transactional(propagation = Propagation.REQUIRED, noRollbackFor = {UserLockedException.class, LoginAuthFailedException.class, NoSuchUserException.class})
    public RestLoginResponse loginWithLockTrans(HttpServletRequest request,
        RestUserLoginCreateRequest requestDomain, UserLog userLog, LoginInfo loginInfo) throws IOException
    {
        String appId = requestDomain.getAppId();
        String loginName = requestDomain.getLoginName();
        String domainName = requestDomain.getDomain();
        String password = requestDomain.getPassword();
        UserLocked userLocked = lockWithDbLock(appId, loginName, domainName, userLog, loginInfo);
        EnterpriseUser enterpriseUserByLdap = enterpriseAuthControlManager.authenticate(loginName,
            requestDomain.getPassword(),
            loginInfo,
            RequestUtils.getRealIP(request));
       
        if(StringUtils.isNotBlank(domainName)){
        	 Enterprise enterprise=enterpriseManager.getByDomainName(domainName);
             EnterpriseAccount  domainEn=enterpriseAccountService.getByEnterpriseApp(enterprise.getId(), appId);
             handleNoneLdap(userLog, loginInfo, userLocked, enterpriseUserByLdap,domainEn.getAccountId());
        }else{
        	 handleNoneLdap(userLog, loginInfo, userLocked, enterpriseUserByLdap,0);
        }
        
       
        EnterpriseUserAccount enterpriseUserAccount = getEnterpriseUserAccount(appId, enterpriseUserByLdap);
        UserToken userToken = new UserToken();
        
        UserToken.buildUserToken(userToken, enterpriseUserAccount);
        userToken.setAppId(appId);
        authAppNetRegionIpManager.setLoginMatchNetRegion(RequestUtils.getLoginRegionIp(request),
            appId,
            userToken);
        RestTerminalRsp lastAccessTerminal = loginTerminalManager.getByUserLastLogin(enterpriseUserAccount.getCloudUserId());
        userTokenHelper.createAndFillToken(userToken, enterpriseUserAccount, request);
      
        RestLoginResponse restLoginResponse = RestLoginResponse.fillRestLoginResponse(userToken);
        fillResetPwdAndDeclare(appId, userLog, userToken, restLoginResponse);
      //根据企业ID查找密码复杂度
        long enterpriseId = enterpriseUserByLdap.getEnterpriseId();
        String pwd_Level= enterpriseAccountService.getPwdLevelByEnterpriseId(enterpriseId);
        int pwdLevel = 1;
        HttpSession session = request.getSession();
        if(!StringUtils.isBlank(pwd_Level)){
        	pwdLevel = Integer.parseInt(pwd_Level);	
        }
        if (!PasswordValidateUtil.isValidPassword(password,pwdLevel))
        {
        	session.setAttribute("ChgPwd", true);
        	restLoginResponse.setPwdLevel(pwdLevel+"");
        }else{
        	session.setAttribute("ChgPwd", false);
        }
        Map<String, Long> bandWidthMap = userService.fillBandWidth(enterpriseUserAccount.getDownloadBandWidth(),
            enterpriseUserAccount.getUploadBandWidth(),
            appId);
        restLoginResponse.setUploadQos(bandWidthMap.get(UserServiceImpl.UPLOAD_BANDWIDTH));
        restLoginResponse.setDownloadQos(bandWidthMap.get(UserServiceImpl.DOWNLOAD_BANDWIDTH));
        userService.createEvent(userToken, EventType.USER_LOGIN, userToken.getId());
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_TOKEN, null);
        if (null != userLocked)
        {
            userLockService.deleteUserLocked(userLocked);
        }
        restLoginResponse.setEmail(userToken.getEmail());
        restLoginResponse.setLastAccessTerminal(lastAccessTerminal);
        restLoginResponse.setAlias(enterpriseUserByLdap.getAlias());
        restLoginResponse.setMobile(enterpriseUserByLdap.getMobile());
        restLoginResponse.setAppId(appId);
        restLoginResponse.setDomain(enterpriseManager.getById(enterpriseId).getDomainName());

        return restLoginResponse;
    }
    
    
    @Transactional(propagation = Propagation.REQUIRED, noRollbackFor = {UserLockedException.class, LoginAuthFailedException.class, NoSuchUserException.class})
    public RestLoginResponse loginWithPassword(HttpServletRequest request, RestRobotLoginRequest robotRequest, UserLog userLog, LoginInfo loginInfo) throws IOException
    {
        String appId = robotRequest.getAppId();
        long enterpriseUserId = robotRequest.getEnterpriseUserId();
        long enterpriseId = robotRequest.getEnterpriseId();
        EnterpriseUser enterpriseUser=enterpriseUserService.get(enterpriseUserId, enterpriseId);
        EnterpriseUserAccount enterpriseUserAccount = getEnterpriseUserAccount(appId, enterpriseUser);
        UserToken userToken = new UserToken();
        
        UserToken.buildUserToken(userToken, enterpriseUserAccount);
        userToken.setAppId(appId);
        authAppNetRegionIpManager.setLoginMatchNetRegion(RequestUtils.getLoginRegionIp(request),
            appId,
            userToken);
        RestTerminalRsp lastAccessTerminal = loginTerminalManager.getByUserLastLogin(enterpriseUserAccount.getCloudUserId());
        userTokenHelper.createAndFillToken(userToken, enterpriseUserAccount, request);
      
        RestLoginResponse restLoginResponse = RestLoginResponse.fillRestLoginResponse(userToken);
        fillResetPwdAndDeclare(appId, userLog, userToken, restLoginResponse);
      //根据企业ID查找密码复杂度
        Map<String, Long> bandWidthMap = userService.fillBandWidth(enterpriseUserAccount.getDownloadBandWidth(),
            enterpriseUserAccount.getUploadBandWidth(),
            appId);
        restLoginResponse.setUploadQos(bandWidthMap.get(UserServiceImpl.UPLOAD_BANDWIDTH));
        restLoginResponse.setDownloadQos(bandWidthMap.get(UserServiceImpl.DOWNLOAD_BANDWIDTH));
        userService.createEvent(userToken, EventType.USER_LOGIN, userToken.getId());
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_TOKEN, null);
        restLoginResponse.setEmail(userToken.getEmail());
        restLoginResponse.setLastAccessTerminal(lastAccessTerminal);
        restLoginResponse.setAlias(enterpriseUser.getAlias());
        restLoginResponse.setMobile(enterpriseUser.getMobile());
        restLoginResponse.setAppId(appId);
        restLoginResponse.setDomain(enterpriseManager.getById(enterpriseId).getDomainName());
        return restLoginResponse;
    }

    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public RestLoginResponse userLogin(HttpServletRequest request, RestWxUserLoginRequest login) throws IOException {
        WxUserInfo userInfo = wxOauth2Service.getWxUserInfo(login.getCode());
        if(userInfo == null) {
            LOGGER.error("Can't get UserInfo of code {}: return value is null", login.getCode());
            throw new LoginAuthFailedException("Failed to get UserInfo: return value is null.");
        }

        if(userInfo.hasError()) {
            LOGGER.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", login.getCode(), userInfo.getErrcode(), userInfo.getErrmsg());
            throw new LoginAuthFailedException("Can't get UserInfo of code.");
        }

        WxUser wxUser = wxUserService.getByUnionId(userInfo.getUnionid());
        String appId = login.getAppId();

        //用户不存在
        if(wxUser == null) {
            LOGGER.error("No such weixin user: unionId={}, openId={}", userInfo.getUnionid(), userInfo.getOpenid());
            throw new LoginAuthFailedException("No such weixin user.");
        }

        WxUserEnterprise wxUserEnterprise = null;
        //登录时指定了企业
        if(login.getEnterpriseId() != null) {
            wxUserEnterprise = wxUserEnterpriseService.getByUnionIdAndEnterpriseId(wxUser.getUnionId(), login.getEnterpriseId());
        } else {
            List<WxUserEnterprise> enterpriseList = wxUserEnterpriseService.listByUnionId(wxUser.getUnionId());

            if(enterpriseList.size() == 1) {
                wxUserEnterprise = enterpriseList.get(0);
            } else  if(enterpriseList.size() > 1) {
                //有多个企业账户，返回账户列表，让用户选择要登录的账户。
                EnterpriseInfo[] infoList = getEnterpriseInfoList(enterpriseList);

                RestWxLoginResponse response = new RestWxLoginResponse();
                response.setEnterpriseList(infoList);
                return response;
            }
        }

        if(wxUserEnterprise == null) {
            LOGGER.error("No account of weixin user: unionId={}, openId={}", userInfo.getUnionid(), userInfo.getOpenid());
            throw new LoginAuthFailedException("No such weixin user.");
        }

        //记录登录信息
        UserLog userLog = UserLogType.getUserLog(request, appId, wxUser.getNickName(), false);
        userLoginLogService.saveLog(userLog);

        EnterpriseUser user = enterpriseUserService.get(wxUserEnterprise.getEnterpriseUserId(), wxUserEnterprise.getEnterpriseId());
        if(user == null) {
            throw new LoginAuthFailedException("User doesn't exist, userId: " + wxUserEnterprise.getEnterpriseUserId() + "; enterpriseId: " + wxUserEnterprise.getEnterpriseId());
        }

        Enterprise enterprise = enterpriseManager.getById(wxUserEnterprise.getEnterpriseId());
        UserLocked tempLock = this.userLockService.getUserLockWithoutLock(appId, wxUserEnterprise.getEnterpriseUserId());
        userLockService.createUserLocked(wxUserEnterprise.getEnterpriseUserId(), user.getName(), enterprise.getDomainName(), appId, tempLock);

        //使用原有的异常传递机制：异常由GlobalExceptionHandler抓获，然后统一响应。使用HTTP STATUS使用403
        return loginWithLockTrans(request, appId, user, userLog);
    }

    protected EnterpriseInfo[] getEnterpriseInfoList(List<WxUserEnterprise> enterpriseList) {
        EnterpriseInfo[] infoList = new EnterpriseInfo[enterpriseList.size()];
        for(int i = 0; i < infoList.length; i++) {
            Enterprise enterprise = enterpriseManager.getById(enterpriseList.get(i).getEnterpriseId());
            infoList[i] = new EnterpriseInfo();
            infoList[i].setId(enterprise.getId());
            infoList[i].setName(enterprise.getName());
        }
        return infoList;
    }

    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public RestLoginResponse userLogin(HttpServletRequest request, RestWxworkUserLoginRequest login) throws IOException {
        String appId = login.getAppId();
        String corpId;
        String userId;

        //auth_code不为空，走第三方登录接口
        if(StringUtils.isNotBlank(login.getAuthCode())) {
            com.huawei.sharedrive.uam.weixin.rest.LoginInfo userInfo = wxWorkOauth2Service.getLoginInfo(login.getAuthCode());
            if(userInfo == null) {
                LOGGER.error("Failed to get user info from Weixin OAuth2 server: authCode={}, user=null", login.getAuthCode());
                throw new LoginAuthFailedException("Failed to get user info from Weixin OAuth2 server.");
            }

            if (userInfo.hasError()) {
                LOGGER.error("Failed to get user info from Weixin OAuth2 server: authCode={}, errorCode={}, errorMsg={}", login.getAuthCode(), userInfo.getErrcode(), userInfo.getErrmsg());
                throw new LoginAuthFailedException("Failed to get user info from Weixin OAuth2 server.");
            }

            // 根据corpId查询内部企业ID
            corpId = userInfo.getCorpInfo().getCorpid();
            userId = userInfo.getUserInfo().getUserid();
        } else {
            //从企业微信浏览器登录
            WxWorkUserInfo userInfo = wxWorkOauth2Service.getUserInfoByCode(login.getCorpId(), login.getCode());
            if(userInfo == null) {
                LOGGER.error("Failed to get user info from Weixin OAuth2 server: corpId={}, code={}, user=null", login.getCorpId(), login.getCode());
                throw new LoginAuthFailedException("Failed to get user info from Weixin OAuth2 server.");
            }

            if(userInfo.hasError()) {
                LOGGER.error("Failed to get user info from Weixin OAuth2 server: corpId={}, code={}, errorCode={}, errorMsg={}", login.getCorpId(), login.getCode(), userInfo.getErrcode(), userInfo.getErrmsg());
                throw new LoginAuthFailedException("Failed to get user info from Weixin OAuth2 server.");
            }

            corpId = login.getCorpId();
            userId = userInfo.getUserId();
        }

        WxEnterpriseUser wxUser = wxEnterpriseUserService.get(corpId, userId);
        if(wxUser == null) {
            LOGGER.error("WxEnterpriseUser doesn't exist: corpId={}, userId={}", corpId, userId);
            throw new LoginAuthFailedException("User doesn't exist, corpId: " + corpId + "; userId: " + userId);
        }

        //记录登录信息
        UserLog userLog = UserLogType.getUserLog(request, appId, wxUser.getName(), false);
        userLoginLogService.saveLog(userLog);

        if (wxUser.getBoxEnterpriseUserId() != 0) {
            UserLocked tempLock = this.userLockService.getUserLockWithoutLock(appId, wxUser.getBoxEnterpriseUserId());
            userLockService.createUserLocked(wxUser.getBoxEnterpriseUserId(), userId, corpId, appId, tempLock);
        }

        EnterpriseUser user = enterpriseUserService.get(wxUser.getBoxEnterpriseUserId(), wxUser.getBoxEnterpriseId());
        if(user == null) {
            LOGGER.error("WxEnterpriseUser doesn't exist: eneterpriseId={}, userId={}", wxUser.getBoxEnterpriseId(), wxUser.getBoxEnterpriseUserId());
            throw new LoginAuthFailedException("User doesn't exist, userId: " + wxUser.getBoxEnterpriseUserId() + "; enterpriseId: " + wxUser.getBoxEnterpriseId());
        }

        //使用原有的异常传递机制：异常由GlobalExceptionHandler抓获，然后统一响应。使用HTTP STATUS使用403
        return loginWithLockTrans(request, appId, user, userLog);
    }

    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public RestLoginResponse userLogin(HttpServletRequest request, RestWxMpUserLoginRequest login) throws IOException {
        WxMpUserInfo mpUserInfo = wxOauth2Service.getWxMpUserInfo(login.getCode(), login.getIv(), login.getEncryptedData());
        if(mpUserInfo == null) {
            LOGGER.error("WxMp login Failed: wxMpUserInfo is null.");
            throw new LoginAuthFailedException("Failed to get user info.");
        }

        if(mpUserInfo.hasError()) {
            LOGGER.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", login.getCode(), mpUserInfo.getErrcode(), mpUserInfo.getErrmsg());
            throw new LoginAuthFailedException("Failed to get user info.");
        }

        WxUser dbWxUser = wxUserService.getByUnionId(mpUserInfo.getUnionId());
        String appId = login.getAppId();

        //用户不存在，自动生成账户
        if(dbWxUser == null) {
            return new RestWxLoginResponse(GlobalErrorMessage.USER_NOT_EXIST);
        }

        WxUserEnterprise wxUserEnterprise = null;
        //登录时指定了企业
        if(login.getEnterpriseId() != null) {
            wxUserEnterprise = wxUserEnterpriseService.getByUnionIdAndEnterpriseId(dbWxUser.getUnionId(), login.getEnterpriseId());
        } else {
            List<WxUserEnterprise> enterpriseList = wxUserEnterpriseService.listByUnionId(dbWxUser.getUnionId());

            if(enterpriseList.size() == 1) {
                wxUserEnterprise = enterpriseList.get(0);
            } else  if(enterpriseList.size() > 1) {
                //有多个企业账户，返回账户列表，让用户选择要登录的账户。
                EnterpriseInfo[] infoList = getEnterpriseInfoList(enterpriseList);

                RestWxLoginResponse response = new RestWxLoginResponse(GlobalErrorMessage.TOO_MANY_ACCOUNT);
                response.setEnterpriseList(infoList);
                return response;
            }
        }

        //没有对应的企业账号
        if(wxUserEnterprise == null) {
            return new RestWxLoginResponse(GlobalErrorMessage.ACCOUNT_NOT_EXIST);
        }

        //记录登录信息
        UserLog userLog = UserLogType.getUserLog(request, appId, dbWxUser.getNickName(), false);
        userLoginLogService.saveLog(userLog);

        EnterpriseUser user = enterpriseUserService.get(wxUserEnterprise.getEnterpriseUserId(), wxUserEnterprise.getEnterpriseId());
        if(user == null) {
            return new RestWxLoginResponse(GlobalErrorMessage.ACCOUNT_NOT_EXIST);
        }

        Enterprise enterprise = enterpriseManager.getById(wxUserEnterprise.getEnterpriseId());
        UserLocked tempLock = this.userLockService.getUserLockWithoutLock(appId, wxUserEnterprise.getEnterpriseUserId());
        userLockService.createUserLocked(wxUserEnterprise.getEnterpriseUserId(), user.getName(), enterprise.getDomainName(), appId, tempLock);

        //小程序登录，使用了新的异常传递机制：所有的响应都使用200OK，错误码保存在响应数据中。此处捕获异常，然后重新封装。
        try {
            return loginWithLockTrans(request, appId, user, userLog);
        } catch (DisabledUserApiException e) {
            return new RestWxLoginResponse(GlobalErrorMessage.USER_DISABLED);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return new RestWxLoginResponse(GlobalErrorMessage.FAIL);
    }

    @Transactional(propagation = Propagation.REQUIRED, noRollbackFor = { UserLockedException.class, LoginAuthFailedException.class, NoSuchUserException.class })
    public RestLoginResponse loginWithLockTrans(HttpServletRequest request, String appId, EnterpriseUser user, UserLog userLog) throws IOException {
        //TODO：暂不考虑用户锁定问题

        //检查用户状态
        if(user.getStatus() != EnterpriseUser.STATUS_ENABLE) {
            throw new DisabledUserApiException();
        }

        EnterpriseUserAccount enterpriseUserAccount = getEnterpriseUserAccount(appId, user);
        UserToken userToken = new UserToken();

        UserToken.buildUserToken(userToken, enterpriseUserAccount);
        userToken.setAppId(appId);
        authAppNetRegionIpManager.setLoginMatchNetRegion(RequestUtils.getLoginRegionIp(request), appId, userToken);
        RestTerminalRsp lastAccessTerminal = loginTerminalManager.getByUserLastLogin(enterpriseUserAccount.getCloudUserId());
        userTokenHelper.createAndFillToken(userToken, enterpriseUserAccount, request);

        RestLoginResponse restLoginResponse = RestLoginResponse.fillRestLoginResponse(userToken);
//        fillResetPwdAndDeclare(appId, userLog, userToken, restLoginResponse);

        Enterprise enterprise = enterpriseManager.getById(user.getEnterpriseId());

        Map<String, Long> bandWidthMap = userService.fillBandWidth(enterpriseUserAccount.getDownloadBandWidth(), enterpriseUserAccount.getUploadBandWidth(), appId);
        restLoginResponse.setUploadQos(bandWidthMap.get(UserServiceImpl.UPLOAD_BANDWIDTH));
        restLoginResponse.setDownloadQos(bandWidthMap.get(UserServiceImpl.DOWNLOAD_BANDWIDTH));
        restLoginResponse.setDomain(enterprise.getDomainName());
        userService.createEvent(userToken, EventType.USER_LOGIN, userToken.getId());
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_TOKEN, null);

        restLoginResponse.setEmail(userToken.getEmail());
        restLoginResponse.setLastAccessTerminal(lastAccessTerminal);
        restLoginResponse.setAlias(user.getAlias());
        restLoginResponse.setMobile(user.getMobile());
        restLoginResponse.setAppId(appId);
        restLoginResponse.setDomain(enterprise.getDomainName());
        restLoginResponse.setEnterpriseName(enterprise.getName());

        return restLoginResponse;
    }

    @SuppressWarnings("PMD.ExcessiveParameterList")
    private UserLocked lockWithDbLock(String appId, String loginName, String domainName, UserLog userLog,
        LoginInfo loginInfo)
    {
        UserLocked userLocked = null;
        if (loginInfo.getUserId() != 0)
        {
            userLocked = userLockService.checkUserLocked(userLog, loginInfo.getUserId(), domainName, appId);
            if (null == userLocked)
            {
                return null;
            }
            if (userLockService.isLocked(userLocked))
            {
                String msg = "user has been locked from " + userLocked.getLockedAt() + ", userloginname is "
                    + loginName;
                userLogService.saveFailLog(userLog, UserLogType.KEY_GET_TOKEN_ERR, null);
                throw new UserLockedException(msg);
            }
        }
        return userLocked;
    }
    
    @SuppressWarnings("PMD.PreserveStackTrace")
    private LoginInfo getLoginInfo(String appId, String loginName, String domainName, String clientIp,
        UserLog userLog)
    {
        LoginInfo loginInfo = null;
        try
        {
            userLoginLogService.saveLog(userLog);
            loginInfo = enterpriseAuthControlManager.getUserLoginInfo(loginName, domainName, appId);
        }
        catch (NoSuchUserException e)// 匿名用户
        {
            ManagerLocked managerLocked = (ManagerLocked) cacheClient.getCache(CLOUDAPP + loginName
                + domainName + appId);
            LOGGER.error("Cloudapp anonymous user:" + loginName + " fail to login at " + clientIp);
            if (null == managerLocked)
            {
                ManagerLocked newManagerLocked = new ManagerLocked();
                newManagerLocked.setCreatedAt(new Date());
                newManagerLocked.setLoginFailTimes(ONE_FAIL_TIME);
                newManagerLocked.setLoginName(loginName);
                cacheClient.setCache(CLOUDAPP + loginName + domainName + appId,
                    newManagerLocked,
                    userLockService.getConfigByLockWait());
            }
            else
            {
                managerLocked.setLoginFailTimes(managerLocked.getLoginFailTimes() + ONE_FAIL_TIME);
                cacheClient.replaceCache(CLOUDAPP + loginName + domainName + appId,
                    managerLocked,
                    userLockService.getConfigByLockWait());
                
                
                if (managerLocked.getLoginFailTimes() >= userLockService.getConfigByLockTimes())
                {
                    String msg = "Cloudapp anonymous user:" + loginName + " has been locked at " + clientIp;
                    LOGGER.error(msg);
                    throw new UserLockedException(msg);
                }
            }
            throw new LoginAuthFailedException();
        }
        catch (RuntimeException e)
        {
            userLogService.saveFailLog(userLog, UserLogType.KEY_GET_TOKEN_ERR, null);
            throw e;
        }
        return loginInfo;
    }
    
    private void handleNoneLdap(LoginInfo loginInfo, UserLocked userLocked, UserLog userLog,long accountId)
    {
        EnterpriseUser enterpriseUser = enterpriseUserService.get(loginInfo.getUserId(),
            loginInfo.getEnterpriseId());
        AuthServer authServer = authServerManager.getAuthServer(enterpriseUser.getUserSource());
        if (AuthServer.AUTH_TYPE_AD.equalsIgnoreCase(authServer.getType()))
        {
            throw new LoginAuthFailedException("AD", "AD user login failed");
        }
        if (null != userLocked)
        {
        	
            boolean locked = userLockService.addUserLocked(userLocked,accountId);
            try {
            	if(accountId!=0){
            		AccountConfig notice_enable = accountConfigService.get(accountId, AccountConfigAttribute.SECURITY_LOGINFAIL_NOTICE_ENABLE.getName());
        	    	AccountConfig lock_time = accountConfigService.get(accountId, AccountConfigAttribute.SECURITY_LOGINFAIL_LOCK_TIME.getName());
        	        AccountConfig lockTimes = accountConfigService.get(accountId, AccountConfigAttribute.SECURITY_LOGINFAIL_TRY_TIMES.getName());
        	        AccountConfig mail_enable = accountConfigService.get(accountId, AccountConfigAttribute.MAIL_STMP_ENABLE.getName());
        	        
        	        if(notice_enable!=null&&notice_enable.getValue().endsWith("true")){
        	           if(userLocked.getLoginFailTimes()+1 == Integer.parseInt(lockTimes.getValue())){
        	        	   sendEmail(enterpriseUser);
        	        	   if(mail_enable.equals("true")){
        	        		   sendMailByAccount(enterpriseUser,accountId);
        	        	   }
        	           }
        	        }
        	        
            	}
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
            if (locked)
            {
            	
                userLogService.saveUserLog(userLog, UserLogType.KEY_LOCK_USER, null);
                throw new UserLockedException("user is locked");
            }
        }
    }
    
    private void sendEmail(EnterpriseUser enterpriseUser) throws IOException {
		MailServer mailServer = mailServerService.getDefaultMailServer();
		if (mailServer == null) {
			throw new BusinessException();
		}

		Enterprise enterprise = enterpriseManager.getById(enterpriseUser.getEnterpriseId());
		String domainNm = enterprise.getDomainName();

		// added by Jeffrey for new requirements
		CustomizeLogo customizeLogo = customizeLogoService.getCustomize();
		String link = "";
		if (customizeLogo != null && StringUtils.isNotBlank(customizeLogo.getDomainName())) {
			link = customizeLogo.getDomainName();
		}

		Map<String, Object> messageModel = new HashMap<String, Object>(2);
		messageModel.put("loginname", HtmlUtils.htmlEscape(enterpriseUser.getName()).replaceAll(" ", "&nbsp;"));
		messageModel.put("password", HtmlUtils.htmlEscape(enterpriseUser.getPassword()));
		messageModel.put("name", HtmlUtils.htmlEscape(enterpriseUser.getAlias()).replaceAll(" ", "&nbsp;"));
		messageModel.put("domainName", HtmlUtils.htmlEscape(domainNm).replaceAll(" ", "&nbsp;"));
		messageModel.put("LoginAddress", HtmlUtils.htmlEscape(link).replaceAll(" ", "&nbsp;"));
		String msg = mailServerService.getEmailMsgByTemplate(Constants.OPEN_ACCOUNT_CONTENT, messageModel);
		String subject = mailServerService.getEmailMsgByTemplate(Constants.OPEN_ACCOUNT_SUBJECT,
				new HashMap<String, Object>(1));
		mailServerService.sendHtmlMail(enterpriseUser.getName(), mailServer.getId(), enterpriseUser.getEmail(), null,
				null, subject, msg);
	}
    
    private void sendMailByAccount(EnterpriseUser enterpriseUser,long accountId)throws IOException{

		MailServer mailServer = mailServerService.getByAccountId(accountId);
		if (mailServer == null) {
			throw new BusinessException();
		}

		Enterprise enterprise = enterpriseManager.getById(enterpriseUser.getEnterpriseId());
		String domainNm = enterprise.getDomainName();

		// added by Jeffrey for new requirements
		CustomizeLogo customizeLogo = customizeLogoService.getCustomize();
		String link = "";
		if (customizeLogo != null && StringUtils.isNotBlank(customizeLogo.getDomainName())) {
			link = customizeLogo.getDomainName();
		}

		Map<String, Object> messageModel = new HashMap<String, Object>(2);
		messageModel.put("loginname", HtmlUtils.htmlEscape(enterpriseUser.getName()).replaceAll(" ", "&nbsp;"));
		messageModel.put("password", HtmlUtils.htmlEscape(enterpriseUser.getPassword()));
		messageModel.put("name", HtmlUtils.htmlEscape(enterpriseUser.getAlias()).replaceAll(" ", "&nbsp;"));
		messageModel.put("domainName", HtmlUtils.htmlEscape(domainNm).replaceAll(" ", "&nbsp;"));
		messageModel.put("LoginAddress", HtmlUtils.htmlEscape(link).replaceAll(" ", "&nbsp;"));
		String msg = mailServerService.getEmailMsgByTemplate(Constants.OPEN_ACCOUNT_CONTENT, messageModel);
		String subject = mailServerService.getEmailMsgByTemplate(Constants.OPEN_ACCOUNT_SUBJECT,
				new HashMap<String, Object>(1));
		mailServerService.sendHtmlMail(enterpriseUser.getName(), mailServer.getId(), enterpriseUser.getEmail(), null,
				null, subject, msg);
	
    }
    
    private void handleNoneLdap(UserLog userLog, LoginInfo loginInfo, UserLocked userLocked,
        EnterpriseUser enterpriseUserByLdap,long accountId)
    {
        if (null == enterpriseUserByLdap)
        {
            userLogService.saveFailLog(userLog, UserLogType.KEY_GET_TOKEN_ERR, null);
            if (loginInfo.getUserId() != 0)
            {
                handleNoneLdap(loginInfo, userLocked, userLog,accountId);
               throw new LoginAuthFailedException("Local", "Local user login failed");
            }
            throw new LoginAuthFailedException("AD", "AD user login failed");
        }
    }
    
    private void fillResetPwdAndDeclare(String appId, UserLog userLog, UserToken userToken,
        RestLoginResponse restLoginResponse)
    {
        boolean needChangePassword = userAccountService.isLocalAndFirstLogin(userToken.getAccountId(),
            userToken.getId());
        UserSignDeclare declare = new UserSignDeclare();
        declare.setAccountId(userToken.getAccountId());
        declare.setCloudUserId(userToken.getCloudUserId());
        declare.setClientType(getClietType(userLog.getClientType()));
        boolean needDeclaration = userSignDeclareManager.isNeedDeclaration(declare, appId);
        userToken.setNeedChangePassword(needChangePassword && needChangePwdFromConfig());
        userToken.setNeedDeclaration(needDeclaration);
        restLoginResponse.setNeedDeclaration(needDeclaration);
        restLoginResponse.setNeedChangePassword(needChangePassword && needChangePwdFromConfig());
    }
    
    private boolean needChangePwdFromConfig() {
        return PropertiesUtils.getProperty("user.local.firstlogin.changepwd", "true").equalsIgnoreCase("true");
    }
    
    private EnterpriseUserAccount getEnterpriseUserAccount(String appId, EnterpriseUser enterpriseUserByLdap)
        throws IOException
    {
        EnterpriseUserAccount enterpriseUserAccount = loginUpdateManagerImpl.save(enterpriseUserByLdap.getUserSource(),
            enterpriseUserByLdap.getObjectSid(),
            enterpriseUserByLdap.getEnterpriseId(),
            appId,
            enterpriseUserByLdap);
        if (enterpriseUserAccount.getAccountStatus() == UserAccount.INT_STATUS_DISABLE)
        {
            String msg = "account user status disabled accountid:" + enterpriseUserAccount.getAccountId()
                + " id:" + enterpriseUserAccount.getId();
            userLogService.saveFailLog(enterpriseUserAccount.getName(),
                appId,
                null,
                UserLogType.KEY_GET_TOKEN_ERR);
            throw new LoginAuthFailedException(msg);
        }
        return enterpriseUserAccount;
    }
    
    private String getClietType(int index)
    {
        Map<Integer, String> map = new HashMap<Integer, String>(4);
        map.put(CLIENT_TYPE_WEB, CLIENT_TYPE_WEB_STR);
        map.put(CLIENT_TYPE_PC, CLIENT_TYPE_PC_STR);
        map.put(CLIENT_TYPE_IOS, CLIENT_TYPE_IOS_STR);
        map.put(CLIENT_TYPE_ANDROID, CLIENT_TYPE_ANDROID_STR);
        return map.get(index);
    }

	@Override
	public RestLoginResponse robotLogin(HttpServletRequest request, RestRobotLoginRequest requestDomain, AuthApp authApp)
			throws IOException {

        String appId = requestDomain.getAppId();
        String loginName = requestDomain.getLoginName();
        String domainName = requestDomain.getDomain();
        UserLog userLog = UserLogType.getUserLog(request, appId, loginName, false);
        LoginInfo loginInfo = getLoginInfo(appId, loginName, domainName, request.getHeader("x-real-ip"), userLog);
        if (loginInfo == null) {
            throw new LoginAuthFailedException();
        }
        if (loginInfo.getUserId() != 0) {
            UserLocked tempLock = this.userLockService.getUserLockWithoutLock(appId, loginInfo.getUserId());
            userLockService.createUserLocked(loginInfo.getUserId(), loginName, domainName, appId, tempLock);
        }
        return loginWithPassword(request, requestDomain, userLog, loginInfo);
    
	}
    
}
