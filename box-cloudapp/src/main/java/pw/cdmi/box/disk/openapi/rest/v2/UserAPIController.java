package pw.cdmi.box.disk.openapi.rest.v2;

import java.util.Date;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import pw.cdmi.box.disk.authapp.service.AuthAppService;
import pw.cdmi.box.disk.client.domain.user.RestUserV2loginRsp;
import pw.cdmi.box.disk.client.utils.Constants;
import pw.cdmi.box.disk.event.domain.EventType;
import pw.cdmi.box.disk.httpclient.rest.request.RestLoginResponse;
import pw.cdmi.box.disk.httpclient.rest.request.UserApiLoginRequest;
import pw.cdmi.box.disk.httpclient.rest.request.UserLoginRequest;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.openapi.rest.v2.manager.UserApiCheckManager;
import pw.cdmi.box.disk.user.service.UserLoginService;
import pw.cdmi.box.disk.user.service.UserService;
import pw.cdmi.box.disk.user.service.impl.UserServiceImpl;
import pw.cdmi.box.disk.utils.RequestUtils;
import pw.cdmi.core.exception.BaseRunException;

@Controller
@RequestMapping(value = "/api/v2/login")
public class UserAPIController
{
    @Autowired
    private UserLoginService userLoginService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private AuthAppService authAppService;
    
    @Autowired
    private UserApiCheckManager userApiCheckManager;
    
    /**
     * login
     * 
     * @param userlogin
     * @return
     * @throws BaseRunException
     */
    @RequestMapping(value = "", method = RequestMethod.POST)
    public ResponseEntity<RestUserV2loginRsp> userLoginByPost(@RequestBody UserApiLoginRequest userlogin,
        HttpServletRequest request) throws BaseRunException
    {
        userApiCheckManager.checkV2LoginParam(userlogin, request);
        
        String loginName = userlogin.getLoginName();
        String password = userlogin.getPassword();
        String appId = userlogin.getAppId();
        String domain = userlogin.getDomain();
        String deviceTypeStr = request.getHeader("x-device-type");
        String deviceSN = request.getHeader("x-device-sn");
        String deviceOS = request.getHeader("x-device-os");
        String deviceName = request.getHeader("x-device-name");
        String deviceAgent = request.getHeader("x-client-version");
        
        String regionIp = request.getHeader(Constants.HTTP_X_REGION_IP);
        
        if (StringUtils.isBlank(appId))
        {
            appId = authAppService.getCurrentAppId();
        }
        String remoteAddr = RequestUtils.getRealIP(request);
        int deviceType = UserServiceImpl.transDeviceType(deviceTypeStr);
        
        UserToken userToken = new UserToken();
        userToken.setDeviceSn(deviceSN);
        userToken.setDeviceName(deviceName);
        userToken.setDeviceType(deviceType);
        userToken.setDeviceOS(deviceOS);
        userToken.setDeviceAgent(deviceAgent);
        userToken.setDeviceAddress(remoteAddr);
        userToken.setProxyAddress(RequestUtils.getProxyIP(request));
        
        UserLoginRequest userLoginRequest = new UserLoginRequest();
        userLoginRequest.setAppId(appId);
        userLoginRequest.setLoginName(loginName);
        userLoginRequest.setPassword(password);
        userLoginRequest.setDomain(domain);
        
        RestLoginResponse restLoginResponse = userLoginService.checkFormUser(userLoginRequest,
            userToken,
            regionIp);
        String authToken = restLoginResponse.getToken();
        String refreshToken = restLoginResponse.getRefreshToken();
        transUser(userToken, restLoginResponse);
        userToken.setToken(authToken);
        userToken.setRefreshToken(refreshToken);
        Date expire = new Date(System.currentTimeMillis() + restLoginResponse.getTimeout() * 1000L);
        userToken.setExpiredAt(expire);
        RestUserV2loginRsp userRsp = new RestUserV2loginRsp();
        userRsp.setToken(authToken);
        userRsp.setRefreshToken(refreshToken);
        userRsp.setTimeout(restLoginResponse.getTimeout());
        userRsp.setLoginName(userToken.getLoginName());
        userRsp.setCloudUserId(userToken.getCloudUserId());
        userRsp.setUserId(userToken.getId());
        userRsp.setUploadQos(restLoginResponse.getUploadQos());
        userRsp.setDownloadQos(restLoginResponse.getDownloadQos());
        userRsp.setAccountId(restLoginResponse.getAccountId());
        userRsp.setEnterpriseId(restLoginResponse.getEnterpriseId());
        userRsp.setDomain(restLoginResponse.getDomain());
        userService.createEvent(userToken, EventType.USER_LOGIN, userToken.getId());
        userRsp.setLastAccessTerminal(restLoginResponse.getLastAccessTerminal());
        userRsp.setNeedChangePassword(restLoginResponse.isNeedChangePassword());
        userRsp.setNeedDeclaration(restLoginResponse.isNeedDeclaration());
        userRsp.setEmail(restLoginResponse.getEmail());
        return new ResponseEntity<RestUserV2loginRsp>(userRsp, HttpStatus.OK);
    }
    
    private void transUser(UserToken userToken, RestLoginResponse restLoginResponse)
    {
        userToken.setId(restLoginResponse.getUserId());
        userToken.setLoginName(restLoginResponse.getLoginName());
        userToken.setDomain(restLoginResponse.getDomain());
        userToken.setCloudUserId(restLoginResponse.getCloudUserId());
        userToken.setEnterpriseId(restLoginResponse.getEnterpriseId());
        userToken.setAccountId(restLoginResponse.getAccountId());
    }
    
}
