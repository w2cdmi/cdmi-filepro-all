<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/common.jsp"%>
<style>
	.pop-content{
		width: 670px;
		min-height: 180px;
	}
	.controls{
		
		margin-left: 145px;
	}
	.validate-con{
		display: block;
		height: 25px;
		margin-left: 82px;
	}
	.form-con{
		margin-top: 16px;
	}
	.error{
		color: #FF6600;
	}
    #errorMessage {
        margin-left: 230px;
        color: #FF6600;
    }
</style>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="modifyPwdForm">
        <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
			<button class="close" data-dismiss="alert">×</button><spring:message code="initChgPwd.modifyFail"/>
		</div>
        <div class="control-group">
            <div class="controls">
            	<label style="margin-left: 28px;" class="control-label" for="oldPasswd"><em>*</em><spring:message code="initChgPwd.oldPwd"/>:</label>
                <input style="width: 280px;" class="span4" type="password" id="oldPasswd" name="oldPasswd" value="" autocomplete="off"/>
                <span class="validate-con bottom"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <div class="controls">
            	<label style="margin-left: 28px;" class="control-label" for="password"><em>*</em><spring:message code="authorize.newPwd"/></label>
                <input class="span4" style="width: 280px;" type="password" id="password" name="password" value="" autocomplete="off"/>
                <span class="validate-con bottom"><div></div></span>
            </div>
        </div>
		<div class="control-group">
            <div class="controls">
            	<label class="control-label" for="confirmPassword"><em>*</em><spring:message code="authorize.confirmNewPwd"/></label>
                <input style="width: 280px;" class="span4" type="password" id="confirmPassword" name="confirmPassword" value="" autocomplete="off"/>
                <span class="validate-con bottom"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <div class="controls" id="errorMessage">
            </div>
        </div>
        <input type="hidden" id="token" name="token" value="<c:out value='${token}'/>"/>
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	$("#modifyPwdForm").validate({ 
		rules: { 
			   oldPasswd: { 
				   required:true
			   },
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
function submitModifyPwd() {
    $("#errorMessage").text("");
	var oldP = $.trim($("#oldPasswd").val());
	$("#oldPasswd").val(oldP);
	if(!$("#modifyPwdForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        url:"${ctx}/account/changePwd",
        data:$('#modifyPwdForm').serialize(),
        error: function(request) {
        	switch(request.responseText)
			{
				case "PasswordInvalidException":
				    $("#errorMessage").text('<spring:message code="initChgPwd.noneComplex"/>');
					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val(""); 
					break;
				case "OldPasswordErrorException":
                    $("#errorMessage").text('<spring:message code="initChgPwd.errOldPwd"/>');
					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val(""); 
					break;
				case "PasswordSameException":
                    $("#errorMessage").text('<spring:message code="initChgPwd.errOldEqualsNewPwd"/>');
					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				case "UserLockedException":
                    $("#errorMessage").text('<spring:message code="initChgPwd.lockmodifypasswd"/>');
					$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val("");
					break;
				default:
                    $("#errorMessage").text('<spring:message code="common.modifyFail"/>');
				   	$("#oldPasswd").val("");
					$("#password").val("");
					$("#confirmPassword").val(""); 
				    break;
			}
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
        }
    });
}
</script>
</body>
</html>
