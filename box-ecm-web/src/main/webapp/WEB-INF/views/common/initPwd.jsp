<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="./common.jsp"%>
<style type="text/css">
	*{
	margin: 0;
	padding: 0;
}
body,html{
	font-family: "思源黑体";
}
a{
	text-decoration: none;
}
a:hover{
	text-decoration: none;
}
.revise-pwd-head{
	min-width: 1100px;
	background-color: #191919;
	height: 60px;
}
.pub-width{
	width: 1100px;
	margin: auto;
}
.revise-head-logo a{
	font-size: 18px;
	color: #fff;
	display: inline-block;
	line-height: 60px;
}
.revise-head-logo a img{
	width: 44px;
	display: inline-block;
	vertical-align: middle;
	margin-right: 16px;
}
.revise-pwd-content{
	min-width: 100%;
	min-height: 1016px;
	background-color: #ECF1F5;
	overflow: hidden;
}
.revise-form-con{
	width: 400px;
	height: 520px;
	margin: 135px auto 330px;
	background-color: #fff;
	/*text-align: center;*/
	overflow: hidden;
}
.backmanage-totle{
	text-align: center;
}
.backmanage-totle p{
	font-size: 18px;
	color: #333;
	line-height: 18px;
	margin-top: 25px;
	margin-bottom: 11px;
}
.backmanage-totle span{
	display: block;
	width: 68px;
	height: 2px;
	margin: auto;
	background-color: #1EB686;
}
.revise-form{
	width: 306px;
	margin: auto;
}
.revise-alert{
	height: 16px;
	font-size: 18px;
	color: #ff4c2e;
}
.revise-pwd-title{
	font-size: 14px;
	color: #999;
	margin-top: 4px;
	margin-bottom: 14px;
}
.revise-word-sty{
	width: 304px;
	/*height: 46px;*/
	border: 1px solid #D8D8D8;
	/*overflow: hidden;*/
	position: relative;
	margin-bottom: 32px;
}
.revise-word-sty img{
	float: left;
	width: 21px;
	vertical-align: middle;
	margin: 12px 10px 0 11px;
}
.revise-word-sty input{
	/*float: left;*/
	border: none;
	outline: none;
	height: 46px;
	width: 260px;
}
.validate-con{
	font-size: 12px;
	color: #FF4C2E;
	/*line-height: 25px;
	display: block;
	height: 24px;*/
	position: absolute;
	z-index: 555;
	left: 0;
	top: 46px;
}
.set-email-title{
	font-size: 14px;
	color: #999;
	margin: 2px 0 14px 0;
}
.confirm-btn button{
	outline: none;
	border: none;
	background-color: #1EB686;
	cursor: pointer;
	color: #fff;
	font-size: 18px;
	line-height: 46px;
	display: inline-block;
	text-align: center;
	width: 306px;
}
.buswx-bottom{
	text-align: center;
}
.buswx-bottom p{
	font-size: 14px;
	color: #333;
}
</style>
</head>
<body>
	<div class="revise-pwd-head">
			<div class="revise-head-logo pub-width">
				<a href="${ctx}/logout?token=<c:out value='${token}'/>">
					<img src="${ctx}/static/skins/default/img/logo_03.png"/>
					<shiro:principal property="name"/>
				</a>
			</div>
		</div>
		<div class="revise-pwd-content">
			<div class="revise-form-con">
				<div class="backmanage-totle">
					<p>企业后台管理</p>
					<span></span>
				</div>
				<form class="revise-form" id="modifyPwdForm">
					<div class="revise-alert" id="errorTip" style="display:none">
						<spring:message code="initChgPwd.modifyFail"/><button class="close" data-dismiss="alert">×</button>
					</div>
					<p class="revise-pwd-title"><spring:message code="common.updatePwd"/></p>
					<!--<div class="revise-group">
						
						<div class="revise-word-sty">
							<img src="${ctx}/static/skins/default/img/revisepwd_01.png" alt="" />
							<input type="password" placeholder="请输入您的原密码" id="oldPasswd" name="oldPasswd" value="" autocomplete="off"/>
							<span class="validate-con"><div></div></span>
						</div>
						
					</div>-->
					<div class="revise-group">
						<div class="revise-word-sty">
							<img src="${ctx}/static/skins/default/img/revisepwd_01.png" alt="" />
							<input type="password" placeholder="请设置您的新密码" id="password" name="password" value="" autocomplete="off" />
							<span class="validate-con"><div></div></span>
						</div>
						
					</div>
					<div class="revise-group">
						<div class="revise-word-sty">
							<img src="${ctx}/static/skins/default/img/revisepwd_01.png" alt="" />
							<input type="password" placeholder="请再次输入您的新密码" id="confirmPassword" name="confirmPassword" value="" autocomplete="off" />
							<span class="validate-con"><div></div></span>
						</div>
						
					</div>
					<div class="confirm-btn">
						<button id="chgPassword_btn" type="button" class="btn btn-primary" onclick="submitModify()"><spring:message code="common.modify"/></button>
					</div>
					<input type="hidden" id="token" name="token" value="<c:out value='${token}'/>"/>
				</form>
			</div>
			<div class="pub-width buswx-bottom">
				<p>Copyright © 全艺智家科技有限公司 2017 保留一切权利</p>
			</div>
		</div>
</body>
<script type="text/javascript">
$(document).ready(function() {
	$("#modifyPwdForm").validate({ 
		rules: { 
			   loginName:{
				   required:true, 
				   rangelength:[4,60],
				   isLoginName:true
			   },
//			   oldPasswd: { 
//				   required:true,
//				   isValidOldPwd:true
//			   },
			   password: { 
				   required:true,
				   isValidPwd:true
			   },
			   confirmPassword: { 
				   required:true,
				   equalTo: "#password"
			   }
		}
 }); 
	
});
function submitModify() {
	if(!$("#modifyPwdForm").valid()) {
	     return false;
	}
	$.ajax({
        type: "POST",
        url:"${ctx}/account/initPwd",
        data:$('#modifyPwdForm').serialize(),
        error: function(request) {
        	switch(request.responseText)
			{
				case "PasswordInvalidException":
					handlePrompt("error",'<spring:message code="initChgPwd.noneComplex"/>');
//					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				case "OldPasswordErrorException":
					handlePrompt("error",'<spring:message code="initChgPwd.errOldPwd"/>');
//					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				case "PasswordSameException":
					handlePrompt("error",'<spring:message code="initChgPwd.errOldEqualsNewPwd"/>');
//					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				case "UserLockedException":
					handlePrompt("error",'<spring:message code="initChgPwd.lockmodifypasswd"/>');
//					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				default:
				 	handlePrompt("error",'<spring:message code="common.modifyFail"/>');
//				 	$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
				    break;
			}
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
        	window.location = "${ctx}/";
        }
    });
}
</script>
</html>
