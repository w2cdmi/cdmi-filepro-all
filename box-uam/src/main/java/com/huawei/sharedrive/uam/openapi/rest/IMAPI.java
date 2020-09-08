package com.huawei.sharedrive.uam.openapi.rest;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import pw.cdmi.common.domain.enterprise.Enterprise;

import com.huawei.sharedrive.uam.enterprise.manager.EnterpriseManager;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseService;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.exception.BaseRunException;
import com.huawei.sharedrive.uam.exception.NoSuchUserException;
import com.huawei.sharedrive.uam.log.service.UserLogService;
import com.huawei.sharedrive.uam.oauth2.domain.UserToken;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.openapi.domain.RestIMAccountUserInfo;
import com.huawei.sharedrive.uam.openapi.manager.TokenMeApiManager;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;
import com.huawei.sharedrive.uam.plugin.Netease.domain.IMAccount;
import com.huawei.sharedrive.uam.plugin.Netease.service.IMAccountService;

@Controller
@RequestMapping(value = "/api/v2/im")
public class IMAPI {
	
	@Autowired
	IMAccountService iMtService;
	
	@Autowired
	private EnterpriseService enterpriseService;
	
	@Autowired
	private UserTokenHelper userTokenHelper;
	
	@Autowired
    private EnterpriseManager enterpriseManager;
	
	@Autowired
    private EnterpriseUserService enterpriseUserService;
	
	@Autowired
    private TokenMeApiManager tokenMeApiManager;
	
	@Autowired
    private UserLogService userLogService;
	
	@Autowired
	private DepartmentService departmentService;
    
    @RequestMapping(value = "/config", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<IMAccount> getImAccountConfig( @RequestHeader("Authorization") String authorization)
        throws Exception
    {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
        IMAccount imAccount= iMtService.get(userToken.getAccountId(),userToken.getCloudUserId());
        return new ResponseEntity<IMAccount>(imAccount, HttpStatus.OK);
        
    }
    
    @RequestMapping(value = "/syncImAccount", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> syncImAccount(@RequestHeader("Authorization") String authorization,@RequestParam(value = "icon", defaultValue = "") String icon)
        throws Exception
    {
    	try {
		  	UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
	        Enterprise enterpirse=enterpriseService.getById(userToken.getEnterpriseId());
			Map<String, Object> paramter=new HashMap<>();
			paramter.put("accountId", userToken.getAccountId());
			paramter.put("icon",icon);
			paramter.put("cloudUserId", userToken.getCloudUserId());
			paramter.put("accid",userToken.getCloudUserId()+"@"+ enterpirse.getDomainName());
			paramter.put("name",userToken.getName());
			paramter.put("token",userToken.getCloudUserId()+"@"+ enterpirse.getDomainName());
			paramter.put("enterpriseId",userToken.getEnterpriseId());
			paramter.put("userId", userToken.getId());
			iMtService.createIMAccount(paramter);
			IMAccount imAccount= iMtService.get(userToken.getAccountId(),userToken.getCloudUserId());
	        return new ResponseEntity<IMAccount>(imAccount, HttpStatus.OK);
		} catch (Exception e) {
			return new ResponseEntity<String>(e.getMessage(), HttpStatus.BAD_REQUEST);
		}
    }
    
    /**
     * 
     * @param id
     * @param model
     * @throws BaseRunException
     */
    @SuppressWarnings("unused")
	@RequestMapping(value = "/{imaccid}", method = RequestMethod.GET)
    public ResponseEntity<RestIMAccountUserInfo> getIMUser(@RequestHeader("Authorization") String authorization,
        @RequestHeader(value = "Date", required = false) String date, @PathVariable("imaccid") String imaccid,
        HttpServletRequest request) throws Exception
    {
        UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
        
        IMAccount imAccount = iMtService.getByIMaccid(imaccid);
        long id = imAccount.getUserId();
        
        if (imAccount == null) {
            throw new Exception("get imAccount info failed, imAccount is null");
        }
        //获取企业信息
        String appId = userToken.getAppId();
        long accountId = imAccount.getAccountId();
        long enterpriseId = imAccount.getEnterpriseId();
        Enterprise enterprise = enterpriseManager.getById(enterpriseId);
        if (enterprise == null) {
            throw new NoSuchUserException("get user info failed, enterprise is null");
        }
        String enterpriseName = enterprise.getName();
        //获取企业用户信息
        EnterpriseUser user = enterpriseUserService.get(id, enterpriseId);
        if(user == null) {
            throw new NoSuchUserException("get user info failed, enterprise is null");
        }
        
        String departmentName = "";
        if(user.getDepartmentId() != 0){
        	//获取部门信息
            Department department = departmentService.getDeptById(user.getDepartmentId());
            if(department == null){
            	throw new Exception("get department info failed, department is null");
            }
            departmentName = department.getName();
        }
        
        RestIMAccountUserInfo responseUser = RestIMAccountUserInfo.convetToResponseUser(user, enterpriseName, departmentName);
        
        return new ResponseEntity<RestIMAccountUserInfo>(responseUser, HttpStatus.OK);
    }
}
