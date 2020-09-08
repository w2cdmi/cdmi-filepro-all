<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/common.jsp"%>
</head>
<body>
	<div class="header">
		<div class="header-con">
			<div class="logo" id="logoBlock">
				<img src="${ctx}/static/skins/default/img/logo.png" /><span><spring:message code="main.title" /></span>
			</div>
		</div>
	</div>

	<div class="body">
		<div class="sys-content  clearfix register-con">
			<h4>
				<spring:message code="anon.pwd.forget" />
			</h4>
			<div class="form-horizontal form-con clearfix">
				<form class="form-horizontal" id="forgetPwdForm">
					<div class="alert alert-error input-medium controls" id="errorTip"
						style="display: none">
						<button class="close" data-dismiss="alert">×</button>
						<spring:message code="anon.forgetPwdError" />
					</div>
					<div class="control-group">
					<label class="control-label" for="input"><em>*</em><spring:message code="forgetPwd.label.phoneNo"/></label>
						<div class="controls">
							<input type="text" id="contactPhone" name="contactPhone" value="" placeholder='<spring:message code="forgetPwd.message.inputPhoneNo"/>' style="width: 231px" />
							<span class="validate-con" id="loginBlock"><div></div></span>
						</div>
					</div>

					<div class="control-group">
						<label class="control-label" for="input"><em>*</em><spring:message code="forgetPwd.label.verifyCode"/></label>
						<div class="controls">
							<input class="span1" type="text" id="identifyCode" name="identifyCode" style="width:94px" value="" placeholder='<spring:message code="forgetPwd.message.fillVerifyCode"/>'/>
	                		<span class="validate-con" id="loginBlock"><div id="vfCodeDiV" style="margin-left:161px"></div></span>
	               			<input type="button" id="btn" value='<spring:message code="forgetPwd.label.getVerifyCode"/>' class="btn btn-primary" style="width:128px" onclick="sendVerifyCode();"/>
						</div>
					</div>

					<div class="control-group">
					<label class="control-label" for="input"><em>*</em><spring:message code="forgetPwd.label.pwd"/></label>
						<div class="controls">
						<input class="span2" type="text" id="newPwd" onfocus="this.type='password'"  autocomplete="off" name="password" value="" style="width:231px" placeholder='<spring:message code="forgetPwd.message.inputNewPwd"/>'  />
	                 	<span class="validate-con" id="loginBlock"><div></div></span>
						</div>
					</div>
					
					<div class="control-group">
						<label class="control-label" for="input"><em>*</em><spring:message code="anon.confirmPwd"/></label>
						<div class="controls">
						<input class="span2" type="text" id="confirmPwd" onfocus="this.type='password'"  autocomplete="off" name="confirmPwd" value="" style="width:231px" placeholder='<spring:message code="forgetPwd.message.confirmPwd"/>'   />
	                 	<span class="validate-con" id="loginBlock"><div></div></span>
						</div>
					</div>

					<div class="control-group" >
						<div class="controls" style>
							<button id="chgPassword_btn" type="button" class="btn btn-primary" onclick="resetPassword()" style="width:58px;margin-right:10px">
								<spring:message code="common.OK" />
							</button>
							<button id="chgPassword_back" type="button" class="btn" onclick="backLogin()" >
								<spring:message code="common.back" />
							</button>
						</div>
					</div>
					<input type="hidden" id="token" name="token" value="<c:out value='${token}'/>" />
				</form>
			</div>
		</div>
	</div>

	<div class="footer">
		<div class="footer-con">
			<p>
				<span class="logo-small" id="copyRightId"><spring:message
						code="corpright" /></span>
			</p>
		</div>
	</div>
</body>
<script type="text/javascript">
	var wait = 60;
	function time(o) {
        if (wait == 0) {
            o.removeAttribute("disabled");           
            o.value='<spring:message code="forgetPwd.label.getVerifyCode"/>';
            wait = 60;
        } else { 
            o.setAttribute("disabled", true);
            o.value='<spring:message code="forgetPwd.label.getVerifyCode"/>'+"(" + wait + ")";
            wait--;
            setTimeout(function() {
                time(o)
            },
            1000)
        }
    }
	
	//Validate method
	$(document).ready(function() {
		$("#forgetPwdForm").validate({ 
			rules: { 
				contactPhone:{
					   required:true,
					   checkName:true
				   },
				   identifyCode:{ 
					   required:true,
					   minlength:[6]
				   },
				   password:{
					   required:true,
					   minlength:[8],
					   isValidPwd:true
				   },
				   confirmPwd:{
					   required:true,
					   minlength:[8],
					   isValidPwd:true,
					   equalTo:"#password"
				   }
			}
	   }); 
	});

	//重置密码
	function resetPassword() {
		if (!checkValidation()) {
			return false;
		}
		$.ajax({
			type : "POST",
			url : "${ctx}/syscommon/setPasswordByPhone",
			data : $('#forgetPwdForm').serialize(),
			error : function(request) {
				$("#captcha").val("");
				$("#img_captcha").attr("src","${ctx}/verifycode?" + Math.random());
				top.handlePrompt("error",'<spring:message code="anon.forgetPwdError" />');
			},
			success : function() {
				top.ymPrompt.alert({
					title : '<spring:message code="common.title.info"/>',
					message : '<spring:message code="anon.forgetPwdMsg" />',
					handler : backLogin
				});
				setTimeout(function() {ymPrompt.doHandler('ok')}, 3000);
			}
		});
	}

	//Send code to user`s phone
	function sendVerifyCode(){
		if(!$("#forgetPwdForm #contactPhone").valid()){
			return;
		}
		
		if(!checkExisting()){
			handlePrompt("error",'<spring:message code="forgetPwd.message.accountInvalid" />',1,1,null,"loginBlock");
			return ;
		}
		
		$.ajax({
            type: "POST",
            async: false,
            url:"${ctx}/syscommon/createAndSendIdentifyCode",
            data:$('#forgetPwdForm').serialize(),
            error: function() {
            	$("#btn").val('<spring:message code="sms.message.sendFail" />');
            },
            success:function(){
            	time(document.getElementById("btn"));
            }
        });
	}

	$.validator.addMethod("checkName", function(element) {
		var value = $("#contactPhone").val();
		var reg_ph = /^1(3|4|5|7|8)\d{9}$/;
		var reg_em = /^(\w)+(\.\w+)*@(\w)+((\.\w+)+)$/;

		if (reg_ph.test(value)) {
			return true;
		} else if (reg_em.test(value)) {
			if (value.length > 30) {
				return false;
			}
			return true;
		}
		return false;
	},'<spring:message code="forgetPwd.message.patternIncorrect" />');

	//Check the userName`s validation
	function checkValidation() {
		if (!$("#forgetPwdForm").valid()) {
			return false;
		}
		return checkExisting();
	}
	
	
	function checkExisting(){
		var chkRes;
		$.ajax({
			type : "POST",
			url : "${ctx}/syscommon/checkName",
			data : $('#forgetPwdForm').serialize(),
			async: false,
			error : function(request) {
				top.handlePrompt("error", '<spring:message code="anon.forgetPwdError" />');
			},
			success : function(data) {
				chkRes = eval(data)[0].isExist;
				if(!chkRes){
					handlePrompt("error",'<spring:message code="forgetPwd.message.accountInvalid" />',1,1,null,"loginBlock");
				}
			}
		});
		return chkRes;
	}
	
	function backLogin() {
		window.location = "${ctx}/login";
	}
	
	$.validator.addMethod("isValidPwd", function(element) {
		var value = $("#newPwd").val();
		var re = new RegExp("[a-zA-Z]");
		var len = re.test(value);
		re = new RegExp("[0-9]");
		len = re.test(value);
		re = new RegExp("((?=[\x21-\x7e]+)[^A-Za-z0-9])");
		len = re.test(value);
		if (len) {
			return true;
		}
		return false;
	}, "<spring:message code='common.account.password.rule'/>");
</script>
</html>
