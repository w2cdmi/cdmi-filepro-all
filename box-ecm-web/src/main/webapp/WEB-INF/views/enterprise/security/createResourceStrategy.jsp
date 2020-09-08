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
   	<form class="form-horizontal" id="creatForm" name="creatForm">
	        
	        
	        <div class="control-group">
	        	<label class="control-label" for=""><spring:message code="accessconfig.saferolename"/>:</label>
	            <div class="controls">
	                <select class="span4" id="securityRoleId" name="securityRoleId">
	                <option value="-1"><spring:message code='security.role.any'/></option>
        		<c:forEach items="${safeRoleList}" var="oper">
        			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
        		</c:forEach>
			</select>
	            </div>
	        </div>
   	
   	   	   <div class="control-group">
	        	<label class="control-label" for=""><spring:message code="accessconfig.netregionname"/>:</label>
	            <div class="controls">
	                <select class="span4" id="netRegionId" name="netRegionId">
	                <option value="-1"><spring:message code='network.region.any'/></option>
        		<c:forEach items="${netRegionList}" var="oper">
        			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.netRegionName}'/></option>
        		</c:forEach>
			</select>
	            </div>
	        </div>
	        
	           	
   	   	   <div class="control-group">
	        	<label class="control-label" for=""><spring:message code="security.resource.safe.level"/>:</label>
	            <div class="controls">
	                <select class="span4" id="resourceSecurityLevelId" name="resourceSecurityLevelId">
        		<c:forEach items="${safeLevelList}" var="oper">
        			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.safeLevelName}'/></option>
        		</c:forEach>
			</select>
	            </div>
	        </div>
	         <div class="control-group">
	        	<div class="controls">
	        		<spring:message code="upload.security.level.create.rule.desc"/>
	        	</div>
	        </div>
	        
	        <input type="hidden" id="strRlues" name="strRlues" class="span4" />
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	</form>
    </div>
</div>
<script type="text/javascript">  
function submitCreate() {
	var securityRoleId = $("#securityRoleId").val();
	var resourceSecurityLevelId = $("#resourceSecurityLevelId").val();
	if(resourceSecurityLevelId==null||resourceSecurityLevelId=="null"){
		handlePrompt("error",'<spring:message code="upload.security.level.create.rule.resourceSecurityLevelId.notnull"/>');
		return;
	}
	var netRegionId = $("#netRegionId").val();
	if(securityRoleId==-1&&netRegionId==-1){
		handlePrompt("error",'<spring:message code="upload.security.level.create.rule.desc"/>');
		return;
	}

	
	if(!$("#creatForm").valid()) {
        return false;
    }

	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createResourceStrategy/<c:out value='${appId}'/>/",
        data:$('#creatForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="upload.security.level.conflict"/>');
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
        	    window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
        	}
        }
    });
}

</script>
</body>
</html>
