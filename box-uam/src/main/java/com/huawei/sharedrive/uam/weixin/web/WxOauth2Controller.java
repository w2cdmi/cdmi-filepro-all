package com.huawei.sharedrive.uam.weixin.web;

import com.huawei.sharedrive.uam.exception.ExistUserConflictException;
import com.huawei.sharedrive.uam.openapi.domain.GlobalErrorMessage;
import com.huawei.sharedrive.uam.openapi.manager.LoginManager;
import com.huawei.sharedrive.uam.weixin.domain.WxUserEnterprise;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.huawei.sharedrive.uam.enterprise.service.EnterpriseService;
import com.huawei.sharedrive.uam.enterpriseuser.domain.EnterpriseUser;
import com.huawei.sharedrive.uam.enterpriseuser.service.EnterpriseUserService;
import com.huawei.sharedrive.uam.openapi.domain.RestResponse;
import com.huawei.sharedrive.uam.weixin.domain.WxUser;
import com.huawei.sharedrive.uam.weixin.rest.*;
import com.huawei.sharedrive.uam.weixin.service.WxOauth2Service;
import com.huawei.sharedrive.uam.weixin.service.WxUserManager;
import com.huawei.sharedrive.uam.weixin.service.WxWorkOauth2Service;

import pw.cdmi.common.domain.enterprise.Enterprise;
import pw.cdmi.core.encrypt.HashPassword;
import pw.cdmi.core.utils.HashPasswordUtil;

import javax.servlet.http.HttpServletRequest;

@Controller
@RequestMapping(value = "/api/v2/wxOauth2")
public class WxOauth2Controller {
	private static Logger logger = LoggerFactory.getLogger(WxOauth2Controller.class);

	@Autowired
    @Qualifier("wxWorkOauth2Service")
    WxWorkOauth2Service oauth2Service;

    @Autowired
    WxOauth2Service wxOauth2Service;

    @Autowired
    WxUserManager wxUserManager;

    @Autowired
    private EnterpriseService enterpriseService;

    @Autowired
    private EnterpriseUserService   enterpriseUserService;

    @Autowired
    private LoginManager loginManager;

    /**
	 *  获取授权企业的访问票据
	 */
	@RequestMapping(value = "/getCorpToken", method = RequestMethod.GET)
    public ResponseEntity<String> getCorpToken(@RequestParam String corpId) throws Exception {
        String ticket = oauth2Service.getCorpToken(corpId);
        return new ResponseEntity<>(ticket, HttpStatus.OK);
    }

    /**
	 *  获取授权企业JS-SDK的访问票据
	 */
	@RequestMapping(value = "/getCorpJsApiTicket", method = RequestMethod.GET)
    public ResponseEntity<String> getCorpJsApiTicket(@RequestParam String corpId) throws Exception {
        String ticket = oauth2Service.getCorpJsApiTicket(corpId);
        return new ResponseEntity<>(ticket, HttpStatus.OK);
    }

    /**
     *  将本系统内的账户，绑定微信账号。 此链接是用户扫码后，从微信服务器跳转过来的Get请求。
     */
    @RequestMapping(value = "/bindWxAccount", method = RequestMethod.GET)
    public String bindWxAccount(@RequestParam String code, @RequestParam Long eId, @RequestParam Long uId) throws Exception {
        WxUserInfo userInfo = wxOauth2Service.getWxUserInfo(code);
        if(userInfo == null) {
            logger.error("Can't get UserInfo of code {}: return value is null", code);
            return "enterprise/admin/user/bindWxAccountFail";
        }

        if(userInfo.getErrcode() != null && userInfo.getErrcode() != 0) {
            logger.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", code, userInfo.getErrcode(), userInfo.getErrmsg());
            return "enterprise/admin/user/bindWxAccountFail";
        }

        try {
            //绑定微信用户
            WxUser user = new WxUser();
            user.setUnionId(userInfo.getUnionid());
            user.setOpenId(userInfo.getOpenid());
            user.setNickName(userInfo.getNickname());
            user.setGender(userInfo.getSex());
            user.setCountry(userInfo.getCountry());
            user.setProvince(userInfo.getProvince());
            user.setCity(userInfo.getCity());
            user.setAvatarUrl(userInfo.getHeadimgurl());

            wxUserManager.bindWxAccount(user, eId, uId);
        } catch (Exception e) {
            logger.error("Create WxUser Failed. unionId={}, nickName={}, enterpriseId={}, enterpriseUserId={}", userInfo.getUnionid(), userInfo.getNickname(), eId, uId);
            logger.error("Exception Occurred When create WxUser: ", e);
            return "enterprise/admin/user/bindWxAccountFail";
        }

        return "enterprise/admin/user/bindWxAccountSuccess";
    }

    /**
     *  将本系统内的账户，绑定微信账号。用户在终端界面上的绑定操作
     */
    @RequestMapping(value = "/bindWxAccount", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<String> bindWxAccount(@RequestBody RestBindWxAccountRequest bindRequest) throws Exception {
        WxUserInfo userInfo = wxOauth2Service.getWxUserInfo(bindRequest.getCode());
        if(userInfo == null) {
            logger.error("Can't get UserInfo of code {}: return value is null", bindRequest.getCode());
            return new ResponseEntity<>("Failed to get UserInfo: return value is null", HttpStatus.INTERNAL_SERVER_ERROR);
        }

        if(userInfo.hasError()) {
            logger.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", bindRequest.getCode(), userInfo.getErrcode(), userInfo.getErrmsg());
            return new ResponseEntity<>("Failed to get UserInfo: err=" + userInfo.getErrmsg(), HttpStatus.INTERNAL_SERVER_ERROR);
        }

        try {
            //绑定微信用户
            WxUser user = new WxUser();
            user.setUnionId(userInfo.getUnionid());
            user.setOpenId(userInfo.getOpenid());
            user.setNickName(userInfo.getNickname());
            user.setGender(userInfo.getSex());
            user.setCountry(userInfo.getCountry());
            user.setProvince(userInfo.getProvince());
            user.setCity(userInfo.getCity());
            user.setAvatarUrl(userInfo.getHeadimgurl());

            wxUserManager.bindWxAccount(user, bindRequest.getEnterpriseId(), bindRequest.getEnterpriseUserId());
        } catch (Exception e) {
            logger.error("Create WxUser Failed. unionId={}, nickName={}, enterpriseId={}, enterpriseUserId={}", userInfo.getUnionid(), userInfo.getNickname(), bindRequest.getEnterpriseId(), bindRequest.getEnterpriseUserId());
            logger.error("Exception Occurred When create WxUser: ", e);
        }

        return new ResponseEntity<>("success", HttpStatus.OK);
    }

    /**
     *  在微信小程序中绑定本系统内的账户
     */
    @RequestMapping(value = "/bindWxMpAccount", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<RestResponse> bindWxMpAccount(@RequestBody RestBindWxMpAccountRequest bindRequest) throws Exception {
        WxMpUserInfo userInfo = wxOauth2Service.getWxMpUserInfo(bindRequest.getCode(), bindRequest.getIv(), bindRequest.getEncryptedData());
        if(userInfo == null) {
            logger.error("Failed to bind account: the wxMpUserInfo is null.");
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        if(userInfo.hasError()) {
            logger.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", bindRequest.getCode(), userInfo.getErrcode(), userInfo.getErrmsg());
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        //
        Enterprise enterprise = enterpriseService.getByName(bindRequest.getEnterpriseName());
        if(enterprise == null) {
            logger.error("No such enterprise: {}", bindRequest.getEnterpriseName());
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        EnterpriseUser enterpriseUser = enterpriseUserService.getByEnterpriseIdAndName(enterprise.getId(), bindRequest.getUsername());
        if(enterpriseUser == null) {
            logger.error("No such user: {}", bindRequest.getUsername());
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        //检查密码
        HashPassword hashPassword = new HashPassword();
        hashPassword.setHashPassword(enterpriseUser.getPassword());
        hashPassword.setIterations(enterpriseUser.getIterations());
        hashPassword.setSalt(enterpriseUser.getSalt());
        if (!HashPasswordUtil.validatePassword(bindRequest.getPassword(), hashPassword)) {
            logger.error("Password is wrong: {}", bindRequest.getUsername());
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USERNAME_PASSWORD_WRONG), HttpStatus.OK);
        }

        try {
            //绑定微信用户
            WxUser user = new WxUser();
            user.setUnionId(userInfo.getUnionId());
            user.setOpenId(userInfo.getOpenId());
            user.setNickName(userInfo.getNickName());
            user.setGender(userInfo.getGender());
            user.setCountry(userInfo.getCountry());
            user.setProvince(userInfo.getProvince());
            user.setCity(userInfo.getCity());
            user.setAvatarUrl(userInfo.getAvatarUrl());

            wxUserManager.bindWxAccount(user, enterpriseUser.getEnterpriseId(), enterpriseUser.getId());
        } catch (ExistUserConflictException e) {
            logger.error("WxEnterpriseUser has existed. unionId={}, nickName={}, username={}, enterpriseId={}", userInfo.getUnionId(), userInfo.getNickName(), bindRequest.getUsername(), enterpriseUser.getId());
            logger.error("Exception Occurred When create WxUser: ", e);
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.FAIL), HttpStatus.OK);
        } catch (Exception e) {
            logger.error("Create WxUser Failed. unionId={}, nickName={}, username={}, enterpriseId={}", userInfo.getUnionId(), userInfo.getNickName(), bindRequest.getUsername(), enterpriseUser.getId());
            logger.error("Exception Occurred When create WxUser: ", e);
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.FAIL), HttpStatus.OK);
        }

        return new ResponseEntity<>(new RestResponse(), HttpStatus.OK);
    }


    /**
     *  在微信小程序中开通本系统内的账户
     */
    @RequestMapping(value = "/openWxMpAccount", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<RestResponse> openWxMpAccount(HttpServletRequest request, @RequestBody RestOpenWxMpAccountRequest openRequest) throws Exception {
        WxMpUserInfo mpUserInfo = wxOauth2Service.getWxMpUserInfo(openRequest.getCode(), openRequest.getIv(), openRequest.getEncryptedData());
        if(mpUserInfo == null) {
            logger.error("Failed to open account: the wxMpUserInfo is null.");
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        if(mpUserInfo.hasError()) {
            logger.error("Can't get UserInfo of code {}: errcode={}, errmsg={}", openRequest.getCode(), mpUserInfo.getErrcode(), mpUserInfo.getErrmsg());
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.USER_NOT_EXIST), HttpStatus.OK);
        }

        //自动生成账户
        WxUser wxUser = new WxUser();
        wxUser.setUnionId(mpUserInfo.getUnionId());
        wxUser.setOpenId(mpUserInfo.getOpenId());
        wxUser.setNickName(mpUserInfo.getNickName());
        wxUser.setGender(mpUserInfo.getGender());
        wxUser.setCountry(mpUserInfo.getCountry());
        wxUser.setProvince(mpUserInfo.getProvince());
        wxUser.setCity(mpUserInfo.getCity());
        wxUser.setLanguage(mpUserInfo.getLanguage());
        wxUser.setAvatarUrl(mpUserInfo.getAvatarUrl());

        //2. 生成WxUser
        WxUserEnterprise userEnterprise = wxUserManager.openAccount(wxUser, openRequest.getEnterpriseId(), openRequest.getAppId());
        if(userEnterprise == null) {
            return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.FAIL), HttpStatus.OK);
        }

        //
        return new ResponseEntity<>(new RestResponse(GlobalErrorMessage.OK), HttpStatus.OK);
    }
    
}