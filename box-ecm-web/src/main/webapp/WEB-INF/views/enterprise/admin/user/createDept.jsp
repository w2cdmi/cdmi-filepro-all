<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@ include file="../../../common/common.jsp"%>
<style>
.form-horizontal .hidden-input{ display:none;}
</style>
</head>
<body><%-- value="${dept.name}" --%>
<div class="pop-content pop-content-en">
	<div class="form-con">
   	<form class="form-horizontal" id="creatUserForm" name="creatUserForm">
        <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
			<button class="close" data-dismiss="alert">×</button><spring:message code="user.manager.createUserFailed"/>
		</div>
		<c:if test="${!empty dept}">
			<div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code="createDept.super"/></label>
	            <div class="controls">
	                <input name="parentid" type="radio" value="${dept.parentid}">&nbsp;&nbsp;<spring:message code="createDept.currentDept"/>
	                &nbsp;&nbsp;&nbsp;<input name="parentid" type="radio" value="${dept.id}" checked="checked">&nbsp;&nbsp;<spring:message code="createDept.sonDept"/>
	            </div>
	        </div>
        </c:if>
         <div class="control-group">
        	<label class="control-label" for=""><em>*</em><spring:message code="createDept.deptName"/></label>
            <div class="controls">
                <input type="text" id="name" name="name" onfocus="disappear()" onblur="isValidDeptName()" maxlength="11"/>
                <span class="validate-con bottom inline-span3">
	                <div style="color:#EA5200">
	                <span id="isValidDeptNameSpan">
	               		<span for="name" class="error" id="isValidDeptName" style="display: none;">
	               			<spring:message code="enterprise.user.login.name"/>
	               		</span>
	               	</span>
	                </div>
                </span>
            </div>
        </div>
        <div class="control-group">
        	<label class="control-label" for=""><em>*</em><spring:message code="createDept.authServer"/></label>
            <div class="controls">
                <input type="text" id="domain" name="domain" maxlength="127" value="local"/>
                <span class="validate-con bottom inline-span3"><div></div></span>
            </div>
        </div>

        <div class="control-group" style="display:none">
        	<label class="control-label" for=""><spring:message code="createDept.state"/></label>
            <div class="controls">
                <input type="text" id="state" name="state" value="0"/>
                <span class="validate-con bottom inline-span3"><div></div></span>
            </div>
        </div>
        <div class="control-group">
        	<label class="control-label" for=""><spring:message code="createDept.state"/></label>
            <div class="controls">
                <textarea class="span4" id="description" name="description" maxlength="255"></textarea>
                <span class="validate-con bottom inline-span4"><div></div></span>
            </div>
        </div>
        <input type="hidden" id="token" name="token" value="${token}"/>	
        <input type="hidden" id="parentid" name="parentid" value="0"/>	
	</form>
    </div>
</div>
<script type="text/javascript">


function submitUser() 
{
	if(!isValidDeptName()){
		return;
	}
	var url="${ctx}/enterprise/admin/organize/addDepartment";
	$.ajax({
        type: "POST",
        url:url,
        data:$('#creatUserForm').serialize(),
        error: function(request) {
        	var status = request.status;
        	if (status == 409) {
        		handlePrompt("error",'<spring:message code="createEnterprise.conflict.name.email"/>');
        	} else {
        		handlePrompt("error",'<spring:message code="user.manager.createUserFailed"/>');
        	}
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="createDept.createDeptSuccessed"/>');
        	refreshWindow();
        }
    });
}

function refreshWindow() {
	top.window.frames[0].location = "${ctx}/enterprise/admin/organize/enterDeptTreeManage/0";
}

function checkValidDeptName(){
	var ret = false;
	if($("#name").val().length>0 && $("#name").val().length<127){
		ret = true;
	}
    return ret;
}

function isValidDeptName(){
	if(!checkValidDeptName()){
		$("#isValidDeptName").removeAttr("style"); 
		$("#isValidDeptNameSpan").removeAttr("style"); 
		$("#isValidDeptName").html("<spring:message code='enterprise.user.login.name'/>"); 
	    return false;
	} 
	$("#isValidDeptName").attr("style","display: none"); 
	return true;
}
function disappear(){
	$("#isValidDeptName").attr("style","display: none"); 
}
</script>
</body>
</html>
