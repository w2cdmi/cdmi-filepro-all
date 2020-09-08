<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));%>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="../../../common/common.jsp" %>
    <meta charset="UTF-8">
    <title>Title</title>

<%--
    <link href="${ctx}/static/base_config/base_config.css" type="text/css" rel="stylesheet">
    <script src="${ctx}/static/base_config/base_config.js"></script>
--%>
    <link href="${ctx}/static/skins/default/css/public.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/skins/default/css/main.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css"/>
    <script src="${ctx}/static/zTree/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>
    <%--<script src="${ctx}/static/js/public/common.js" type="text/javascript"></script>--%>
</head>

<div class="content">
    <input type="hidden" id="token" name="token" value="${token}"/>
    <input type="hidden" id="appId" name="appId" value="${appId}"/>
    <!--面包屑导航-->
    <!--<div class="curr-location">
        <div class="location-icon icon icon-location" style='background: url(../../../static/skins/public/images/icon.png); background-repeat: no-repeat;background-position: -64px -59px;'></div>
        <div class="curr-location-detail">
            <span>当前位置:</span>
            <a href="">控制台</a>
            <span>&gt;</span>
            <a href=""><spring:message code="enterpriseAdmin.employee.manage"/></a>
            <span>&gt;</span>
            <a class="curr-location-now"><spring:message code="enterpriseAdmin.organization.chart"/></a>
        </div>
    </div>-->
    <div class="c_main" id="enterpriseUserAdmin">
        <div class="option-header">
            <div class="option-item option-header-active" href="${ctx}/enterprise/admin/organize/enterDeptTreeManage/0"><spring:message code="enterpriseAdmin.organization.chart"/></div>
            <div class="option-item" href="${ctx}/enterprise/admin/user/infoSecurityManage/0">信息安全管理员</div>
            <div class="option-item" href="${ctx}/enterprise/admin/user/archiveOwnerManage/0">知识管理员</div>
            <div class="option-item" href="${ctx}/enterprise/admin/user/employeeManage/0"><spring:message code="enterpriseAdmin.employee.manage"/></div>
        </div>

        <!--组织架构-->
        <div class="option-content show" id="mainContainer">
        </div>



        <!--信息安全管理员-->
<%--
        <div class="option-content" id="infoManager">
            信息安全管理员
            <div class="ui-btn save-config-domain">保存</div>
        </div>
        <div class="option-content" id="archiveManager">
            版权管理
            <div class="ui-btn save-config-domain">保存</div>
        </div>
        <div class="option-content" id="employeeManager">
            配额管理
            <div class="ui-btn save-config-domain">保存</div>
        </div>
--%>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        //tab
        var $tabs = $(".option-item");
        $tabs.each(function (e, v) {
            $(v).bind("click", function (t, h) {
                $(".option-item").each(function (k1, v1) {
                    $(v1).removeClass("option-header-active");
                    $("#" + $(v1).attr("value")).css("display", "none");
                });
                $(this).addClass("option-header-active");

                var url = $(this).attr("href");
                if(url != null) {
                    $("#mainContainer").load(url).show();
                }
            })

        });

        //界面进入后，显示第一个tab内容
        $("#mainContainer").load($tabs.first().attr("href"));
    });

    function reloadCurrentTab() {
        $("#enterpriseUserAdmin").find(".option-header-active").click();

    }
</script>


</html>