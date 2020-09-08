<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.shiro.SecurityUtils" %>
<%@ page import="com.huawei.sharedrive.uam.user.domain.Admin" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<%@ page import="org.apache.shiro.session.Session" %>
<%@ page import="org.apache.shiro.SecurityUtils" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

Admin admin = (Admin) SecurityUtils.getSubject().getPrincipal();
request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
Session sesion = SecurityUtils.getSubject().getSession();
boolean tag = (Boolean) sesion.getAttribute("tag");
%>
<%-- <div class="header">
    <div class="header-con">
    	<div class="logo" id="logoBlock"><img src="${ctx}/static/skins/default/img/logo.png" /><span><spring:message code="main.title" /></span></div>
        <div class="nav-menu">
        	<shiro:hasRole name="ENTERPRISE_MANAGER">
        	<ul class="clearfix" id="downMenu">
        		<li>
		        	<a class="menu-enterprise"><i></i><spring:message code="ENTERPRISE_BUSINESS_MANAGER"/></a>
			        <ul>
			        	<li><span onClick="openInframe(this, '{ct$x}/enterprise/admin/enterpriseInfo','systemFrame')"><spring:message  code="enterpriseAdmin.header.info"  /></span></li>
			        	<li><span onClick="openInframe(this, '${ctx}/enterprise/admin/authserver/enterList','systemFrame')"><spring:message  code="enterpriseAdmin.authentication.methods"  /></span></li>
			        	<c:if test="${checkOrganizeOperPrivilege}">
			        		<li><span onClick="openInframe(this, '${ctx}/enterprise/admin/organize/enterDeptTreeManage/0','systemFrame')"><spring:message  code="enterpriseAdmin.organization.chart"  /></span></li>
						</c:if>
			        	<li><span onClick="openInframe(this, '${ctx}/enterprise/admin/user/employeeManage/0','systemFrame')"><spring:message  code="enterpriseAdmin.employee.manage"  /></span></li>
			        </ul>
	        	</li>	        	
	        	<li>
		        	<a class="menu-application"><i></i><spring:message code="header.appManager"/></a>
			        <ul>
			        	<li><span  onClick="openInframe(this, '${ctx}/enterprise/admin/listAppByAuthentication','systemFrame')"><spring:message  code="appList.appList"  /></span></li>
			        </ul>
	        	</li>
	        </ul>
	        </shiro:hasRole>
        </div>
        <div class="header-R pull-right clearfix">
        	<ul class="clearfix pull-right">
            	<li class="pull-left dropdown">
                	<a class="dropdown-toggle" href="#" id="nav-account" data-toggle="dropdown"><strong title="<shiro:principal property='name'/>"><shiro:principal property="name"/></strong> <i class="icon-caret-down icon-white"></i></a>
                	<ul class="dropdown-menu pull-right">
                	    <%if(admin.getDomainType() == Constants.DOMAIN_TYPE_LOCAL){ 
                	        if(admin.getType() == Constants.ROLE_SUPER_ADMIN){
                	    %>
                	            <li><a href="javascript:enterModifyAccountPage()"><i class="icon-user"></i><spring:message code="header.updateUserName"/></a></li>    
                	    <%
                	        }
                	    %>
                	        <li><a href="javascript:enterModifyPwdPage()"><i class="icon-lock"></i><spring:message code="common.updatePwd"/></a></li>
                	        <%if(admin.getType() != Constants.ROLE_ENTERPRISE_ADMIN){%>
                	        <li><a href="javascript:enterModifyEmail()"><i class="icon-envelope"></i><spring:message code="header.updateMail"/></a></li>
                	        <%} %>
                	    <% 
                	      }
                	    %>
	                    <li class="divider"></li>
						<li id="langZH"><a href="?locale=zh_CN"><i class="icon-lang-zh"></i>简体中文</a></li>
						<li id="langEN"><a href="?locale=en_US"><i class="icon-lang-en"></i>English</a></li>
                        <li class="divider"></li>
                        <li><a href="#" onclick="doLogout()"><i class="icon-signout"></i> <spring:message code="common.exit"/></a></li>
                    </ul>
                </li>
            </ul>
        </div>
        
        <!-- show login info -->
		<div class="modal hide" id="loginInfo" tabindex="-1" role="dialog"
			aria-hidden="true" data-backdrop="static">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					onclick="closeInfo()" aria-hidden="true">&times;</button>
				<h3>
					<spring:message code="loginInfo.info" />
				</h3>
			</div>
			<div class="modal-body" style="margin-left:40px;">
				<div id="loginTime" style="margin-left:12px;">
					<spring:message code="loginInfo.date" />
					<span id="showTimeZone"></span>
				</div>
				<div id="loginIP" style="margin-top:10px;">
					<spring:message code="loginInfo.IP" />
					<%
					    if (admin.getLastLoginIP() != null)
					    {
					%>
					<%=org.springframework.web.util.HtmlUtils.htmlEscape(admin.getLastLoginIP())%>
					<%
					    }
					%>
				</div>
				<div id="loginClient" style="margin-top:10px;margin-left:27px;">
					<spring:message code="loginInfo.clientInfo" />
					<spring:message code="loginInfo.client" />
				</div>
			</div>
		</div>
	</div>
</div>  --%>


<div class="header">
    <div class="h_logo">
        <div class="logo-icon icon icon-logo">
        	<div class="enterprise-name">${productName}</div>
        </div>
    </div>
    <!--<div class="h_nav">
        <a class="h_nav_item">文件管理</a>
        <a class="h_nav_item">服务套餐</a>
        <a class="h_nav_item">帮助</a>
    </div>-->
    <div class="h_right">
        <!--<div class="h_r_import">
            <input type="button" class="btn" value="导入云盘文件" style="height: 30px;">
        </div>-->
        <!--<div class="h_r_message">
            <div class="message-icon icon icon-message"></div>
            <div class="message-new"></div>
            <div class="message-detail">
                <div class="message-item">第一条信息</div>
                <div class="message-item">第二条信息</div>
                <div class="message-item">第三条信息</div>
            </div>
        </div>-->
        <div class="h_r_user">
            <div class="user-logo icon icon-user"></div>
            <div class="user-name"><shiro:principal property="name"/></div>
            <div class="toggle-user-menu icon icon-arrow-down"></div>
            <div class="user-menu">
                <div class="user-menu-item" onClick="enterModifyPwdPage()">修改密码</div>
                <div class="user-menu-item">个人中心</div>
                <div class="user-menu-item">帮助</div>
                <div class="user-menu-item"><a href="${ctx}/logout?token=<c:out value='${token}'/>">退出</a></div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
	$(".user-name,.toggle-user-menu").click(function(e){
		$(".user-menu").toggle();
		e.stopPropagation();
	});

	$("body").click(function(){
		$(".user-menu").hide();
	});

    function enterModifyPwdPage(){
        top.ymPrompt.win({
            message:'${ctx}/account/changePwd',
            width:700,
            height:320,
            title:'<spring:message code="common.updatePwd"/>',
            iframe:true,
            btn:[['<spring:message code="common.modify"/>','yes',false,"btnModifyPwd"],['<spring:message code="common.cancel"/>','no',true,"btnModifyCancel"]],
            handler:doSubmitModifyPwd
        });
        top.ymPrompt_addModalFocus("#btnModifyPwd");
    }
    function doSubmitModifyPwd(tp) {
        if (tp == 'yes') {
            top.ymPrompt.getPage().contentWindow.submitModifyPwd();
        } else {
            top.ymPrompt.close();
        }
    }
</script>
