<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><spring:message code="user.manager.modifyUser"/></title>
<%@ include file="../../../common/common.jsp"%>
<style>
.form-horizontal .hidden-input{ display:none;}
</style>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="updateUserForm">
		<p style="padding-bottom:20px;"><spring:message code="user.tag.updateDesc"/></p>
        <div class="control-group">
        	<label class="control-label" for="">
        		<input type="checkbox" class="pull-left" id="isRegionId" name="isRegionId" value=""/>
        		<spring:message code="user.manager.labelRegion"/>
        	</label>
            <div class="controls">
                <select class="span3"  name="regionId">
                    <c:forEach items="${regionList}" var="region">
        				<option value="<c:out value='${region.id}'/>" <c:if test="${user.regionId == region.id}">selected="selected"</c:if>><c:out value='${region.name}'/></option>
        			</c:forEach>
                </select>
            </div>
        </div>
        <div class="control-group">
        	<label class="control-label" for="">
        		<input type="checkbox" class="pull-left" id="isSpaceQuota" name="isSpaceQuota" value=""/>
        		<spring:message code="createUser.spaceQuote"/>
        	</label>
            <div class="controls">
                <label class="checkbox inline"><input type="checkbox" <c:if test="${user.spaceQuota == -1}">checked="checked"</c:if> id="spaceQuotaCheckBox" name="spaceQuotaCheckBox"/><spring:message code="basicConfig.limit"/></label>
                <input class="span2 ${user.spaceQuota == -1 ? "hidden-input" : ""}" type="text" id="spaceQuotaInput" name="spaceQuotaInput"/>
                <span class="validate-con bottom inline-span2"><div></div></span>
            </div>
        </div>
        <div class="control-group">
        	<label class="control-label" for="">
        		<input type="checkbox" class="pull-left" id="isMaxVersions" name="isMaxVersions" value=""/>
        		<spring:message code="createUser.maxVersionNumber"/>:
        	</label>
            <div class="controls">
                <label class="checkbox inline"><input type="checkbox" <c:if test="${user.maxVersions == -1}">checked="checked"</c:if> id="maxVersionsCheckBox" name="maxVersionsCheckBox"/><spring:message code="basicConfig.limit"/></label>
                <input class="span2 ${user.maxVersions == -1 ? "hidden-input" : ""}" type="text" id="maxVersionsInput" name="maxVersionsInput"/>
                <span class="validate-con bottom inline-span2"><div></div></span>
            </div>
        </div>
        <div class="control-group">
        		<label class="control-label" for="">
	        		<input type="checkbox" class="pull-left" id="isUploadBandWidthInput" name="isUploadBandWidthInput" value=""/>
	        		<spring:message code="user.uploadBandWidth"/>
        		</label>
	            <div class="controls">
	            	<label class="checkbox inline"><input type="checkbox" <c:if test="${user.uploadBandWidth == -1}">checked="checked"</c:if> id="uploadBandWidthCheckBox" name="uploadBandWidthCheckBox"/><spring:message code="basicConfig.limit"/></label>
	                <input class="span2 ${user.uploadBandWidth == -1 ? "hidden-input" : ""}" type="text" id="uploadBandWidthInput" name="uploadBandWidthInput"/>
	                <span class="validate-con bottom inline-span2"><div></div></span>
	            </div>          
        </div>
        <div class="control-group">
        		<label class="control-label" for="">
	        		<input type="checkbox" class="pull-left" id="isDownloadBandWidthInput" name="isDownloadBandWidthInput" value=""/>
	        		<spring:message code="user.downloadBandWidth"/>
        		</label>
	            <div class="controls">
	            	<label class="checkbox inline"><input type="checkbox" <c:if test="${user.downloadBandWidth == -1}">checked="checked"</c:if> id="downloadBandWidthCheckBox" name="downloadBandWidthCheckBox"/><spring:message code="basicConfig.limit"/></label>
	                <input class="span2 ${user.downloadBandWidth == -1 ? "hidden-input" : ""}" type="text" id="downloadBandWidthInput" name="downloadBandWidthInput"/>
	                <span class="validate-con bottom inline-span2"><div></div></span>
	            </div>          
        </div>
        <div class="control-group">
	            <label class="control-label" for="input">
        			<input type="checkbox" class="pull-left" id="isTeamSpaceFlag" name="isTeamSpaceFlag" value="" onclick="changeTeamSpaceFlag()"/>
        			<spring:message code="user.manager.labelIsTeam"/>:
        		</label>
	            <div class="controls">
	                <label class="checkbox" for="input"><input type="checkbox" id="teamSpaceFlag" name="teamSpaceFlag" value="" onclick="changeTeamSpaceFlag()"/><spring:message code="user.manager.isCreateTeam"/></label>
	            </div>
	   </div>
        <div class="control-group">
        	<label class="control-label" for="">
        		<input type="checkbox" class="pull-left" id="isTeamSpaceMaxNum" name="isTeamSpaceMaxNum" value="" disabled=”disabled“/>
        		<spring:message code="createUser.teamspaceMaxNUm"/>:
        	</label>
            <div class="controls">
                <label class="checkbox inline"><input type="checkbox" <c:if test="${user.teamSpaceMaxNum == -1}">checked="checked"</c:if> id="teamSpaceMaxNumCheckBox" name="teamSpaceMaxNumCheckBox"/><spring:message code="basicConfig.limit"/></label>
                <input class="span2 ${user.teamSpaceMaxNum == -1 ? "hidden-input" : ""}" type="text" id="teamSpaceMaxNumInput" name="teamSpaceMaxNumInput"/>
                <span class="validate-con bottom inline-span2"><div></div></span>
            </div>
        </div>
	   <input type="hidden" id="userIds" name="userIds"/>
	   <input type="hidden" id="selLdapDn" name="selLdapDn"/>
	   <input type="hidden" id="selStatus" name="selStatus"/>
	   <input type="hidden" id="selFilter" name="selFilter"/>
	   <input type="hidden" id="spaceQuota" name="spaceQuota"/>
	   <input type="hidden" id="maxVersions" name="maxVersions"/>
	   <input type="hidden" id="teamSpaceMaxNum" name="teamSpaceMaxNum"/>
	   <input type="hidden" id="uploadBandWidth" name="uploadBandWidth"/>
        <input type="hidden" id="downloadBandWidth" name="downloadBandWidth"/>
        <input type="hidden" id="authServerId" name="authServerId"/>
        <input type="hidden" id="appId" name="appId"/>
        <input type="hidden" id="token" name="token" value="${token}"/>	
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function(){
	$(".control-label").parent().css("color","#999").end().next().find(":text,select,:checkbox").attr("disabled","disabled");
	$(".control-label input").click(function(){
		if(this.checked){
			$(this).parent().parent().css("color","#333").end().next().find(":text,select,:checkbox").removeAttr("disabled");
		}else{
			$(this).parent().parent().css("color","#999").end().next().find(":text,select,:checkbox").attr("disabled","disabled");
		}
	})
});

function changeTeamSpaceFlag()
{
	var isTeamSpace=$("#teamSpaceFlag").get(0).checked;
	var isTeamSpaceFlag=$("#isTeamSpaceFlag").get(0).checked;
	if((isTeamSpace==true||isTeamSpace=="true") && (isTeamSpaceFlag==true||isTeamSpaceFlag=="true"))
	{
		$("#teamSpaceFlag").val("0");
		$("#isTeamSpaceMaxNum").removeAttr("disabled");
	}
	else
	{
		$("#teamSpaceFlag").val("1");
		$("#isTeamSpaceMaxNum").attr("disabled","disabled");
	}
}
function submitUser(ids,selTag,selStatus,selFilter,selLdapDn,authServerId,appId) 
{
	validateUserInfo();
	if(!$("#updateUserForm").valid()) 
	{
        return;
    }
	var url="${ctx}/enterprise/admin/accountuser/updateUserList";
	$("#userIds").val(ids);
	$("#selStatus").val(selStatus);
	$("#selFilter").val(selFilter);
	$("#selLdapDn").val(selLdapDn);
	$("#authServerId").val(authServerId);
	$("#appId").val(appId);
	fillChecked();
	setParameter();
	$.ajax({
        type: "POST",
        url:url,
        data:$('#updateUserForm').serialize(),
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
function fillChecked()
{
	var isRegionId=$("#isRegionId").get(0).checked;
	var isSpaceQuota=$("#isSpaceQuota").get(0).checked;
	var isMaxVersions=$("#isMaxVersions").get(0).checked;
	var isTeamSpaceFlag=$("#isTeamSpaceFlag").get(0).checked;
	var isTeamSpaceMaxNum=$("#isTeamSpaceMaxNum").get(0).checked;
	var isUploadBandWidthInput=$("#isUploadBandWidthInput").get(0).checked;
	var isDownloadBandWidthInput=$("#isDownloadBandWidthInput").get(0).checked;
	if(isRegionId==true||isRegionId=="true")
	{
		$("#isRegionId").val(true);
	}
	if(isSpaceQuota==true||isSpaceQuota=="true")
	{
		$("#isSpaceQuota").val(true);
	}
	if(isMaxVersions==true||isMaxVersions=="true")
	{
		$("#isMaxVersions").val(true);
	}
	if(isTeamSpaceFlag==true||isTeamSpaceFlag=="true")
	{
		$("#isTeamSpaceFlag").val(true);
	}
	if(isTeamSpaceMaxNum==true||isTeamSpaceMaxNum=="true")
	{
		$("#isTeamSpaceMaxNum").val(true);
	}
	if(isUploadBandWidthInput==true||isUploadBandWidthInput=="true")
	{
		$("#isUploadBandWidthInput").val(true);
	}
	if(isDownloadBandWidthInput==true||isDownloadBandWidthInput=="true")
	{
		$("#isDownloadBandWidthInput").val(true);
	}
}
function validateUserInfo()
{
		$("#updateUserForm").validate({ 
		rules: {
				spaceQuotaInput: {
				   digits:true,
				   max:999999,
				   min:1
			   },
			   maxVersionsInput: {
				   digits:true,
				   max:10000,
				   min:1
			   },
			   teamSpaceMaxNumInput: {
				   digits:true,
				   max:10000,
				   min:1
			   },
			   uploadBandWidthInput: {
				   digits:true,
				   max:999999,
				   min:100
			   },
			   downloadBandWidthInput: {
				   digits:true,
				   max:999999,
				   min:100
			   }
		}
    });
}
function refreshWindow(appId,authServerId) {
	top.window.frames[0].location = "${ctx}/enterprise/admin/accountuser/list/"+appId+"/"+authServerId;
}
$("#uploadBandWidthCheckBox").click(function(){ 
	if(this.checked){
		$('#uploadBandWidthInput').addClass("hidden-input")
		.val("")
		.next().find("> div > span").remove();
	}else{ 
		$('#uploadBandWidthInput').removeClass("hidden-input");
		$('#uploadBandWidthInput').val("");
	}
});
$("#downloadBandWidthCheckBox").click(function(){ 
	if(this.checked){
		$('#downloadBandWidthInput').addClass("hidden-input")
		.val("")
		.next().find("> div > span").remove();
	}else{ 
		$('#downloadBandWidthInput').removeClass("hidden-input");
		$('#downloadBandWidthInput').val("");
	}
});
$("#maxVersionsCheckBox").click(function(){ 
	if(this.checked){
		$('#maxVersionsInput').addClass("hidden-input")
		.val("")
		.next().find("> div > span").remove();
	}else{ 
		$('#maxVersionsInput').removeClass("hidden-input");
		$('#maxVersionsInput').val("");
	}
});
$("#teamSpaceMaxNumCheckBox").click(function(){ 
	if(this.checked){
		$('#teamSpaceMaxNumInput').addClass("hidden-input")
		.val("")
		.next().find("> div > span").remove();
	}else{ 
		$('#teamSpaceMaxNumInput').removeClass("hidden-input");
		$('#teamSpaceMaxNumInput').val("");
	}
});
$("#spaceQuotaCheckBox").click(function(){ 
	if(this.checked){
		$('#spaceQuotaInput').addClass("hidden-input")
		.val("")
		.next().find("> div > span").remove();
	}else{ 
		$('#spaceQuotaInput').removeClass("hidden-input");
		$('#spaceQuotaInput').val("");
	}
});
function setParameter(){
	$("#uploadBandWidth").val($("#uploadBandWidthInput").val() == "" ? -2 : $("#uploadBandWidthInput").val());
	$("#downloadBandWidth").val($("#downloadBandWidthInput").val() == "" ? -2 : $("#downloadBandWidthInput").val());
	$("#maxVersions").val($("#maxVersionsInput").val());
	$("#teamSpaceMaxNum").val($("#teamSpaceMaxNumInput").val());
	$("#spaceQuota").val($("#spaceQuotaInput").val());
	var isSpaceQuotaCheckBox=$("#spaceQuotaCheckBox").get(0).checked
	var isUploadBandWidthCheckBox=$("#uploadBandWidthCheckBox").get(0).checked
	var isDownloadBandWidthCheckBox=$("#downloadBandWidthCheckBox").get(0).checked
	var isMaxVersionsCheckBox=$("#maxVersionsCheckBox").get(0).checked
	var isTeamSpaceMaxNumCheckBox=$("#teamSpaceMaxNumCheckBox").get(0).checked
	if(isSpaceQuotaCheckBox==true||isSpaceQuotaCheckBox=="true")
	{
		$("#spaceQuota").val(-1);
	}
	if(isUploadBandWidthCheckBox==true||isUploadBandWidthCheckBox=="true")
	{
		$("#uploadBandWidth").val(-1);
	}
	if(isDownloadBandWidthCheckBox==true||isDownloadBandWidthCheckBox=="true")
	{
		$("#downloadBandWidth").val(-1);
	}
	if(isMaxVersionsCheckBox==true||isMaxVersionsCheckBox=="true")
	{
		$("#maxVersions").val(-1);
	}
	if(isTeamSpaceMaxNumCheckBox==true||isTeamSpaceMaxNumCheckBox=="true")
	{
		$("#teamSpaceMaxNum").val(-1);
	}
}
</script>
</body>
</html>
