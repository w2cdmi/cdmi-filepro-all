<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<style type="text/css">
	.bus-info-style{
		width: 20%;
	}
</style>
</head>
<body>
	<div class="content">

		<div class="panel panel-default" style="margin: 15px">
			<div class="panel-body">
				<form id="enterpriseInfoForm" name="enterpriseInfoForm" class="form-horizontal" method="post" action="${ctx}/enterprise/manager/update">
					<div class="form-group">
						<label  for="name" class="col-sm-2 control-label"><spring:message code="enterpriseList.name" /></label>
						<div class="col-sm-2 bus-info-style">
							<input class="form-control" type="text" id="name" name="name" value="<c:out value='${enterprise.name}'/>"/> 
						</div>
					</div>
					<div class="form-group">
						<label  for="domainName" class="col-sm-2 control-label"><spring:message code="enterpriseList.domainName" /></label>
						<div class="col-sm-2 bus-info-style">
							<input class="form-control" type="text" id="domainName" name="domainName" value="<c:out value='${enterprise.domainName}'/>"/> 
						</div>
					</div>
					<div class="form-group">
						<label  for="contactEmail" class="col-sm-2 control-label"><spring:message code="enterpriseList.contactEmail" /></label>
						<div class="col-sm-2 bus-info-style">
							<input class="form-control" type="text" id="contactEmail" name="contactEmail"
								value="<c:out value='${enterprise.contactEmail}'/>" /> 
						</div>
					</div>
				
					
					<!--  新增员工登录密码复杂度设置         -->
					<div class="form-group">
						<label class="col-sm-2 control-label" for="pwdLevel"><spring:message code="enterpriseList.pwdLevel" /></label>
						<div class="col-sm-2 bus-info-style">
							<select name="pwdLevel" id="pid" onchange="gradeChange()" class="form-control">
								<option value="1"
									<c:if test="${enterprise.pwdLevel==null || enterprise.pwdLevel==1}">selected</c:if>><spring:message
										code="employeeManage.pwdLevel.senior" /></option>
								<option value="2"
									<c:if test="${enterprise.pwdLevel==2}">selected</c:if>><spring:message
										code="employeeManage.pwdLevel.midran" /></option>
								<option value="3"
									<c:if test="${enterprise.pwdLevel==3}">selected</c:if>><spring:message
										code="employeeManage.pwdLevel.primary" /></option>
							</select> <%-- <span id="pwdDescription" class="validate-con"><div>
									<spring:message
										code="employeeManage.pwdLevel.senior.description" />
								</div></span> --%>
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-2 control-label" for="contactPerson"><spring:message code="enterpriseList.contactPerson" /></label>
						<div class="col-sm-2 bus-info-style">
							<input class="form-control" type="text" id="contactPerson"name="contactPerson" value="<c:out value='${enterprise.contactPerson}'/>" /> 
						</div>
					</div>
					<div class="form-group">
						<label class="col-sm-2 control-label" for="contactPhone"><spring:message code="enterpriseList.contactPhone" /></label>
						<div class="col-sm-2 bus-info-style">
							<input class="form-control" type="text" id="contactPhone" name="contactPhone" value="<c:out value='${enterprise.contactPhone}'/>" /> 
						</div>
					</div>
					<div class="control-group" align="center">
						<div class="controls" style="text-align: left;margin-left: 22%;">
							<button id="submit_btn" type="button"
								onclick="updateEnterpriseInfo()" class="btn btn-primary">
								<spring:message code="common.save" />
							</button>
						</div>
					</div>
					<input type="hidden" name="token" value="${token}" />
				</form>
			</div>
		</div>

		<%-- <div class="alert"><i class="icon-lightbulb"></i><spring:message code="enterpriseAdmin.enterprise.info"/></div>
	<div class="form-horizontal form-con clearfix">
   	<form id="enterpriseInfoForm" name="enterpriseInfoForm" class="form-horizontal" method="post" action="${ctx}/enterprise/manager/update">
        
	</form> --%>
	</div>

</body>
<script type="text/javascript">

$(document).ready(function() {
		$("#enterpriseInfoForm").validate({
			rules: { 
				   name:{
					   required:true, 
					   maxlength:[255]
				   },
				   domainName: { 
				   	   required:true, 
				       maxlength:[64]
				   },
				   contactEmail: {
					   required:true, 
					   isValidEmail:true,
					   maxlength:[255]
				   },
				   contactPerson: {
					   maxlength:[255]
				   },
				   contactPhone: {
					   maxlength:[255],
					   contactPhoneCheck : true
				   }
			},
			messages : {
				contactPhone : {
					contactPhoneCheck : '<spring:message  code="enterpriseList.contactPhone.rule"/>'
				}
			},
	    }); 
		$.validator.addMethod(
				"contactPhoneCheck", 
				function(value, element) {  
					var pattern = /^[0-9 +-]*$/;
				    if(!pattern.test(value)){
				 	   return false;
				    }
				    return true;
				}
		); 
		
		var pageH = $("body").outerHeight();
		top.iframeAdaptHeight(pageH);
		$("button").tooltip({ container:"body", placement:"top", delay: { show: 100, hide: 0 }, animation: false });
		gradeChange();
});

function updateEnterpriseInfo() {
	if(!$("#enterpriseInfoForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        async:false,
        url:"${ctx}/enterprise/admin/changeEnterpriseInfo",
        data:$('#enterpriseInfoForm').serialize(),
        error: function(request) {
        	errorMessage(request);
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="common.saveSuccess"/>');
        	window.location.reload();
        }
    });
}

function errorMessage(request)
{
	switch(request.responseText)
	{
	 case "domainOrEmailConflict":
         handlePrompt("error",'<spring:message code="createEnterprise.conflict.domain.email"/>');
         break;
		case "userNameNotChange":
			handlePrompt("error",'<spring:message code="changeLoginName.usernameUnmodified"/>');
			break;
		case "repeatLoginName":
			handlePrompt("error",'<spring:message code="changeLoginName.userExist"/>');
			break;
		default:
			top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
		    break;
	}
}
//pwdLevel_Description
function gradeChange(){
	var objS = document.getElementById("pid");
    var grade = objS.options[objS.selectedIndex].value;
    switch(grade)
		{
		 	case "1":
		 		$("#pwdDescription").html('<div><spring:message code="employeeManage.pwdLevel.senior.description"/></div>');
	         break;
			case "2":
				$("#pwdDescription").html('<div style="width:500px"><spring:message code="employeeManage.pwdLevel.midran.description"/></div>');
				break;
			case "3":
				$("#pwdDescription").html('<div><spring:message code="employeeManage.pwdLevel.primary.description"/></div>');
				break;
			default:
			    break;
		}
   }
</script>
</html>
