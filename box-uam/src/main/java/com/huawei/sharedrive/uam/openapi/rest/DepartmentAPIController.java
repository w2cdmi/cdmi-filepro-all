package com.huawei.sharedrive.uam.openapi.rest;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import com.huawei.sharedrive.uam.oauth2.service.impl.UserTokenHelper;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;

@Controller
@RequestMapping(value = "/api/v2/department")
public class DepartmentAPIController {

	private static final Logger LOGGER = LoggerFactory.getLogger(DepartmentAPIController.class);

	@Autowired
	DepartmentService departmentService;

	@Autowired
	private UserTokenHelper userTokenHelper;

	@RequestMapping(value = "/getDeptInfo/{deptId}", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<?> get(@RequestHeader("Authorization") String authorization,
			@RequestHeader(value = "Date", required = false) String date,@PathVariable("deptId") long deptId) {
		userTokenHelper.checkTokenAndGetUser(authorization);
		Department department = departmentService.getDeptById(deptId);
		return new ResponseEntity<Department>(department, HttpStatus.OK);
	}

}
