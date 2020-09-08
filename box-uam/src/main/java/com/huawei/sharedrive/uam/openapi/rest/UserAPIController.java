package com.huawei.sharedrive.uam.openapi.rest;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import pw.cdmi.common.domain.AuthServer;
import pw.cdmi.common.domain.enterprise.Enterprise;
import pw.cdmi.common.log.UserLog;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.huawei.sharedrive.uam.accountuser.domain.UserAccount;
import com.huawei.sharedrive.uam.accountuser.service.UserAccountService;
import com.huawei.sharedrive.uam.authserver.manager.AuthServerManager;
import com.huawei.sharedrive.uam.enterprise.manager.EnterpriseManager;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.enterpriseuseraccount.domain.EnterpriseUserAccount;
import com.huawei.sharedrive.uam.exception.BaseRunException;
import com.huawei.sharedrive.uam.exception.ForbiddenException;
import com.huawei.sharedrive.uam.exception.InvalidParamterException;
import com.huawei.sharedrive.uam.exception.NoSuchUserException;
import com.huawei.sharedrive.uam.log.domain.UserLogType;
import com.huawei.sharedrive.uam.log.service.UserLogService;
import com.huawei.sharedrive.uam.oauth2.domain.UserToken;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.openapi.domain.BasicUserUpdateRequest;
import com.huawei.sharedrive.uam.openapi.domain.RestListDeptAndUserRequest;
import com.huawei.sharedrive.uam.openapi.domain.user.RequestCreateLdapUser;
import com.huawei.sharedrive.uam.openapi.domain.user.RequestSearchUser;
import com.huawei.sharedrive.uam.openapi.domain.user.ResponseSearchUser;
import com.huawei.sharedrive.uam.openapi.domain.user.ResponseUser;
import com.huawei.sharedrive.uam.openapi.domain.user.TokenMeResponseUser;
import com.huawei.sharedrive.uam.openapi.manager.TokenMeApiCheckManager;
import com.huawei.sharedrive.uam.openapi.manager.TokenMeApiManager;
import com.huawei.sharedrive.uam.openapi.manager.TokenMeSearchManager;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.domain.DeptNode;
import com.huawei.sharedrive.uam.organization.manager.DepartmentManager;
import com.huawei.sharedrive.uam.user.domain.User;
import com.huawei.sharedrive.uam.user.service.UserParameterCheck;
import com.huawei.sharedrive.uam.uservip.domian.UserVip;
import com.huawei.sharedrive.uam.uservip.service.UserVipService;
import com.huawei.sharedrive.uam.util.PropertiesUtils;

@Controller
@RequestMapping(value = "/api/v2/users")
public class UserAPIController
{
    private static Logger logger = LoggerFactory.getLogger(UserAPIController.class);
    
    public static final String AUTH_TYPE_LDAP = "LdapAuth";
    
    public static final String AUTH_TYPE_AD = "AdAuth";
    
    public static final String AUTH_TYPE_LOCAL = "LocalAuth";
    
    @Autowired
    private UserTokenHelper userTokenHelper;
    
    @Autowired
    private UserParameterCheck userParameterCheck;
    
    @Autowired
    private UserLogService userLogService;
    
    @Autowired
    private TokenMeApiCheckManager tokenMeApiCheckManager;
    
    @Autowired
    private TokenMeSearchManager tokenMeSearchManager;
    
    @Autowired
    private TokenMeApiManager tokenMeApiManager;
    
    @Autowired
    private EnterpriseManager enterpriseManager;
    
    @Autowired
    private UserAccountService userAccountService;
    
    @Autowired
    private DepartmentManager departmentManager;
    
    @Autowired
    private EnterpriseUserService enterpriseUserService;
    
    @Autowired
    private UserVipService userVipService;
    
    @Autowired 
    private AuthServerManager authServerManager;
    
    private ObjectMapper objectMapper = null;
    
    private JsonGenerator jsonGenerator = null;
    
    /**
     * 
     * @return
     * @throws BaseRunException
     * @throws IOException
     */
    @RequestMapping(value = "/ldapuser", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<ResponseUser> createLdapuser(@RequestHeader("Authorization") String authorization,
        @RequestBody RequestCreateLdapUser createRequest) throws BaseRunException, IOException
    {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
        String loginName = createRequest.getLoginName();
        if (StringUtils.isBlank(loginName) || loginName.length() >= User.LOGINNAME_LENGTH)
        {
            userLogService.saveFailLog(loginName,
                userToken.getAppId(),
                null,
                UserLogType.KEY_CREATE_LDAP_USER_ERR);
            throw new InvalidParamterException();
        }
        EnterpriseUserAccount enterpriseUserAccount = tokenMeApiManager.createLdapUser(loginName,
            userToken.getAppId(),
            userToken.getEnterpriseId(),
            userToken.getAccountId());
        ResponseUser restTokenCreateResponse = ResponseUser.convetToResponseUser(enterpriseUserAccount,
            userToken.getAppId());
        Enterprise tempEnterprise = enterpriseManager.getById(userToken.getEnterpriseId());
        Enterprise enterprise = null;
        if (tempEnterprise != null)
        {
            enterprise = tempEnterprise;
            restTokenCreateResponse.setDomain(enterprise.getDomainName());
        }
        restTokenCreateResponse.setSpaceUsed(null);
        restTokenCreateResponse.setFileCount(null);
        UserLog userLog = UserLogType.getUserLog(userToken);
        userLogService.saveUserLog(userLog, UserLogType.KEY_CREATE_LDAP_USER, null);
        return new ResponseEntity<ResponseUser>(restTokenCreateResponse, HttpStatus.CREATED);
    }
    
    
    @RequestMapping(value = "/getUsersByDepId", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<List<ResponseUser>> getUsersByDepId(@RequestHeader("Authorization") String authorization,
        @RequestBody String depId) throws BaseRunException, IOException
    {
		UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
		long enterpriseId = userToken.getEnterpriseId();
		long deptId = Long.parseLong(depId.substring(1,depId.length()-1));
		AuthServer authServer = authServerManager.enterpriseTypeCheck(enterpriseId, "LocalAuth");
    	if(authServer==null){
    		throw new InvalidParamterException();
    	}
    	long authServerId = authServer.getId();
        List<ResponseUser> users = new ArrayList<>();
        List<Long> deptIds = new ArrayList<>();
        getAllDeptIds(deptIds,deptId,enterpriseId);
        deptIds.add(deptId);
        for (Long long1 : deptIds) {
        	List<EnterpriseUser> filterd = enterpriseUserService.getFilterd(null, authServerId, long1,enterpriseId, null, null);
        	if (filterd!=null) {
        		for (EnterpriseUser enterpriseUser : filterd) {
        			UserAccount userAccount = userAccountService.get(enterpriseUser.getId(), userToken.getAccountId());
        			if (userAccount!=null) {
        				ResponseUser responseUser = ResponseUser.convetToResponseUser(enterpriseUser,userAccount);
        				users.add(responseUser);
					}
        		}
			}
		}
        
        return new ResponseEntity<List<ResponseUser>>(users,HttpStatus.OK);
    }
    
    
    
    @RequestMapping(value = "/getDepMamagerCloudUserId", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Long> getDepMamagerCloudUserId(@RequestHeader("Authorization") String authorization) throws BaseRunException, IOException
    {
		UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
		try {
			long enterpriseId = userToken.getEnterpriseId();
			EnterpriseUser user =enterpriseUserService.get(userToken.getId(), enterpriseId);
			EnterpriseUser deptManager =enterpriseUserService.getDeptManager(enterpriseId,user.getDepartmentId());
			UserAccount userAccount=userAccountService.get(deptManager.getId(), userToken.getAccountId());
	        return new ResponseEntity<Long>(userAccount.getCloudUserId(),HttpStatus.OK);
		} catch (Exception e) {
			// TODO: handle exception
			   return new ResponseEntity<Long>(0L,HttpStatus.OK);
		}
	
    }
    
    
    @RequestMapping(value = "/listDept", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> listDept(@RequestHeader("Authorization") String authorization) throws BaseRunException, IOException
    {
    	UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
//    	List<DeptNode> allByEnterpriseId = departmentManager.getAllByEnterpriseId(userToken.getEnterpriseId(),userToken.getAccountId());
    	List<DeptNode> allByEnterpriseId = departmentManager.getRootDepartment(userToken.getEnterpriseId());
    	String result = "";
    	try {
    		objectMapper = new ObjectMapper();
    		jsonGenerator = objectMapper.getJsonFactory().createJsonGenerator(System.out, JsonEncoding.UTF8);
    		jsonGenerator.writeObject(allByEnterpriseId);
    		result = objectMapper.writeValueAsString(allByEnterpriseId);
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    	return new ResponseEntity<String>(result, HttpStatus.OK);
    }
    
    @RequestMapping(value = "/listDepAndUsers", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<String> listDeptAndUserByDeptId(@RequestHeader("Authorization") String authorization,
    		@RequestBody RestListDeptAndUserRequest request) throws BaseRunException, IOException
    {
    	UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
    	long enterpriseId = userToken.getEnterpriseId();
        long deptId = request.getDeptId();
    	List<Department> depts = departmentManager.listDepByParentDepId(deptId, enterpriseId);
    	AuthServer authServer = authServerManager.enterpriseTypeCheck(enterpriseId, "LocalAuth");
    	List<EnterpriseUser> bydepId=null;
    	if(authServer!=null){
            bydepId = enterpriseUserService.getFilterd(null, authServer.getId(), deptId, enterpriseId, null, null);
    	}
    	String result = "";
    	if (bydepId!=null) {
    		List<DeptNode> list = new ArrayList<>();
    		if (depts!=null) {
    			for (Department dept : depts) {
    				DeptNode mj = new DeptNode();
    				mj.setId(String.valueOf(dept.getId()));
    				mj.setpId(String.valueOf(dept.getParentid()));
    				mj.setName(dept.getName());
    				mj.setType("department");
    				list.add(mj);
    			}
			}
    		for (EnterpriseUser enterpriseUser : bydepId) {
    			UserAccount userAccount = userAccountService.get(enterpriseUser.getId(), userToken.getAccountId());
    			if (userAccount!=null) {
    				ResponseUser responseUser = ResponseUser.convetToResponseUser(enterpriseUser,userAccount);
    				DeptNode mj = new DeptNode();
    				mj.setId(String.valueOf(responseUser.getCloudUserId()));
    				mj.setUserId(String.valueOf(responseUser.getId()));
    				mj.setpId(String.valueOf(deptId));
    				mj.setName(enterpriseUser.getName());
    				mj.setEmail(enterpriseUser.getEmail());
  					mj.setAlias(enterpriseUser.getAlias());
    				mj.setType("user");
    				mj.setIsParent(false);
    				list.add(mj);
    			}
    			
    		}
        	try {
        		objectMapper = new ObjectMapper();
        		jsonGenerator = objectMapper.getJsonFactory().createJsonGenerator(System.out, JsonEncoding.UTF8);
        		jsonGenerator.writeObject(list);
        		result = objectMapper.writeValueAsString(list);
        	} catch (Exception e) {
        		e.printStackTrace();
        	}
		}
    	
    	return new ResponseEntity<String>(result, HttpStatus.OK);
    }
    
    /**
     * 
     * @param id
     * @param model
     * @throws BaseRunException
     */
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    public ResponseEntity<ResponseUser> getUserInfo(@RequestHeader("Authorization") String authorization,
        @RequestHeader(value = "Date", required = false) String date, @PathVariable("id") Long id,
        HttpServletRequest request) throws BaseRunException
    {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
        
        String appId = userToken.getAppId();
        long accountId = userToken.getAccountId();
        long enterpriseId = userToken.getEnterpriseId();
        Enterprise enterprise = enterpriseManager.getById(enterpriseId);
        if (enterprise == null) {
            throw new NoSuchUserException("get user info failed, enterprise is null");
        }

        EnterpriseUser user = enterpriseUserService.get(id, enterpriseId);
        if(user == null) {
            throw new NoSuchUserException("get user info failed, enterprise is null");
        }

//        Department department = departmentManager.getDeptById(enterpriseId, user.getDepartmentId());

        String[] para = {id + ""};
        EnterpriseUserAccount enterpriseUserAccount = tokenMeApiManager.getUserInfo(id, accountId, enterpriseId);
        if (enterpriseUserAccount == null) {
            UserLog userLog = UserLogType.getUserLog(request, appId, "", false);
            userLogService.saveFailLog(userLog, UserLogType.KEY_GET_ME_TOKEN_ERR, para);
            throw new NoSuchUserException("get user info failed, user is null");
        }
        UserLog userLog = UserLogType.getUserLog(userToken);
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_ME_TOKEN, para);
        ResponseUser responseUser = ResponseUser.convetToResponseUser(enterpriseUserAccount, appId);
        return new ResponseEntity<ResponseUser>(responseUser, HttpStatus.OK);
        
    }
    
    /**
     * 
     * @param userId
     * @return
     * @throws BaseRunException
     */
    @RequestMapping(value = "/me", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<TokenMeResponseUser> checkToken(@RequestHeader String authorization)
        throws BaseRunException
    {
        UserToken userToken;
        UserLog userLog = null;
        TokenMeResponseUser tokenMeResponseUser = null;
        try
        {
            userToken = userTokenHelper.unSafeCheckTokenAndGetUser(authorization);
            userLog = UserLogType.getUserLog(userToken);
            tokenMeResponseUser = TokenMeResponseUser.convetToResponseUser(userToken);
        }
        catch (RuntimeException e)
        {
            userLogService.saveUserLog(userLog, UserLogType.KEY_GET_UER_INFOMATION_ERR, null);
            throw e;
        }
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_UER_INFOMATION, null);
        return new ResponseEntity<TokenMeResponseUser>(tokenMeResponseUser, HttpStatus.OK);
    }
    
    /**
     * 
     * @param userId
     * @return offset
     * @throws BaseRunException
     */
    @RequestMapping(value = "/search", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<ResponseSearchUser> search(@RequestHeader String authorization,
        @RequestBody RequestSearchUser searchRequest) throws BaseRunException
    {
        UserToken userToken;
        ResponseSearchUser responseSearchUser = null;
        UserLog userLog = null;
        try
        {
            tokenMeApiCheckManager.checkSearchUserParameter(searchRequest);
            userToken = userTokenHelper.checkTokenAndGetUser(authorization);
            userLog = UserLogType.getUserLog(userToken);
            String seatchType = searchRequest.getType();
            String appId = userToken.getAppId();
            String filter = searchRequest.getKeyword();
            Integer limit = searchRequest.getLimit();
            Integer offset = searchRequest.getOffset();
            long accountId = userToken.getAccountId();
            long enterpriseId = userToken.getEnterpriseId();
            if (RequestSearchUser.TYPE_AD_USER.equals(seatchType))
            {
                ResponseSearchUser searchUser = tokenMeSearchManager.listADUser(appId,
                    filter,
                    limit,
                    accountId,
                    enterpriseId);
                if (searchUser != null)
                {
                    responseSearchUser = searchUser;
                    responseSearchUser.setOffset(null);
                    responseSearchUser.setTotalCount(null);
                }
            }
            if (RequestSearchUser.TYPE_AUTO.equals(seatchType))
            {
                ResponseSearchUser searchUser = tokenMeSearchManager.listADLocalUser(appId,
                    filter,
                    limit,
                    accountId,
                    enterpriseId);
                if (searchUser != null)
                {
                    responseSearchUser = searchUser;
                    responseSearchUser.setOffset(null);
                    responseSearchUser.setTotalCount(null);
                }
            }
            if (RequestSearchUser.TYPE_SYSTEM.equals(seatchType))
            {
                ResponseSearchUser searchUser = tokenMeSearchManager.listLocalUser(limit,
                    offset,
                    filter,
                    accountId,
                    enterpriseId,
                    appId);
                if (searchUser != null)
                {
                    responseSearchUser = searchUser;
                }
            }
        }
        catch (RuntimeException e)
        {
            userLogService.saveUserLog(userLog, UserLogType.KEY_LIST_USER_ERR, null);
            throw e;
        }
        
        userLogService.saveUserLog(userLog, UserLogType.KEY_LIST_USER, null);
        return new ResponseEntity<ResponseSearchUser>(responseSearchUser, HttpStatus.OK);
        
    }
    
    @RequestMapping(value = "/{userId}", method = RequestMethod.PUT)
    @ResponseBody
    public ResponseEntity<ResponseUser> updateUser(@PathVariable long userId,
        @RequestHeader("Authorization") String authorization,
        @RequestHeader(value = "Date", required = false) String date,
        @RequestBody BasicUserUpdateRequest ruser) throws BaseRunException
    {
        String appId = "";
        UserToken userToken = null;
        long accountId = 0;
        long enterpriseId = 0;
        ResponseUser responseUser;
        try
        {
            if (StringUtils.isNotBlank(ruser.getNewPassword())
                && StringUtils.isNotBlank(ruser.getOldPassword())
                && !ruser.getNewPassword().equals(ruser.getOldPassword()))
            {
                userToken = userTokenHelper.unSafeCheckTokenAndGetUser(authorization);
            }
            else
            {
                userToken = userTokenHelper.checkTokenAndGetUser(authorization);
            }
            appId = userToken.getAppId();
            enterpriseId = userToken.getEnterpriseId();
            accountId = userToken.getAccountId();
            checkUserUpdateParam(userId, ruser, userToken, appId);
            
            responseUser = doUpdateUser(userId,
                authorization,
                ruser,
                appId,
                userToken,
                accountId,
                enterpriseId);
            responseUser.setSpaceUsed(null);
            responseUser.setFileCount(null);
        }
        catch (RuntimeException e)
        {
            if (null != userToken)
            {
                UserLog userLog = UserLogType.getUserLog(userToken);
                userLogService.saveFailLog(userLog,
                    userToken.getLoginName(),
                    appId,
                    new String[]{String.valueOf(userId)},
                    UserLogType.KEY_UPDATE_TOKEN_USER_ERR);
                
            }
            throw e;
        }
        catch (Exception e)
        {
            userLogService.saveFailLog(null,
                null,
                appId,
                new String[]{String.valueOf(userId)},
                UserLogType.KEY_UPDATE_TOKEN_USER_ERR);
            
            throw e;
        }
        userLogService.saveFailLog(null,
            null,
            appId,
            new String[]{String.valueOf(userId)},
            UserLogType.KEY_UPDATE_TOKEN_USER);
        return new ResponseEntity<ResponseUser>(responseUser, HttpStatus.OK);
    }
    
    @SuppressWarnings("PMD.ExcessiveParameterList")
    private ResponseUser doUpdateUser(long userId, String authorization,
        BasicUserUpdateRequest userUpdateRequest, String appId, UserToken userToken, long accountId,
        long enterpriseId)
    {
        EnterpriseUserAccount enterpriseUserAccount;
        ResponseUser responseUser;
        enterpriseUserAccount = tokenMeApiManager.updateEnterpriseUser(authorization,
            userId,
            enterpriseId,
            accountId,
            userUpdateRequest);
        responseUser = ResponseUser.convetToResponseUser(enterpriseUserAccount, appId);
        saveUpdateUserLog(userToken, enterpriseUserAccount, responseUser, appId, userId, null);
        if (StringUtils.isNotBlank(userUpdateRequest.getNewPassword())
            && StringUtils.isNotBlank(userUpdateRequest.getOldPassword())
            && !userUpdateRequest.getNewPassword().equals(userUpdateRequest.getOldPassword()))
        {
            userAccountService.setNoneFirstLogin(accountId, userId);
        }
        boolean needChangePassword = userAccountService.isLocalAndFirstLogin(userToken.getAccountId(),
            userToken.getId());
        if (!needChangePassword || !needChangePwdFromConfig())
        {
            userTokenHelper.updateTokenCache(authorization);
        }
        return responseUser;
    }
    
    private void checkUserUpdateParam(long userId, BasicUserUpdateRequest ruser, UserToken userToken,
        String appId)
    {
        if (userId != userToken.getId())
        {
            throw new ForbiddenException("The current user:" + userToken.getId()
                + " cannot modify other user:" + userId);
        }
        
        userParameterCheck.checkUpdateUserParament(ruser, appId);
    }
    
    @SuppressWarnings("PMD.ExcessiveParameterList")
    private void saveUpdateUserLog(UserToken userToken, EnterpriseUserAccount enterpriseUserAccount,
        ResponseUser responseUser, String appId, long userId, String[] akArr)
    {
        if (null != userToken)
        {
            if (!UserAccount.STATUS_DISABLE.equals(responseUser.getStatus()))
            {
                UserToken.buildUserToken(userToken, enterpriseUserAccount);
                userTokenHelper.saveUserInfo(userToken);
            }
            try
            {
                UserLog userLog = UserLogType.getUserLog(userToken);
                userLogService.saveUserLog(userLog,
                    UserLogType.KEY_UPDATE_TOKEN_USER,
                    new String[]{String.valueOf(userId)});
            }
            catch (Exception e)
            {
                logger.info("Fail to record logger", e);
            }
        }
        else
        {
            try
            {
                UserLog userLog = UserLogType.getUserLog(null);
                userLog.setAppId(appId);
                if (null != akArr && akArr.length >= 2)
                {
                    userLog.setKeyword(akArr[1]);
                    userLog.setLoginName(akArr[1]);
                }
                userLogService.saveUserLog(userLog,
                    UserLogType.KEY_UPDATE_APP_USER,
                    new String[]{String.valueOf(userId)});
            }
            catch (Exception e)
            {
                logger.info("Fail to record logger", e);
            }
        }
    }
    
    private boolean needChangePwdFromConfig()
    {
        String value = PropertiesUtils.getProperty("user.local.firstlogin.changepwd", "true");
        if (null == value)
        {
            return true;
        }
        if ("false".equalsIgnoreCase(value))
        {
            return false;
        }
        return true;
    }
    
    private void getAllDeptIds(List<Long> deptIds,long deptId,long enterpriseId){
    	 List<Department> listDepByParentDepId = departmentManager.listDepByParentDepId(deptId,enterpriseId);
    	 if(listDepByParentDepId.size()!=0){
    		 for (Department department : listDepByParentDepId) {
    			 long id = department.getId();
    			 deptIds.add(id);
    			 getAllDeptIds(deptIds,id,enterpriseId);
			}
    	 }
    }

    @RequestMapping(value = "/checkOrgIsEnabled", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> checkOrgEnabledOrNot(@RequestHeader("Authorization") String authorization) throws BaseRunException, IOException
    {
    	String result="";
    	UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
    	long enterpriseId = userToken.getEnterpriseId();
    	try {
    		result = String.valueOf(enterpriseManager.checkOrganizeEnabled(enterpriseId));
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    	return new ResponseEntity<String>(result, HttpStatus.OK);
    }

    @RequestMapping(value = "/getUserByImAccount", method = RequestMethod.POST)
    public ResponseEntity<ResponseUser> getUserInfoByImAccount(@RequestHeader("Authorization") String authorization, @RequestBody String imAccount) throws BaseRunException {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);

        String appId = userToken.getAppId();
        long accountId = userToken.getAccountId();
        long enterpriseId = userToken.getEnterpriseId();
        String[] para = { imAccount + "" };
        UserLog userLog = UserLogType.getUserLog(userToken);
        EnterpriseUserAccount enterpriseUserAccount = tokenMeApiManager.getUserInfoByImAccount(imAccount, accountId, enterpriseId);
        if (null == enterpriseUserAccount) {
            userLogService.saveFailLog(userLog, UserLogType.KEY_GET_ME_TOKEN_ERR, para);
            throw new NoSuchUserException("get userinfo failed,user is null");
        }
        userLogService.saveUserLog(userLog, UserLogType.KEY_GET_ACCOUNT_ATTR, para);
        ResponseUser responseUser = ResponseUser.convetToResponseUser(enterpriseUserAccount, appId);

        return new ResponseEntity<>(responseUser, HttpStatus.OK);
    }
    
    @RequestMapping(value = "/getUserVipInfo", method = RequestMethod.GET)
    public ResponseEntity<UserVip> getUserVipInfo(@RequestHeader("Authorization") String authorization) throws BaseRunException {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);

        long enterpriseId = userToken.getEnterpriseId();
        long userId = userToken.getId();
        long accountId = userToken.getAccountId();
        long cloudUserId = userToken.getCloudUserId();
        
        UserVip userVipParam = new UserVip();
        userVipParam.setEnterpriseId(enterpriseId);
        userVipParam.setEnterpriseUserId(userId);
        userVipParam.setEnterpriseAccountId(accountId);
        userVipParam.setCloudUserId(cloudUserId);
        UserVip userVip = userVipService.get(userVipParam);

        return new ResponseEntity<>(userVip, HttpStatus.OK);
    }
}
