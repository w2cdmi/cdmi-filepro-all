<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.shiro.web.filter.authc.FormAuthenticationFilter"%>
<%@ page import="org.apache.shiro.authc.ExcessiveAttemptsException"%>
<%@ page import="org.apache.shiro.authc.IncorrectCredentialsException"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<%@ page import="com.huawei.sharedrive.uam.util.custom.ForgetPwdUtils"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%
request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
<title><spring:message code="main.title" /></title>
<%@ include file="./common/common.jsp"%>
<link href="${ctx}/static/skins/default/css/login.css" rel="stylesheet" type="text/css" />
<link rel="shortcut icon" type="image/x-icon" href="${ctx}/static/skins/default/img/logo.ico">
<style type="text/css">
	.all-contro-group{
		overflow: hidden;
	    width: 310px;
	    height: 40px;
	    margin: auto;
	}
	.all-control-label{
		line-height: 12px;
	    float: left;
	    padding-right: 6px
	}
	.all-controls{
		float: left;
	}
</style>
</head>
<body>
<div class="login">
	<div class="top clearfix">
		<div class="logo" id="logoBlock"><img src="${ctx}/static/skins/default/img/logo.png" /><span><spring:message code="main.title" /></span></div>
	</div>
    <div class="main">
    	<form id="loginForm" action="${ctx}/login" method="post" class="form-horizontal">
    <%
	String error = (String) request.getAttribute(FormAuthenticationFilter.DEFAULT_ERROR_KEY_ATTRIBUTE_NAME);
	if(error != null){
	    if(error.equals("com.huawei.sharedrive.uam.exception.IncorrectCaptchaException")){
	%>
		    <div class="alert alert-error input-medium controls" style="width: 310px;margin: auto;">
				<button class="close" data-dismiss="alert">×</button><spring:message code="login.verificationCode"/>
			</div>
	<%        
	    }
	    else if(error.equals("com.huawei.sharedrive.uam.exception.UserLockedWebException")){
	    	%>
	    		    <div class="alert alert-error input-medium controls" style="width: 310px;margin: auto;">
	    				<button class="close" data-dismiss="alert">×</button><spring:message code="login.userLocked"/>
	    			</div>
	    	<%        
	     }
	    else if(error.equals("com.huawei.sharedrive.uam.exception.DisabledUserException")){
	    	%>
	    		    <div class="alert alert-error input-medium controls" style="width: 310px;margin: auto;">
	    				<button class="close" data-dismiss="alert">×</button><spring:message code="login.disabledUser"/>
	    			</div>
	    	<%        
	     }
	    else
	    {
	%>
	        <div class="alert alert-error input-medium controls" style="width: 310px;margin: auto;">
				<button class="close" data-dismiss="alert">×</button><spring:message code="login.errUser"/>
			</div>
    <%
	    }
	}
	%>
        <div class="control-group all-contro-group">
            <label class="control-label all-control-label" for="enterpriseName"><spring:message code="login.enterpriseName" />:</label>
            <div class="controls all-controls">
                <input type="text" id="enterpriseName" name="enterpriseName"  value="<%=request.getParameter("enterpriseName") == null ? "": org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("enterpriseName"))%>" class="input-medium required"/>
            </div>
        </div>
        <div class="control-group all-contro-group">
            <label style="padding-left: 14px;" class="control-label all-control-label" for="username"><spring:message code="login.username" />:</label>
            <div class="controls all-controls">
                <input type="text" id="username" name="username"  value="<%=request.getParameter("username") == null ? "": org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("username"))%>" class="input-medium required"/>
            </div>
        </div>
        <div class="control-group all-contro-group">
            <label style="padding-left: 28px;" class="control-label all-control-label" for="password"><spring:message code="login.password" />:</label>
            <div class="controls all-controls">
                <input type="password" id="password" name="password" value="" class="input-medium required" autocomplete="off"/>
                 <%
                   if(ForgetPwdUtils.enableForget())
                   {
               %>
                   <span class="forget-pwd" onclick="gotoForgetPwd()"><spring:message code="anon.pwd.forget"/></span>
                <%	   
                   }
                %>
            </div>
        </div>
		<div class="control-group all-contro-group">
            <label style="padding-left: 14px;" class="control-label all-control-label" for="captcha"><spring:message code="login.captcha" />:</label>
            <div class="controls all-controls">
                <input type="text" id="captcha" name="captcha" class="input-medium required" size="4" maxlength="4"/>
                <span class="validate-code">
                    <img title='<spring:message code="anon.toChangecaptcha" />' id="img_captcha" onclick="javascript:loadImage();" src="#">
                </span>
            </div>
        </div>
        <div class="control-group">
            <div class="controls" style="width: 128px;margin: 18px auto 0;">
            	<button type="submit" class="btn btn-primary"><spring:message code="login.submit" /></button>
            </div>
        </div>
        </form>
        <div class="copy-right" id="copyRightId">
        <spring:message code="corpright" />
        </div>
    </div>
</div>
</body>
<script type="text/javascript">
		$(document).ready(function() {
			if(window.top != window.self){
				window.top.location="${ctx}/logout?token=<c:out value='${token}'/>";
			}
			if (document.all){
				document.execCommand("ClearAuthenticationCache","false");
			}else {
				var xmlhttp = new XMLHttpRequest();
				xmlhttp.open("GET", "${ctx}/logout", false, "logout", "logout");
				xmlhttp.send(null);
			}
			$("#img_captcha").attr("src","${ctx}/verifycode?" + Math.random());
			$("#loginForm").validate();
		});
		
		function gotoForgetPwd(){
			window.location = "${ctx}/syscommon/enterforget";
		}
		
		function loadImage()
		{
		    $("#img_captcha").attr("src","${ctx}/verifycode?" + Math.random());
		    $("#captcha").val("");
		    $("#captcha").focus();
		}
</script>
</html>
