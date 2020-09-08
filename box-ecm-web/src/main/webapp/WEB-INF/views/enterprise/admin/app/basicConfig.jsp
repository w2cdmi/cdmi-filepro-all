<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%request.setAttribute("token",CSRFTokenManager.getTokenForSession(session));%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js"type="text/javascript"></script>
<script src="${ctx}/static/zTree/jquery.ztree.core-3.5.js" type="text/javascript"></script>

<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />

 <style type="text/css">
 	toleft {
	  margin-left: 132px;
	}
 </style>
<style>
.form-horizontal .hidden-input{ display:none;}
</style>
</head>
<body>
<div class="sys-content">
	<div class="clearfix control-group">
			<a class="return btn btn-small pull-right"
				href="${ctx}/enterprise/admin/listAppByAuthentication"><i
				class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
			<h5 class="pull-left" style="margin: 3px 0 0 4px;">
				<a href="${ctx}/enterprise/admin/listAppByAuthentication"><c:out value='${appId}'/></a>&nbsp;&gt;&nbsp;
				<spring:message code="manage.title.basic" />
			</h5>
		</div>
		<ul class="nav nav-tabs clearfix">
        <li><a class="return" href="${ctx}/enterprise/admin/teamspace/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.teamspace"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/statistics/list/<c:out value='${appId}'/>"><spring:message code="header.statistics"/> </a></li>
        <c:if test="${appType == 1}">
        	<li><a class="return" href="${ctx}/enterprise/admin/individual/config/<c:out value='${appId}'/>"><spring:message code="individual.config"/> </a></li>
        </c:if>
        <li><a class="return" href="${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>"><spring:message code="systemRoleList.systemRoleManage"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
        <li class="active"><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
        </ul>
	
<div class="form-horizontal form-con clearfix">
   	<form id="basicConfigForm" class="form-horizontal" method="post">
         <div class="control-group">
                <label class="control-label" for="input"><em>*</em><spring:message code="account.basicConfig.userSpaceQuota"/>：</label>
	            <div class="controls">
	            	<label class="checkbox inline"><input type="checkbox" <c:if test="${appBasicConfig.userSpaceQuota == -1}">checked="checked"</c:if> id="userSpaceQuotaCheckBox" name="userSpaceQuotaCheckBox"/><spring:message code="basicConfig.limit"/></label>
	                <input class="span4 ${appBasicConfig.userSpaceQuota == -1 ? "hidden-input" : ""}" type="text" id="userSpaceQuotaInput" name="userSpaceQuotaInput" value="${appBasicConfig.userSpaceQuota == -1 ? 0 : appBasicConfig.userSpaceQuota}" />
	                <span class="validate-con"><div></div></span>
	            </div>          
        </div>
        <div class="control-group">
                <label class="control-label" for="input"><em>*</em><spring:message code="account.basicConfig.userVersions"/>：</label>
	            <div class="controls">
	            	<label class="checkbox inline"><input type="checkbox"  <c:if test="${appBasicConfig.userVersions == -1}">checked="checked"</c:if> id="userVersionsCheckBox" name="userVersionsCheckBox"/><spring:message code="basicConfig.limit"/></label>
	                <input class="span4 ${appBasicConfig.userVersions == -1 ? "hidden-input" : ""}" type="text" id="userVersionsInput" name="userVersionsInput" value="${appBasicConfig.userVersions == -1 ? 0 : appBasicConfig.userVersions}" />
	                <span class="validate-con"><div></div></span>
	            </div>                         
        </div> 
        <br/>
        <div class="control-group">
            <label class="control-label" for="input"><spring:message code="user.manager.labelIsTeam"/>：</label>
        	<div class="controls">
            	<label class="checkbox inline"><input type="checkbox" id="chkEnableTeamSpace" name="chkEnableTeamSpace" <c:if test="${appBasicConfig.enableTeamSpace}">checked="checked"</c:if> /><spring:message code="user.manager.isCreateTeam"/></label>
            </div>
        </div>
        <div id="maxTeamSpacesDiv" <c:if test="${!appBasicConfig.enableTeamSpace}">style="display:none"</c:if>>
	        <div class="control-group">
	               <label class="control-label" for="input"><em>*</em><spring:message code="account.basicConfig.maxTeamSpaces"/>：</label>
	               <div class="controls" >
			            <label class="checkbox inline"><input type="checkbox" <c:if test="${appBasicConfig.maxTeamSpaces == -1}">checked="checked"</c:if>  id="maxTeamSpacesCheckBox" name="maxTeamSpacesCheckBox"/><spring:message code="basicConfig.limit"/></label>
			            <input class="span4 ${appBasicConfig.maxTeamSpaces == -1 ? "hidden-input" : ""}" type="text" id="maxTeamSpacesInput" name="maxTeamSpacesInput" value="${appBasicConfig.maxTeamSpaces == -1 ? 0 : appBasicConfig.maxTeamSpaces}" />
			            <span class="validate-con"><div></div></span>
	               </div>   
		    </div>
		    <div class="control-group">
	                <label class="control-label" for="input"><em>*</em><spring:message code="account.basicConfig.teamSpaceQuota"/>：</label>
		            <div class="controls">
		            	<label class="checkbox inline"><input type="checkbox" id="teamSpaceQuotaCheckBox" <c:if test="${appBasicConfig.teamSpaceQuota == -1}">checked="checked"</c:if> name="teamSpaceQuotaCheckBox"/><spring:message code="basicConfig.limit"/></label>
		                <input class="span4 ${appBasicConfig.teamSpaceQuota == -1 ? "hidden-input" : ""}" type="text" id="teamSpaceQuotaInput" name="teamSpaceQuotaInput" value="${appBasicConfig.teamSpaceQuota == -1 ? 0 : appBasicConfig.teamSpaceQuota}" />
		                <span class="validate-con"><div></div></span>
		            </div>                         
	        </div>
	        <div class="control-group">
	                <label class="control-label" for="input"><em>*</em><spring:message code="account.basicConfig.teamSpaceVersions"/>：</label>
		            <div class="controls">
		                <label class="checkbox inline"><input type="checkbox" <c:if test="${appBasicConfig.teamSpaceVersions == -1}">checked="checked"</c:if> id="teamSpaceVersionsCheckBox" name="teamSpaceVersionsCheckBox"/><spring:message code="basicConfig.limit"/></label>
		                <input class="span4 ${appBasicConfig.teamSpaceVersions == -1 ? "hidden-input" : ""}" type="text" id="teamSpaceVersionsInput" name="teamSpaceVersionsInput" value="${appBasicConfig.teamSpaceVersions == -1 ? 0 : appBasicConfig.teamSpaceVersions}" />
		                <span class="validate-con"><div></div></span>
		            </div>          
	        </div>
        </div>        
        <div class="control-group">
            <div class="controls">
            	<button id="submit_btn" type="button" onClick="saveSecurityConfig()" class="btn btn-primary"><spring:message code="common.save"/></button>
            </div>
        </div>
        <input type="hidden" id="teamSpaceQuota" name="teamSpaceQuota"/>
        <input type="hidden" id="teamSpaceVersions" name="teamSpaceVersions"/>
        <input type="hidden" id="maxTeamSpaces" name="maxTeamSpaces"/>
        <input type="hidden" id="userVersions" name="userVersions"/>
        <input type="hidden" id="userSpaceQuota" name="userSpaceQuota"/>
   	    <input type="hidden" id="enableTeamSpace" name="enableTeamSpace" value="${appBasicConfig.enableTeamSpace}" />
        <input type="hidden" id="appId" name="appId" value="${appId}" />
        <input type="hidden" id="token" name="token" value="${token}"/>        
	</form>
</div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	$("#basicConfigForm").validate({ 
		rules: {
			userSpaceQuotaInput: { 
				   required:true, 
				   digits:true,
			       min:1,
			       max:104857600
			   },
			   userVersionsInput: {
				   required:true,
				   digits:true,
			       min:1,
			       max:10000
			   },
			   maxTeamSpacesInput: { 
				   required:true, 
				   digits:true,
			       min:0,
			       max:10000
			   },
			   teamSpaceQuotaInput:{
				   required:true, 
				   digits:true,
			       min:1,
			       max:104857600
			   },
			   teamSpaceVersionsInput: { 
				   required:true, 
				   digits:true,
			       min:1,
			       max:10000
			   }
		},
		ignore: ".hidden-input",
		onkeyup:function(element) {$(element).valid()},
		focusCleanup:true,
		onfocusout:false
    }); 
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
	

});


$("#teamSpaceQuotaCheckBox").click(function(){ 
	if(this.checked){
		$('#teamSpaceQuotaInput').addClass("hidden-input")
			.val("0")
			.next().find("> div > span").remove();
		
	}else{ 
		$('#teamSpaceQuotaInput').removeClass("hidden-input");
		$('#teamSpaceQuotaInput').val("");
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});
$("#teamSpaceVersionsCheckBox").click(function(){ 
	if(this.checked){
		$('#teamSpaceVersionsInput').addClass("hidden-input")
		.val("0")
		.next().find("> div > span").remove();
	}else{ 
		$('#teamSpaceVersionsInput').removeClass("hidden-input");
		$('#teamSpaceVersionsInput').val("");
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});
$("#maxTeamSpacesCheckBox").click(function(){
	if(this.checked){
		$('#maxTeamSpacesInput').addClass("hidden-input")
		.val("-1")
		.next().find("> div > span").remove();
	}else{ 
		$('#maxTeamSpacesInput').removeClass("hidden-input");
		$('#maxTeamSpacesInput').val("");
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});
$("#userVersionsCheckBox").click(function(){ 
	if(this.checked){
		$('#userVersionsInput').addClass("hidden-input")
		.val("0")
		.next().find("> div > span").remove();
	}else{ 
		$('#userVersionsInput').removeClass("hidden-input");
		$('#userVersionsInput').val("");
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});
$("#userSpaceQuotaCheckBox").click(function(){ 
	if(this.checked){
		$('#userSpaceQuotaInput').addClass("hidden-input")
		.val("0")
		.next().find("> div > span").remove();
	}else{ 
		$('#userSpaceQuotaInput').removeClass("hidden-input");
		$('#userSpaceQuotaInput').val("");
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});

$("#chkEnableTeamSpace").click(function(){ 
	if(this.checked){
		$("#enableTeamSpace").val("true");
		$('#maxTeamSpacesDiv').show();
	}else{ 
		$("#enableTeamSpace").val("false");
		$("maxTeamSpaces").val("0");
		$('#maxTeamSpacesDiv').hide();
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
});
function setParameter(){
	$("#userSpaceQuota").val($("#userSpaceQuotaInput").val() == 0 ? -1 : $("#userSpaceQuotaInput").val());
	$("#userVersions").val($("#userVersionsInput").val() == 0 ? -1 : $("#userVersionsInput").val());
	$("#teamSpaceQuota").val($("#teamSpaceQuotaInput").val() == 0 ? -1 : $("#teamSpaceQuotaInput").val());
	$("#teamSpaceVersions").val($("#teamSpaceVersionsInput").val() == 0 ? -1 : $("#teamSpaceVersionsInput").val());	
	$("#maxTeamSpaces").val($("#maxTeamSpacesInput").val() == -1 ? -1 : $("#maxTeamSpacesInput").val());
}

function saveSecurityConfig(){
	if(!$("#basicConfigForm").valid()) {
        return false;
    }  
	setParameter();
	$.ajax({
		type: "POST",
		url:"${ctx}/enterprise/admin/basicconfig/save",
		data:$('#basicConfigForm').serialize(),
		error: function(request) {
			top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
		},
		success: function() {
			top.handlePrompt("success",'<spring:message code="common.saveSuccess"/>');
		}
	});
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
}
</script>
</body>
</html>
