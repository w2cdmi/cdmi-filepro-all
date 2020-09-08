<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
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
        	<li class="active"><a class="return" href="${ctx}/enterprise/admin/individual/config/<c:out value='${appId}'/>"><spring:message code="individual.config"/> </a></li>
        </c:if>
        <li><a class="return" href="${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>"><spring:message code="systemRoleList.systemRoleManage"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
        </ul>
	
	<form id="customizeForm" class="form-horizontal" enctype="multipart/form-data" method="post" action="${ctx}/enterprise/admin/individual/config"> 
		<div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="webCustomize.chineseSystem"/>:</label>
            <div class="controls">
                <input class="span4" type="text" id="titleCh" name="titleCh" value="${cse:htmlEscape(customize.titleCh)}" />&nbsp;&nbsp;(<spring:message code="webCustomize.chinese"/>)
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label" for="input"></label>
            <div class="controls">
                <input class="span4" type="text" id="titleEn" name="titleEn" value="${cse:htmlEscape(customize.titleEn)}" />&nbsp;&nbsp;(<spring:message code="webCustomize.english"/>)
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="webCustomize.systemLogo"/>:</label>
           
            <c:if test="${customize.existWebLogo}">
            <div class="controls">
                <div class="set-logo-con">
                    <img alt="logo" id="weblogoImage" src="${ctx}/syscommon/weblogo/<c:out value='${appId}'/>" style="width: 148px;height: 60px"/>
                </div>
            </div>
            </c:if>
            <c:if test="${!customize.existWebLogo}">
            <div class="controls">
            	<div class="set-logo-con">
                	<img alt="logo" src="${ctx}/static/skins/default/img/logo-onebox.png" style="width: 148px;height: 60px"/>
                </div>
            </div>
            </c:if>
             <div class="controls">
             	<span class="help-block"><spring:message code="webIconPcLogo.suggestWebLogo"/></span>
                <input type="file" name="webLogoFile" id="webLogoFile" onchange="loadImage(this,weblogoImage,'${ctx}/syscommon/weblogo/<c:out value='${appId}'/>');"/>
            </div>
        </div>
        
        <div class="control-group">
        	<label class="control-label" for="input"><em>*</em><spring:message code="webCustomize.browserIdentification"/>:</label>
        	<c:if test="${customize.existIcon}">
            <div class="controls">
                <img alt="logo" src="${ctx}/syscommon/webicon/<c:out value='${appId}'/>" width="16" height="16" style="width: 16px;height: 16px">
            </div>
            </c:if>
        	<c:if test="${!customize.existIcon}">
            <div class="controls">
                <img alt="logo" src="${ctx}/static/skins/default/img/logo.ico" width="16" height="16" style="width: 16px;height: 16px">
            </div>
            </c:if>
        	  <div class="controls">
                <span class="help-block"><spring:message code="webIconPcLogo.suggestIcon"/></span>
                <input type="file" name="iconFile" id="iconFile">
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="pcCustomize.systemLogo"/>:</label>
           
            <c:if test="${customize.existPcLogo}">
            <div class="controls">
                <div class="set-logo-con">
                    <img alt="logo" id="pcLogoImage" src="${ctx}/syscommon/pclogo/<c:out value='${appId}'/>" style="width: 148px;height: 60px"/>
                </div>
            </div>
            </c:if>
            <c:if test="${!customize.existPcLogo}">
            <div class="controls">
            	<div class="set-logo-con">
                	<img alt="logo"  src="${ctx}/static/skins/default/img/logo-onebox.png" style="height: 60px"/>
                </div>
            </div>
            </c:if>
             <div class="controls">
             	<span class="help-block"><spring:message code="webIconPcLogo.suggestPcLogo"/></span>
                <input type="file" name="pcLogoFile" id="pcLogoFile" onchange="loadImage(this,pcLogoImage,'${ctx}/syscommon/pclogo/<c:out value='${appId}'/>');"/>
            </div>
        </div>
        
        <div class="control-group">
            <div class="controls">
            	<button id="submit_btn" type="button" onclick="saveLogoCustom()" class="btn btn-primary"><spring:message code="common.save"/></button>
            </div>
            <div class="control-group" style="display:none">
           		<input type="reset" value="Reset" />            
        	</div>
        </div>
        <input type="hidden" id="token" name="token" value="${token}"/>
        <input type="hidden" id="appId" name="appId" value="<c:out value='${appId}'/>"/>
	</form>
	</div>
</body>
<script type="text/javascript">

var saveState = "<c:out value='${saveState}'/>";
var locationState = "<c:out value='${whichOne}'/>";
$(document).ready(function() {
	if(saveState == "success"){
		top.handlePrompt("success",'<spring:message code="common.saveSuccess"/>');
	}else if(saveState == "fail"){
		top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
	}
	
	if(locationState == "webLogoFile"){
		if(saveState == "ImageSizeException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmWebLogoSize"/>');
		}else if(saveState == "ImageInvalidException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmWebLogoInvalid"/>');
		}
	} 
	if(locationState == "iconFile"){
		if(saveState == "ImageSizeException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmIconSize"/>');
		}else if(saveState == "ImageInvalidException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmIconInvalid"/>');
		}
		else if(saveState == "ImageScaleException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmIconScale"/>');
		}
	}
	if(locationState == "pcLogoFile"){
		if(saveState == "ImageSizeException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmPcLogoSize"/>');
		}else if(saveState == "ImageInvalidException"){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmPcLogoInvalid"/>');
		}
	}
	
	$("#customizeForm").validate({ 
		rules: { 
			   titleCh:{
				   required:true, 
			       maxlength:[100]
			   },
			   titleEn:{
				   required:true, 
			       maxlength:[100]
			   }
		}
 	});
});
function loadImage(e,id,src){
	var file = $(e)[0].files[0];
	if(file){
		var reader = new FileReader();
		reader.onload=function(){
			$("#"+id.id+"")[0].src=this.result;
		}
		reader.readAsDataURL(file);
	}else{
		$("#"+id.id+"")[0].src=src;
	}
};


function saveLogoCustom(){
	if(!$("#customizeForm").valid()) {
        return false;
    }  
	var webPicTypes = ["png"];
	var iconPicTypes = ["ico","icon"];
	var pcPicTypes = ["jpg","jpeg","png"];
	
 	var webLogoFileName = $("#webLogoFile").val();
	if(webLogoFileName != ""){
		var formatValid = false;
		var curType = webLogoFileName.substring(webLogoFileName.lastIndexOf(".")+1);
		curType = curType.toLowerCase();
		for(idx in webPicTypes){
			if(curType == webPicTypes[idx]){
				formatValid = true;
				break;
			}
		}
		if(formatValid == false){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmWebLogoInvalid"/>');
			return;
		}
	}
	
	var pcLogoFileName = $("#pcLogoFile").val();
	if(pcLogoFileName != ""){
		var formatValid = false;
		var curType = pcLogoFileName.substring(pcLogoFileName.lastIndexOf(".")+1);
		curType = curType.toLowerCase();
		for(idx in pcPicTypes){
			if(curType == pcPicTypes[idx]){
				formatValid = true;
				break;
			}
		}
		if(formatValid == false){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmPcLogoInvalid"/>');
			return;
		}
	}
	
	var iconFileName = $("#iconFile").val();
	if(iconFileName != ""){
		var formatValid = false;
		var curType = iconFileName.substring(iconFileName.lastIndexOf(".")+1);
		curType = curType.toLowerCase();
		for(idx in iconPicTypes){
			if(curType == iconPicTypes[idx]){
				formatValid = true;
				break;
			}
		}
		if(formatValid == false){
			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmIconInvalid"/>');
			return;
		}
	} 
	$("#customizeForm").attr("action", "${ctx}/enterprise/admin/individual/config");
	$("#customizeForm").submit();
}

</script>


</html>
