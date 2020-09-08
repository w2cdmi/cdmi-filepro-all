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
   		<div id="addSpaceDiv">	        
	        <div class="control-group">
                <span><spring:message code="space.access.policy"/><a href="#"><spring:message code="space.access.example"/></a></span>
       	</div>
       	 <div class="control-group ">
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="space.access.visitor"/></p><br/>
                    <div class="control-new-label control-new-label-two">
                        <select class="span2" id="safeRoleId" name="safeRoleId" size="4">
	               	 <option value="-1" selected title="<spring:message code='security.role.any'/>" ><spring:message code="security.role.any"/></option>
        				<c:forEach items="${safeRoleList}" var="oper">
        					<option title="<c:out value='${oper.roleName}'/>"  value="<c:out value='${oper.id}'/>" <c:if test="${accessConfigList.safeRoleId == oper.id}">selected="selected"</c:if>><c:out value='${oper.roleName}'/></option>
        				</c:forEach>
					</select>
                    </div>
                </div>
                <div class="pull-left icon-add icon-add-two"><i class="icon-plus"></i></div>
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="space.title.netregionname"/></p><br/>
                    <div class="control-new-label control-new-label-two">
                         <select class="span2" id="netRegionId" name="netRegionId" size="4">
	               	 <option value="-1" selected title="<spring:message code='network.region.any'/>"><spring:message code="network.region.any"/></option>
        				<c:forEach items="${netRegionList}" var="oper">
        					<option title="<c:out value='${oper.netRegionName}'/>" value="<c:out value='${oper.id}'/>" <c:if test="${accessConfigList.netRegionId == oper.id}">selected="selected"</c:if>><c:out value='${oper.netRegionName}'/></option>
        				</c:forEach>
					</select>
                    </div>
                </div>
                <div class="pull-left icon-add icon-add-two"><i class="icon-plus"></i></div>
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="space.access.targetSafeRole"/></p><br/>
                    <div class="control-new-label control-new-label-two">
                        <select class="span2" id="targetSafeRoleId" name="targetSafeRoleId" size="4">
	                <option value="-1" selected title="<spring:message code='security.role.any'/>" ><spring:message code="security.role.any"/></option>
        				<c:forEach items="${targetSafeList}" var="oper">
        					<option title="<c:out value='${oper.roleName}'/>" value="<c:out value='${oper.id}'/>" <c:if test="${accessConfigList.targetSafeRoleId == oper.id}">selected="selected"</c:if>><c:out value='${oper.roleName}'/></option>
        				</c:forEach>
				</select>
                    </div>
                </div>
            </div>
            
            <div class="control-group control-group-two" id ="Permission">
   	        	<label for=""><spring:message code="space.access.operationtypename"/></label>
   	        
            	<label class="checkbox inline"><input type="checkbox" id="uploadCheckbox" name="uploadCheckbox" value="2" />
            		<spring:message code="space.access.upload"/>
            	</label>
            	<label class="checkbox inline"><input type="checkbox" id="newFolderCheckbox" name="newFolderCheckbox" value="5" />
            		<spring:message code="space.access.newfolder"/>
            	</label>
            	<label class="checkbox inline"><input type="checkbox" id="deleteCheckbox" name="deleteCheckbox" value="29" />
            		<spring:message code="space.access.delete"/>
            	</label>
            	<label class="checkbox inline"><input type="checkbox" id="browserCheckbox" name="browserCheckbox" value="23" />
            		<spring:message code="space.access.browser"/>
            	</label>
            	<label class="checkbox inline"><input type="checkbox" id="shareCheckbox" name="shareCheckbox" value="17" />
            		<spring:message code="space.access.share"/>
            	</label>            
            	<label class="checkbox inline"><input type="checkbox" id="linkCheckbox" name="linkCheckbox" value="19" />
            		<spring:message code="space.access.link"/>
            	</label>            
            	<label class="checkbox inline"><input type="checkbox" id="downloadCheckbox" name="downloadCheckbox" value="3" />
            		<spring:message code="space.access.download"/>&nbsp;&nbsp;<a href="#" onclick="openDownloadLevel()"><spring:message code="space.access.level"/></a>
            	</label>           
            	<label class="checkbox inline"><input type="checkbox" id="previewCheckbox" name="previewCheckbox" value="13" />
            		<spring:message code="space.access.preview"/>&nbsp;&nbsp;<a href="#" onclick="openPreviewLevel()"><spring:message code="space.access.level"/></a>
            	</label>
            </div> 
	        <div class="control-group">
                <label class="controls-strategy"><spring:message code="space.access.setpolicy"/></label>
                <div class="controls-strategy ">
                    <p><spring:message code="space.access.setpolicyHelp"/></p>
                </div>
            </div>
	        <div id="manageBtnCon" class="btn-con">
			    <button id="modifySpaceBtn" type="button" class="btn btn-primary" onclick="submitModify()"><spring:message code='common.modify'/></button>
			    <button id="cancelSpaceBtn" type="button" class="btn" onclick="submitCancel()"><spring:message code='common.cancel'/></button>
			</div>
	        <input type="hidden" id="operation" name="operation" value="" />
	        <input type="hidden" id="downLoadResrouceTypeIds" name="downLoadResrouceTypeIds" value="" />
	        <input type="hidden" id="previewResourceTypeIds" name="previewResourceTypeIds" value="" />
	        <input type="hidden" id="id" name="id" value="<c:out value='${accessConfigList.id}'/>" />
	        <input type="hidden" id="token" name="token" value="${token}"/>
        </div>
        
	</form>
	
	<form class="form-horizontal" id="creatDownloadForm" name="creatDownloadForm">
   	  <div id="addDownloadDiv" class="hide">
    	   <div class="control-group">
   	        <label class="control-label" for=""><spring:message code="accessconfig.download.resource.type"/>:</label>
   	        <div class="controls" id ="downloadResourceType">
   	           <label class="checkbox inline"><input type="checkbox" id="default1" name="default1" value="-1" onclick="changePermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        			<label class="checkbox inline"><input type="checkbox" value="<c:out value='${oper.id}'/>" /> <c:out value='${oper.safeLevelName}'/></label>
        		</c:forEach>
            	</div>
            </div>
	         <input type="hidden" id="id" name="id" value="<c:out value='${config.id}'/>" />
	        <input type="hidden" id="token" name="token" value="${token}"/>
	        <input type="hidden" id="downLoadResrouceTypeIds" name="downLoadResrouceTypeIds" value="" />
	        <div class="control-group">
		        	<div class="controls">
		        		<button type="button" class="btn" onclick="addDownloadFile()"><spring:message code='common.addbtn'/></button>
		        		<button type="button" class="btn" onclick="cancelWindow()"><spring:message code='common.cancel'/></button>
		        	</div>
	        </div>
        </div>
	</form> 
	
	<form class="form-horizontal" id="creatPreviewForm" name="creatPreviewForm">
  	   	<div id="addPreviewDiv" class="hide">
    	   <div class="control-group" id ="previewResourceType">
   	        <label class="control-label" for=""><spring:message code="accessconfig.preview.resource.type"/>:</label>
   	        <div class="controls">
   	           <label class="checkbox inline"><input type="checkbox" id="default2" name="default2" value="-1" onclick="changePreviewPermission()"/><spring:message code="common.select.all"/></label>
   	        	 <c:forEach items="${safeLevelList}" var="oper">
        		<label class="checkbox inline"><input type="checkbox" value="<c:out value='${oper.id}'/>"/><c:out value='${oper.safeLevelName}'/></label>
        		</c:forEach>
            	</div>
            </div>
	         <input type="hidden" id="id" name="id" value="<c:out value='${config.id}'/>" />
	        <input type="hidden" id="token" name="token" value="${token}"/>
	        <input type="hidden" id="previewResourceTypeIds" name="previewResourceTypeIds" value="" />
	        <div class="control-group">
		        	<div class="controls">
		        		<button type="button" class="btn" onclick="addPreviewFile()"><spring:message code='common.addbtn'/></button>
		        		<button type="button" class="btn" onclick="cancelWindow()"><spring:message code='common.cancel'/></button>
		        	</div>
		        </div>
        </div>
	</form>
	
    </div>
</div>
<script type="text/javascript">  
$(document).ready(function() {
	var permissionCodeList = "<c:out value='${accessConfig.operation}'/>";
	var array = permissionCodeList.split("、");
	var checkBox = null;
	var id = "";
	for(var i = 0 ; i < array.length ; i++){
		id = getFilePermissionId(array[i]);
		checkBox = $("#"+id+"Checkbox");
		checkBox.attr("checked", "checked");
	}
	
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
	
	if ($("input[name='downloadCheckbox']:checkbox")[0].checked == true) {
		var downLoadResrouceTypeIds = getDownLoadResrouceTypeIds();
		$("#downLoadResrouceTypeIds").val(downLoadResrouceTypeIds);
	} else {
		$("#previewResourceTypeIds").val("");
	}

	if ($("input[name='previewCheckbox']:checkbox")[0].checked == true) {
		var previewResourceTypeIds = getPreviewResourceTypeIds();
		$("#previewResourceTypeIds").val(previewResourceTypeIds);
	} else {
		$("#previewResourceTypeIds").val("");
	}
	
	var operationIdList = getSelected();
	$("#operation").val(operationIdList);
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/space/modifyAccessConfig/<c:out value='${appId}'/>/",
        data:$('#creatForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="space.tip.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.modifyFail"/>');
        	}	
        },
        success: function(data) {
      	    top.ymPrompt.close();
      	    top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
      	    window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
        }
    });
}

function submitCancel(){
	top.ymPrompt.close();
}


function getSelected(){
	var permissionCodeList = "";
	var checkBoxList = $("#Permission input[type='checkbox']");
	for(var i = 0 ; i < checkBoxList.length ; i++){
		if(checkBoxList[i].checked == true){
			permissionCodeList += (checkBoxList[i].value + ",");
		}
	}
	permissionCodeList = permissionCodeList.substring(0, permissionCodeList.length - 1);
	return permissionCodeList;
}

function getFilePermissionId(num){
	num = num - 0;
	var id = "";
	switch (num){
		case 2:
			id = "upload";
			break;
		case 5:
			id = "newFolder";
			break;
		case 3:
			id = "download";
			break;
		case 7:
			id = "copy";
			break;
		case 11:
			id = "move";
			break;
		case 13:
			id = "preview";
			break;
		case 17:
			id = "share";
			break;
		case 19:
			id = "link";
			break;
		case 23:
			id = "browser";
			break;
		case 29:
			id = "delete";
			break;
	}
	return id;
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

function openDownloadLevel() {
	$("#addDownloadDiv").show();
	$("#addSpaceDiv").hide();	
	$("#addPreviewDiv").hide();
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='space.access.canDownloadFile'/>");
}

function openPreviewLevel() {
	$("#addDownloadDiv").hide();
	$("#addSpaceDiv").hide();	
	$("#addPreviewDiv").show();
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='space.access.canPreviewFile'/>");
}

function addDownloadFile() {
	if($("input[name='downloadCheckbox']:checkbox")[0].checked == true){
		var downLoadResrouceTypeIds = getDownLoadResrouceTypeIds();
		$("#downLoadResrouceTypeIds").val(downLoadResrouceTypeIds);
	}

	cancelWindow();
}

function addPreviewFile() {
	if($("input[name='previewCheckbox']:checkbox")[0].checked == true){
		var previewResourceTypeIds = getPreviewResourceTypeIds();
		$("#previewResourceTypeIds").val(previewResourceTypeIds);
	}
	cancelWindow();
}

function cancelWindow() {
	$("#addDownloadDiv").hide();
	$("#addSpaceDiv").show();	
	$("#addPreviewDiv").hide();
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='accessconfig.space.update'/>");	
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
