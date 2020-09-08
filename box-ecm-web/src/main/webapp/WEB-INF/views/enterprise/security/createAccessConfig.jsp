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
	                <select class="span4" id="safeRoleId" name="safeRoleId">
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
   	        <label class="control-label" for=""><spring:message code="accessconfig.download.resource.type"/>:</label>
   	        <div class="controls" id ="downloadResourceType">
   	           <label class="checkbox inline"><input type="checkbox" id="default1" name="default1" value="-1" onclick="changePermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        			<label class="checkbox inline"><input type="checkbox" value="<c:out value='${oper.id}'/>" /> <c:out value='${oper.safeLevelName}'/></label>
        		</c:forEach>
            	</div>
            </div>
            
            <div class="control-group" id ="previewResourceType">
   	        <label class="control-label" for=""><spring:message code="accessconfig.preview.resource.type"/>:</label>
   	        <div class="controls">
   	           <label class="checkbox inline"><input type="checkbox" id="default2" name="default2" value="-1" onclick="changePreviewPermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        		<label class="checkbox inline"><input type="checkbox" value="<c:out value='${oper.id}'/>"/><c:out value='${oper.safeLevelName}'/></label>
        		</c:forEach>
            	</div>
            </div>
	        
	        <input type="hidden" id="downLoadResrouceTypeIds" name="downLoadResrouceTypeIds" value="" />
	        <input type="hidden" id="previewResourceTypeIds" name="previewResourceTypeIds" value="" />
	        <input type="hidden" id="token" name="token" value="${token}"/>
	</form>
    </div>
</div>
<script type="text/javascript">  
$(document).ready(function() {
});
		
function changePermission() {
	var checkBoxList = $("input[name='default1']:checkbox");
	if(checkBoxList[0].checked == true){
		$("#downloadResourceType input[type='checkbox']").attr("disabled", true);
		$("#downloadResourceType input[type='checkbox']").attr("checked", false);
		$("#downloadResourceType input[name='default1']").attr("disabled", false);
		checkBoxList[0].checked = true;
	}else{
		$("#downloadResourceType input[type='checkbox']").attr("disabled", false);
	}
}
function changePreviewPermission() {
	var checkBoxList = $("input[name='default2']:checkbox");
	if(checkBoxList[0].checked == true){
		$("#previewResourceType input[type='checkbox']").attr("disabled", true);
		$("#previewResourceType input[type='checkbox']").attr("checked", false);
		$("#previewResourceType input[name='default2']").attr("disabled", false);
		checkBoxList[0].checked = true;
	}else{
		$("#previewResourceType input[type='checkbox']").attr("disabled", false);
	}
}

function submitCreate() {
	var previewResourceTypeIds = getPreviewResourceTypeIds();
	var downLoadResrouceTypeIds = getDownLoadResrouceTypeIds();
	$("#downLoadResrouceTypeIds").val(downLoadResrouceTypeIds);
	$("#previewResourceTypeIds").val(previewResourceTypeIds);
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createAccessConfig/<c:out value='${appId}'/>/",
        data:$('#creatForm').serialize(),
        error: function(data) {
        	if(data.status==409){
        		handlePrompt("error",'<spring:message code="accessconfig.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}	
        },
        success: function(data) {
        	if(data == "ExistAccessConfigConflict")
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


function getPreviewResourceTypeIds(){
	var permissionCodeList = "";
	var checkBoxList = $("#previewResourceType input[type='checkbox']");
	for(var i = 0 ; i < checkBoxList.length ; i++){
		if(checkBoxList[i].checked == true){
			permissionCodeList += (checkBoxList[i].value + ",");
		}
	}
	permissionCodeList = permissionCodeList.substring(0, permissionCodeList.length - 1);
	return permissionCodeList;
}

function getDownLoadResrouceTypeIds(){
	var permissionCodeList = "";
	var checkBoxList = $("#downloadResourceType input[type='checkbox']");
	for(var i = 0 ; i < checkBoxList.length ; i++){
		if(checkBoxList[i].checked == true){
			permissionCodeList += (checkBoxList[i].value + ",");
		}
	}
	permissionCodeList = permissionCodeList.substring(0, permissionCodeList.length - 1);
	return permissionCodeList;
}



</script>
</body>
</html>
