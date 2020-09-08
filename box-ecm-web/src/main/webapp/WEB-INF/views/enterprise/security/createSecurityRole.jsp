<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="creatEnterpriseForm" name="creatEnterpriseForm">
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='common.name'/>:</label>
	            <div class="controls">
	                <input type="text" id="roleName" name="roleName" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	         <div class="control-group">
	        	<label class="control-label" for=""><spring:message code='common.description'/>:</label>
	            <div class="controls">
	                <textarea name="roleDesc" class="span4" id="roleDesc" maxlength="255"></textarea>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	</form>
    </div>
</div>
<script type="text/javascript">  
$(document).ready(function() {
		$("#creatEnterpriseForm").validate({ 
			rules: { 
				   roleName:{
					   required:true, 
					   maxlength:[128]
				   },
				   roleDesc: { 
					   maxlength:[255]
				   }
			}
	    });
});

function submitCreate() {
	if(!$("#creatEnterpriseForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createSecurityRole/<c:out value='${appId}'/>/",
        data:$('#creatEnterpriseForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="security.role.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}	
        },
        success: function(data) {
        	if(data == "AlreadyDomainNameOrContactEmail")
        	{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}
        	else
        	{	
        	    top.ymPrompt.close();
        	    top.handlePrompt("success",'<spring:message code="common.createSuccess"/>');
        	    top.window.frames[0].initDataList(1);
        	}
        }
    });
}

</script>
</body>
</html>
