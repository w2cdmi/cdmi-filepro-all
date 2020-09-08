package com.huawei.sharedrive.uam.openapi.rest;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import com.huawei.sharedrive.uam.oauth2.domain.UserToken;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.wxrobot.domain.WxRobot;
import com.huawei.sharedrive.uam.wxrobot.domain.WxRobotConfig;
import com.huawei.sharedrive.uam.wxrobot.service.WxRobotConfigService;
import com.huawei.sharedrive.uam.wxrobot.service.WxRobotService;

@Controller
@RequestMapping(value = "/api/v2/wx/robot/")
public class WxRobotApi {

	@Autowired
	private UserTokenHelper userTokenHelper;

	@Autowired
	private WxRobotService wxRobotService;
	
	@Autowired
	private WxRobotConfigService wxRobotConfigService;
	
	@RequestMapping(value = "listRunning", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> listRunning(@RequestHeader("Authorization") String authorization,
			@RequestHeader(value = "Date", required = false) String date, int offset, int limit) {
//		userTokenHelper.checkAppToken(authorization, date);
		List<WxRobot> robotList = wxRobotService.listRuning(WxRobot.STATUS_RUNNING, offset, limit);
		return new ResponseEntity<List<WxRobot>>(robotList, HttpStatus.OK);
	}
	
	@RequestMapping(value = "listConfigBySystem", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> listConfigBySystem(@RequestHeader("Authorization") String authorization,
			@RequestHeader(value = "Date", required = false) String date, long robotId) {
//		userTokenHelper.checkAppToken(authorization, date);
		List<WxRobotConfig> configList = wxRobotConfigService.listByRobotId(robotId);
		return new ResponseEntity<List<WxRobotConfig>>(configList, HttpStatus.OK);
	}

	@RequestMapping(value = "list", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> listByUser(@RequestHeader("Authorization") String authorization, HttpServletRequest req,
			HttpServletResponse resp) {

		UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);
		List<WxRobot> robotList = wxRobotService.listByCloudUserId(userToken.getCloudUserId(),userToken.getAccountId());
		return new ResponseEntity<List<WxRobot>>(robotList, HttpStatus.OK);
	}

	@RequestMapping(value = "getRobotByUin", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> getByUinAndUser(@RequestHeader("Authorization") String authorization, String uin) {
		
		UserToken userToken = userTokenHelper.checkTokenAndGetUser(authorization);

		WxRobot WxRobot = new WxRobot();
		WxRobot.setAccountId(userToken.getAccountId());
		WxRobot.setCloudUserId(userToken.getCloudUserId());
		WxRobot.setWxUin(uin);

		WxRobot newWxRobot = wxRobotService.getByUinAndUser(WxRobot);
		return new ResponseEntity<WxRobot>(newWxRobot, HttpStatus.OK);
	}

	@RequestMapping(value = "create", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<WxRobot> addRobot(@RequestHeader("Authorization") String authorization,
			@RequestBody WxRobot wxRobot) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobot.setId(wxRobotService.getNextRobotId());
		WxRobotConfig userConfig=getUserDefaultConfig(wxRobot);
		WxRobotConfig groupConfig=getGroupDefaultConfig(wxRobot);
		wxRobotConfigService.cerate(userConfig);
		wxRobotConfigService.cerate(groupConfig);
		wxRobotService.create(wxRobot);
		return new ResponseEntity<WxRobot>(wxRobot, HttpStatus.OK);
	}

	@RequestMapping(value = "stopRobot", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<?> stopRobot(@RequestHeader("Authorization") String authorization,
			@RequestBody long robotId) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobotService.stopRobot(robotId);
		return new ResponseEntity<String>(HttpStatus.OK);
	}

	
	@RequestMapping(value = "update", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<WxRobot> updateRobot(@RequestHeader("Authorization") String authorization,
			@RequestBody WxRobot robot) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobotService.updateRobot(robot);
		return new ResponseEntity<WxRobot>(robot, HttpStatus.OK);
	}
	
	@RequestMapping(value = "updateBySystem", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<WxRobot> updateBySystem(@RequestHeader("Authorization") String authorization,
			@RequestHeader(value = "Date", required = false) String date,
			@RequestBody WxRobot robot) {
//		userTokenHelper.checkAppToken(authorization, date);
		wxRobotService.updateRobotStatus(robot);
		return new ResponseEntity<WxRobot>(robot, HttpStatus.OK);
	}
	
	
	@RequestMapping(value = "listConfigByRobotId", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<List<WxRobotConfig>> listConfigByUin(@RequestHeader("Authorization") String authorization,
			long robotId) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		List<WxRobotConfig> listConfig=wxRobotConfigService.listByRobotId(robotId);
		return new ResponseEntity<List<WxRobotConfig>>(listConfig, HttpStatus.OK);
	}
	
	@RequestMapping(value = "deleteConfig", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<?> deleteConfig(@RequestHeader("Authorization") String authorization,
			@RequestBody WxRobotConfig wxRobotConfig) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobotConfigService.delete(wxRobotConfig);
		return new ResponseEntity<String>(HttpStatus.OK);
	}
	
	@RequestMapping(value = "createConfig", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<?> createConfig(@RequestHeader("Authorization") String authorization,
			@RequestBody WxRobotConfig wxRobotConfig) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobotConfigService.cerate(wxRobotConfig);
		return new ResponseEntity<String>(HttpStatus.OK);
	}
	
	@RequestMapping(value = "updateConfig", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<?> updateConfig(@RequestHeader("Authorization") String authorization,
			@RequestBody WxRobotConfig wxRobotConfig) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		wxRobotConfigService.updateConfig(wxRobotConfig);
		return new ResponseEntity<String>(HttpStatus.OK);
	}
	
	private WxRobotConfig getUserDefaultConfig(WxRobot wxRobot){
		WxRobotConfig wxRobotConfig=new WxRobotConfig();
		wxRobotConfig.setRobotId(wxRobot.getId());
		wxRobotConfig.setType(wxRobotConfig.TYPE_USER);
		wxRobotConfig.setName(WxRobotConfig.NAME_USER);
		wxRobotConfig.setValue(WxRobotConfig.VALUE_DEFAULT);
		return wxRobotConfig;
		
	}
	
	private WxRobotConfig getGroupDefaultConfig(WxRobot wxRobot){
		WxRobotConfig wxRobotConfig=new WxRobotConfig();
		wxRobotConfig.setRobotId(wxRobot.getId());
		wxRobotConfig.setType(wxRobotConfig.TYPE_GROUP);
		wxRobotConfig.setName(WxRobotConfig.NAME_GROUP);
		wxRobotConfig.setValue(WxRobotConfig.VALUE_DEFAULT);
		return wxRobotConfig;
		
	}
	

}
