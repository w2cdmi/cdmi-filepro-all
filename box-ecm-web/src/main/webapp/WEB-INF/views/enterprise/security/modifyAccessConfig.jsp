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
	        	<label class="control-label" for=""><em>*</em><spring:message code="accessconfig.saferolename"/>:</label>
	            <div class="controls">
	                <select class="span4" id="safeRoleId" name="safeRoleId">
	                <option value="-1" <c:if test="${accessConfig.safeRoleId == oper.id}">selected="selected"</c:if>><spring:message code='security.role.any'/></option>
        		<c:forEach items="${safeRoleList}" var="oper">
        			<option value="<c:out value='${oper.id}'/>" <c:if test="${accessConfig.safeRoleId == oper.id}">selected="selected"</c:if>><c:out value='${oper.roleName}'/></option>
        		</c:forEach>
			</select>
	            </div>
	        </div>
   	
   	   	   <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code="accessconfig.netregionname"/>:</label>
	            <div class="controls">
	                <select class="span4" id="netRegionId" name="netRegionId">
	                <option value="-1" <c:if test="${accessConfig.safeRoleId == oper.id}">selected="selected"</c:if>><spring:message code='network.region.any'/></option>
        		<c:forEach items="${netRegionList}" var="oper">
        			<option value="<c:out value='${oper.id}'/>" <c:if test="${accessConfig.netRegionId == oper.id}">selected="selected"</c:if>><c:out value='${oper.netRegionName}'/></option>
        		</c:forEach>
			</select>
	            </div>
	        </div>
	        
	        <div class="control-group" id ="downloadResourceType">
   	        <label class="control-label" for=""><em>*</em><spring:message code="accessconfig.download.resource.type"/>:</label>
   	        <div class="controls">
   	           <label class="checkbox inline"><input type="checkbox" id="default1" name="default1" value="-1" onclick="changePermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        		<input type="checkbox" value="<c:out value='${oper.id}'/>"><c:out value='${oper.safeLevelName}'/></input>
        		</c:forEach>
            	</div>
            </div>
            
            <div class="control-group" id ="previewResourceType">
   	        <label class="control-label" for=""><em>*</em><spring:message code="accessconfig.preview.resource.type"/>:</label>
   	        <div class="controls">
   	          <label class="checkbox inline"><input type="checkbox" id="default2" name="default2" value="-1" onclick="changePreviewPermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        		<input type="checkbox" value="<c:out value='${oper.id}'/>"><c:out value='${oper.safeLevelName}'/></input>
        		</c:forEach>
            	</div>
            </div>
	        
	        <input type="hidden" id="id" name="id" value="<c:out value='${accessConfig.id}'/>" />
	        
	        	        <input type="hidden" id="downLoadResrouceTypeIds" name="downLoadResrouceTypeIds" value="" />
	        <input type="hidden" id="previewResourceTypeIds" name="previewResourceTypeIds" value="" />
	        <input type="hidden" id="token" name="token" value="${token}"/>
	</form>
    </div>
</div>
<script type="text/javascript">  
$(document).ready(function() {
	var checkBox = null;
	var id = "";
	var checkBoxList = $("#downloadResourceType input[type='checkbox']");
	var downLoadResrouceTypeIds = "<c:out value='${downLoadResrouceTypeIds}'/>".split(",");
	for(var i = 0 ; i < checkBoxList.length ; i++){
		for(var j = 0 ; j < downLoadResrouceTypeIds.length ; j++){
			if(checkBoxList[i].value==downLoadResrouceTypeIds[j]){
				checkBoxList[i].checked=true;
			}
		}
	}
	var downloadAllCheckboxObj = $("input[name='default1']:checkbox");
	if(downloadAllCheckboxObj[0].checked == true){
		$("#downloadResourceType input[type='checkbox']").attr("disabled", true);
		$("#downloadResourceType input[name='default1']").attr("disabled", false);
	}
	
	var checkBoxListPreviewResourceType = $("#previewResourceType input[type='checkbox']");
	var previewResourceTypeIds = "<c:out value='${previewResourceTypeIds}'/>".split(",");
	for(var i = 0 ; i < checkBoxListPreviewResourceType.length ; i++){
		for(var j = 0 ; j < previewResourceTypeIds.length ; j++){
			if(checkBoxListPreviewResourceType[i].value==previewResourceTypeIds[j]){
				checkBoxListPreviewResourceType[i].checked=true;
			}
		}
	}
	var previewAllCheckboxObj = $("input[name='default2']:checkbox");
	if(previewAllCheckboxObj[0].checked == true){
		$("#previewResourceType input[type='checkbox']").attr("disabled", true);
		$("#previewResourceType input[name='default2']").attr("disabled", false);
	}
	
});

function submitModify() {
	var previewResourceTypeIds = getPreviewResourceTypeIds();
	var downLoadResrouceTypeIds = getDownLoadResrouceTypeIds();
	$("#downLoadResrouceTypeIds").val(downLoadResrouceTypeIds);
	$("#previewResourceTypeIds").val(previewResourceTypeIds);
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/modifyAccessConfig/<c:out value='${appId}'/>/",
        data:$('#creatForm').serialize(),
        error: function(request) {
				 	handlePrompt("error",'<spring:message code="admin.create.err"/>');
        },
        success: function(data) {
        	if(data == "AlreadyDomainNameOrContactEmail")
        	{
        		handlePrompt("error",'<spring:message code="common.modifyFail"/>');
        	}
        	else
        	{	
        	    top.ymPrompt.close();
        	    top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
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

</script>
</body>
</html>
