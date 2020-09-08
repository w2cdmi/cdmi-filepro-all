/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.huawei.sharedrive.uam.authapp.service.AuthAppService;
import com.huawei.sharedrive.uam.enterprise.service.EnterpriseAccountService;
import com.huawei.sharedrive.uam.organization.domain.Department;
import com.huawei.sharedrive.uam.organization.domain.DepartmentAccount;
import com.huawei.sharedrive.uam.organization.manager.DepartmentAccountManager;
import com.huawei.sharedrive.uam.organization.service.DepartmentService;
import com.huawei.sharedrive.uam.system.service.AppBasicConfigService;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamSpaceCreateRequest;
import com.huawei.sharedrive.uam.teamspace.domain.RestTeamSpaceInfo;
import com.huawei.sharedrive.uam.teamspace.service.TeamSpaceService;
import com.huawei.sharedrive.uam.weixin.dao.WxDepartmentDao;
import com.huawei.sharedrive.uam.weixin.domain.WxDepartment;
import com.huawei.sharedrive.uam.weixin.service.WxDepartmentService;

import pw.cdmi.common.domain.AppBasicConfig;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;
import pw.cdmi.uam.domain.AuthApp;

import java.util.List;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>部门</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
@Service("weixinDepartmentService")
public class WxDepartmentServiceImpl implements WxDepartmentService {
    private static final Logger logger = LoggerFactory.getLogger(WxDepartmentServiceImpl.class);

    @Autowired
    private WxDepartmentDao weixinDepartmentDao;

    @Autowired
    private DepartmentService departmentService;

    @Autowired
    private AuthAppService authAppService;

    @Autowired
    private TeamSpaceService teamSpaceService;

    @Autowired
    private EnterpriseAccountService enterpriseAccountService;
    
    @Autowired
  	private AppBasicConfigService appBasicConfigService;

    @Autowired
    private DepartmentAccountManager deptAccountManager;

    @Override
    public WxDepartment get(String corpId, int deptId) {
        return weixinDepartmentDao.get(corpId, deptId);
    }

    @Override
    public void create(WxDepartment wxDept) {
        try {
            Department dept = toDepartment(wxDept);
            departmentService.create(dept);

            //自动生成部门空间
            createDeptTeamSpace(wxDept.getBoxEnterpriseId(), dept.getId(), wxDept.getName());

            //保存微信部门与系统部门的对应关系
            wxDept.setBoxDepartmentId(dept.getId());
            if(wxDept.getState() == null) {
                wxDept.setState(0);
            }
            weixinDepartmentDao.create(wxDept);
        } catch (Exception e) {
            logger.error("自动生成部门[{}]失败：{}", wxDept.getName(), e.getMessage());
            logger.error("自动生成部门失败：", e);
        }
    }

    public void createDeptTeamSpace(long enterpriseId, long deptId, String deptName) throws Exception {
        RestTeamSpaceCreateRequest request = new RestTeamSpaceCreateRequest();
        //设置空间名称
        request.setName(deptName);
        //设为不限制
        request.setMaxMembers(-1);
        request.setMaxVersions(-1);
        request.setSpaceQuota((long) -1);
        request.setType(1);//部门空间
//            request.setOwnerBy(-2L);//系统所有。此处不指定Owner，使用[account,...]Token，UFM会自动设置owner为-2（APP_USER_ID)
        AuthApp app = authAppService.getDefaultWebApp();
        AppBasicConfig appBasicConfig=appBasicConfigService.getAppBasicConfig(app.getAuthAppId());
        request.setRegionId(appBasicConfig.getUserDefaultRegion());
        
        RestTeamSpaceInfo teamSpaceInfo = teamSpaceService.createTeamSpace(enterpriseId, app.getAuthAppId(), request);
        teamSpaceService.addDepartMember(teamSpaceInfo,"uploadAndView",enterpriseId, app.getAuthAppId(),deptName);
        try {
			
		} catch (Exception e) {
			// TODO: handle exception
		}
        if (teamSpaceInfo != null) {
            //ufm返回的结果中id对应的就是cloudUserId(Teamspace主键也是cloudUserId).
            deptAccountManager.create(app.getAuthAppId(), enterpriseId, deptId, teamSpaceInfo.getId());
        }
    }

    @Override
    public void update(WxDepartment wxDept) {
        WxDepartment dbDept = weixinDepartmentDao.get(wxDept.getCorpId(), wxDept.getId());

        //更新部门信息
        Department dept = toDepartment(wxDept);
        dept.setId(dbDept.getBoxDepartmentId());
        departmentService.update(dept);

        weixinDepartmentDao.update(wxDept);
    }

    @Override
    public void delete(String corpId, int wxDeptId) {
        try {
            WxDepartment wxDept = weixinDepartmentDao.get(corpId, wxDeptId);

            if(wxDept != null) {
                Department dept = departmentService.getDeptById(wxDept.getBoxDepartmentId());

                if(dept != null) {
                    AuthApp app = authAppService.getDefaultWebApp();
                    EnterpriseAccount account = enterpriseAccountService.getByEnterpriseApp(wxDept.getBoxEnterpriseId(), app.getAuthAppId());
                    DepartmentAccount deptAccount = deptAccountManager.getByDeptIdAndAccountId(dept.getId(), account.getAccountId());
                    if(deptAccount != null) {
                        //删除部门空间. cloudId就是teamId
                        teamSpaceService.deleteTeamSpace(wxDept.getBoxEnterpriseId(), app.getAuthAppId(), deptAccount.getCloudUserId());

                        //删除部门对应的账户
                        deptAccountManager.delete(deptAccount.getId());

                        //删除部门信息
                        departmentService.delete(dept.getId());
                    }
                }

                //删除微信部门信息
                weixinDepartmentDao.delete(wxDept);
            }
        } catch (Exception e) {
            logger.error("自动删除部门[{}]失败：{}", wxDeptId, e.getMessage());
            logger.debug("自动删除部门失败：", e);
        }
    }

    protected Department toDepartment(WxDepartment wxDept) {
        Department dept = new Department();

        //获取微信父部门对应的系统部门
        WxDepartment wxParentDept = weixinDepartmentDao.get(wxDept.getCorpId(), wxDept.getParentId());
        if(wxParentDept != null) {
            dept.setParentid(wxParentDept.getBoxDepartmentId());
        } else {
            dept.setParentid(-1);//根部门，没有父部门
        }
        dept.setName(wxDept.getName());
        if(wxDept.getState() != null) {
            dept.setState(wxDept.getState().byteValue());
        }
        dept.setEnterpriseid(wxDept.getBoxEnterpriseId());
        return dept;
    }

    @Override
    public List<WxDepartment> listByCorpId(String corpId) {
        return weixinDepartmentDao.listByCorpId(corpId);
    }
}
