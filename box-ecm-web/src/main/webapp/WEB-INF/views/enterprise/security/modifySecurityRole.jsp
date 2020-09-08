<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="modifyAdminForm" name="modifyAdminForm">
   	        <input type="hidden" id="id" name="id" value="<c:out value='${securityRole.id}'/>"  class="span4" />
   	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='common.name'/>:</label>
	            <div class="controls">
	                <input type="text" id="roleName" name="roleName"  value="<c:out value='${securityRole.roleName}'/>" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	        	<label class="control-label" for=""><spring:message code='common.description'/>:</label>
	            <div class="controls">
	                <textarea name="roleDesc" class="span4" id="roleDesc" maxlength="255"><c:out value='${securityRole.roleDesc}'/></textarea>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function() {
		$("#modifyAdminForm").validate({ 
			rules: { 
				   roleName: { 
					   required:true, 
					   maxlength:[128]
				   },
				   roleDesc:{
					   maxlength:[255]
				   }
			}
	    }); 
		$("label").tooltip({ container:"body", placement:"top", delay: { show: 100, hide: 0 }, animation: false });
});

function submitModifyAdminUser() {
	if(!$("#modifyAdminForm").valid()) {
        return false;
    }  
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/modifySecurityRole/<c:out value='${appId}'/>/",
        data:$('#modifyAdminForm').serialize(),
        error: function(request) {
        	handlePrompt("error",'<spring:message code="common.modifyFail"/>');
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
        	top.window.frames[0].initDataList(1);
        }
    });
}

</script>
</body>
</html>
