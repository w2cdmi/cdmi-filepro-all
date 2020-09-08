/* 
 * 版权声明(Copyright Notice)：
 * Copyright(C) 2017-2017 聚数科技成都有限公司。保留所有权利。
 * Copyright(C) 2017-2017 www.cdmi.pw Inc. All rights reserved.
 * 警告：本内容仅限于聚数科技成都有限公司内部传阅，禁止外泄以及用于其他的商业项目
 */
package com.huawei.sharedrive.uam.weixin.service.impl;

import com.huawei.sharedrive.uam.weixin.domain.WxDepartment;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterprise;
import com.huawei.sharedrive.uam.weixin.domain.WxEnterpriseUser;
import com.huawei.sharedrive.uam.weixin.event.*;
import com.huawei.sharedrive.uam.weixin.rest.Department;
import com.huawei.sharedrive.uam.weixin.rest.PermanentCodeInfo;
import com.huawei.sharedrive.uam.weixin.rest.User;

import java.util.Date;

/************************************************************
 * @author Rox
 * @version 3.0.1
 * @Description: <pre>将微信事件或查询结果转换为Domain的工具类</pre>
 * @Project Alpha CDMI Service Platform, box-uam-web Component. 2017/7/31
 ************************************************************/
public class WxDomainUtils {
    public static WxEnterprise toWxEnterprise(PermanentCodeInfo info) {
        WxEnterprise enterprise = new WxEnterprise();
        enterprise.setId(info.getAuthCorpInfo().getCorpid());
        enterprise.setName(info.getAuthCorpInfo().getCorpName());
        enterprise.setType(info.getAuthCorpInfo().getCorpType());
        enterprise.setSquareLogoUrl(info.getAuthCorpInfo().getCorpSquareLogoUrl());
        enterprise.setUserMax(info.getAuthCorpInfo().getCorpUserMax());
        enterprise.setFullName(info.getAuthCorpInfo().getCorpFullName());
        enterprise.setSubjectType(info.getAuthCorpInfo().getSubjectType());
        enterprise.setVerifiedEndTime(new Date(info.getAuthCorpInfo().getVerifiedEndTime()));
        enterprise.setWxqrCode(info.getAuthCorpInfo().getCorpWxqrcode());
        enterprise.setEmail(info.getAuthUserInfo().getEmail());
        enterprise.setMobile(info.getAuthUserInfo().getMobile());
        enterprise.setUserId(info.getAuthUserInfo().getUserid());
        enterprise.setPermanentCode(info.getPermanentCode());

        return enterprise;
    }

    /**
     * 将部门查询结果转化为Domain对象。查询结果中没有enterpriseId, 需要调用函数自己赋值
     * @param dept 部门查询结果
     * @return WxDepartment
     */
    public static WxDepartment toWxDepartment(Department dept) {
        WxDepartment wx = new WxDepartment();
        wx.setId(dept.getId());
        wx.setParentId(dept.getParentid());
        wx.setName(dept.getName());
        wx.setOrder(dept.getOrder());

        return wx;
    }

    /**
     * 将SuiteCreatePartyEvent转化为Domain对象。
     * @param e SuiteCreatePartyEvent
     * @return WxDepartment
     */
    public static WxDepartment toWxDepartment(SuiteCreatePartyEvent e) {
        WxDepartment wx = new WxDepartment();
        wx.setCorpId(e.getAuthCorpId());
        wx.setId(e.getId());
        wx.setParentId(Integer.parseInt(e.getParentId()));
        wx.setName(e.getName());
        wx.setOrder(e.getOrder());

        return wx;
    }

    /**
     * 将SuiteUpdatePartyEvent转化为Domain对象。
     * @param e SuiteUpdatePartyEvent
     * @return WxDepartment
     */
    public static WxDepartment toWxDepartment(SuiteUpdatePartyEvent e) {
        WxDepartment wx = new WxDepartment();
        wx.setCorpId(e.getAuthCorpId());
        wx.setId(e.getId());
        if(e.getParentId() != null) {
            wx.setParentId(Integer.parseInt(e.getParentId()));
        } else {
            wx.setParentId(-1);
        }
        wx.setName(e.getName());

        return wx;
    }

    /**
     * 将员工查询结果转化为Domain对象。查询结果中没有enterpriseId, 需要调用函数自己赋值
     * @param user 员工查询结果
     * @return WxDepartment
     */
    public static WxEnterpriseUser toWxEnterpriseUser(User user) {
        WxEnterpriseUser wx = new WxEnterpriseUser();
        wx.setDepartmentId(user.getDepartment().get(user.getDepartment().size() - 1));
        wx.setUserId(user.getUserid());
        wx.setName(user.getName());
        wx.setOrder(user.getOrder().get(user.getOrder().size() - 1));
        wx.setPosition(user.getPosition());
        wx.setMobile(user.getMobile());
        wx.setGender(user.getGender());
        wx.setEmail(user.getEmail());
        wx.setIsLeader(user.getIsleader());
        wx.setAvatar(user.getAvatar());
        wx.setTelephone(user.getTelephone());
        wx.setEnglishName(user.getEnglishName());
        wx.setStatus(user.getStatus());

        return wx;
    }

    /**
     * 将SuiteCreateUserEvent果转化为Domain对象。
     * @param e SuiteCreateUserEvent
     * @return WxDepartment
     */
    public static WxEnterpriseUser toWxEnterpriseUser(SuiteCreateUserEvent e) {
        WxEnterpriseUser wx = new WxEnterpriseUser();
        wx.setCorpId(e.getAuthCorpId());
        String[] split = e.getDepartment().split(",");
        wx.setDepartmentId(Integer.parseInt(split[split.length - 1]));
        wx.setUserId(e.getUserID());
        wx.setName(e.getName());
//        wx.setOrder(e.getOrder().get(e.getOrder().size() - 1));
        wx.setPosition(e.getPosition());
        wx.setMobile(e.getMobile());
        wx.setGender(e.getGender());
        wx.setEmail(e.getEmail());
        wx.setIsLeader(e.getIsLeader());
//        wx.setAvatar(e.getAvatar());
        wx.setTelephone(e.getTelephone());
        wx.setEnglishName(e.getEnglishName());
        wx.setStatus(e.getStatus());

        return wx;
    }

    /**
     * 将SuiteUpdateUserEvent果转化为Domain对象。
     * @param e SuiteUpdateUserEvent
     * @return WxDepartment
     */
    public static WxEnterpriseUser toWxEnterpriseUser(SuiteUpdateUserEvent e) {
        WxEnterpriseUser wx = new WxEnterpriseUser();
        wx.setCorpId(e.getAuthCorpId());
        String[] split = e.getDepartment().split(",");
        wx.setDepartmentId(Integer.parseInt(split[split.length - 1]));
        wx.setUserId(e.getUserID());
        wx.setName(e.getName());
//        wx.setOrder(e.getOrder().get(e.getOrder().size() - 1));
        wx.setPosition(e.getPosition());
        wx.setMobile(e.getMobile());
        wx.setGender(e.getGender());
        wx.setEmail(e.getEmail());
        wx.setIsLeader(e.getIsLeader());
//        wx.setAvatar(e.getAvatar());
        wx.setTelephone(e.getTelephone());
        wx.setEnglishName(e.getEnglishName());
        wx.setStatus(e.getStatus());

        return wx;
    }

    /**
     * 将AppCreatePartyEvent转化为Domain对象。
     * @param e SuiteCreatePartyEvent
     * @return WxDepartment
     */
    public static WxDepartment toWxDepartment(AppCreatePartyEvent e) {
        WxDepartment wx = new WxDepartment();
        wx.setId(e.getId());
        wx.setParentId(Integer.parseInt(e.getParentId()));
        wx.setName(e.getName());
        wx.setOrder(e.getOrder());

        return wx;
    }

    /**
     * 将AppUpdatePartyEvent转化为Domain对象。
     * @param e SuiteUpdatePartyEvent
     * @return WxDepartment
     */
    public static WxDepartment toWxDepartment(AppUpdatePartyEvent e) {
        WxDepartment wx = new WxDepartment();
        wx.setId(e.getId());

        if(e.getParentId() != null) {
            wx.setParentId(Integer.parseInt(e.getParentId()));
        }

        wx.setName(e.getName());

        return wx;
    }

    /**
     * 将AppCreateUserEvent果转化为Domain对象。
     * @param e SuiteCreateUserEvent
     * @return WxDepartment
     */
    public static WxEnterpriseUser toWxEnterpriseUser(AppCreateUserEvent e) {
        WxEnterpriseUser wx = new WxEnterpriseUser();
        wx.setCorpId(e.getToUserName());
        String[] split = e.getDepartment().split(",");
        wx.setDepartmentId(Integer.parseInt(split[split.length - 1]));
        wx.setUserId(e.getUserID());
        wx.setName(e.getName());
//        wx.setOrder(e.getOrder().get(e.getOrder().size() - 1));
        wx.setPosition(e.getPosition());
        wx.setMobile(e.getMobile());
        wx.setGender(e.getGender());
        wx.setEmail(e.getEmail());
        wx.setIsLeader(e.getIsLeader());
        wx.setAvatar(e.getAvatar());
        wx.setTelephone(e.getTelephone());
        wx.setEnglishName(e.getEnglishName());
        wx.setStatus(e.getStatus());

        return wx;
    }

    /**
     * 将AppUpdateUserEvent果转化为Domain对象。
     * @param e SuiteUpdateUserEvent
     * @return WxDepartment
     */
    public static WxEnterpriseUser toWxEnterpriseUser(AppUpdateUserEvent e) {
        WxEnterpriseUser wx = new WxEnterpriseUser();
        wx.setCorpId(e.getToUserName());
        String[] split = e.getDepartment().split(",");
        wx.setDepartmentId(Integer.parseInt(split[split.length - 1]));
        wx.setUserId(e.getUserID());
        wx.setName(e.getName());
//        wx.setOrder(e.getOrder().get(e.getOrder().size() - 1));
        wx.setPosition(e.getPosition());
        wx.setMobile(e.getMobile());
        wx.setGender(e.getGender());
        wx.setEmail(e.getEmail());
        wx.setIsLeader(e.getIsLeader());
//        wx.setAvatar(e.getAvatar());
        wx.setTelephone(e.getTelephone());
        wx.setEnglishName(e.getEnglishName());
        wx.setStatus(e.getStatus());

        return wx;
    }
}
