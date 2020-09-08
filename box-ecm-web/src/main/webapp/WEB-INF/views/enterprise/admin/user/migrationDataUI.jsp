<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@ include file="../../../common/common.jsp"%>
    <link href="${ctx}/static/skins/default/css/public.css" rel="stylesheet" type="text/css"/>
<style>
.form-horizontal .hidden-input{ display:none;}

.checkbox-inline{
	display: inline-block;
}
.control-group {
	margin: 10px;
}
#migrateToNewUserDiv {
	margin-top: 50px;
}
.controls .control-label {
	display: inline-block;
	margin-left: 0px;
	text-align: right;
	width: 100px;
	float: left;
}
.controls .control-field  {
	margin-left: 20px;
	width: 200px;
}

#migrateToExistUserDiv {
	margin-top: 10px;
}
#migrateToExistUserDiv .input-append {
	float: left;
	margin-left: 10px;
}
#migrateToExistUserDiv .input-append select{
	height: 25px;
	margin: auto 0;
}
#migrateToExistUserDiv .btn {
	width: 50px;
}
#userList {
	
}

</style>
</head>
<body >
<div class="pop-content pop-content-en">
	<div class="form-con">
	
		<div class="control-group">
	        <div class="controls">
	        <input type="hidden" name="optionsRadiosinline" id="migrateToExistUser" value="2" >
	           <!--  <label class="checkbox-inline" style="display:none;">
					<input type="radio" name="optionsRadiosinline" id="migrateToNewUser" value="1" >新用户
				</label>
				
				<label class="checkbox-inline" >
					<input type="hidden" name="optionsRadiosinline" id="migrateToExistUser" value="2" >
				</label> -->
	        </div>
	    </div>

		<form class="form-horizontal" id="creatUserForm" name="creatUserForm">
			<input type="hidden" name="localTypeId"  id = "localTypeId" value="${localTypeId}" />
			<input type="hidden" name="departureUserId" id = "departureUserId"  value="${departureUserId}" />
			<input type="hidden" name="departureCloudUserId" id = "departureCloudUserId"  value="${departureCloudUserId}" />
			<input type="hidden" name="appIds" id = "appIds" value="${appIds}" />
			<input type="hidden" name="departureUserName" id = "departureUserName" value="${departureUserName}" />
			<input type="hidden" name="migrateToken" id = "migrateToken" value="${migrateToken}" />

			<div id = "migrateToNewUserDiv" style="display: none;">
				<div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
					<button class="close" data-dismiss="alert">×</button><spring:message code="user.manager.createUserFailed"/>
				</div>
				
		         <div class="control-group">
		            <div class="controls">
						<label class="control-label" for="name"><em>*</em><spring:message code="user.manager.labelUserName"/></label>
		                <input class="control-field" type="text" id="name" name="name" onblur="isValidLoginName()" maxlength="127"/>
		                <span class="validate-con bottom inline-span3">
			                <div style="color:#EA5200">
				                <span id="isValidLoginNameSpan">
				               		<span for="name" class="error" id="isValidLoginName" style="display: none;">
				               			<spring:message code="enterprise.user.login.name"/>
				               		</span>
				               	</span>
			                </div>
		                </span>
		            </div>
		        </div>
		        
		        <div class="control-group">
		            <div class="controls">
						<label class="control-label" for=""><em>*</em><spring:message code="user.manager.labelName"/></label>
		                <input class="control-field" type="text" id="alias" name="alias" maxlength="127"/>
		                <span class="validate-con bottom inline-span3"><div></div></span>
		            </div>
		        </div>
		        
		        <div class="control-group">
		            <div class="controls">
						<label class="control-label" for=""><em>*</em><spring:message code="user.manager.labelEmail"/></label>
		                <input class="control-field" type="text" id="email" name="email" maxlength="255"/>
		                <span class="validate-con bottom inline-span3"><div></div></span>
		            </div>
		        </div>
		        <div class="control-group">
		            <div class="controls">
						<label class="control-label" for=""><spring:message code="enterpriseList.contactPhone"/></label>
		                <input class="control-field" type="text" id="mobile" name="mobile" maxlength="255"/>
		                <span class="validate-con bottom inline-span3"><div></div></span>
		            </div>
		        </div>
		        <div class="control-group">
		            <div class="controls">
						<label class="control-label" for=""><spring:message code="user.manager.labelDecription"/></label>
		                <textarea class="control-field span4" id="description" name="description" maxlength="255" style="resize: none; width: 200px"></textarea>
		                <span class="validate-con bottom inline-span4"><div></div></span>
		            </div>
		        </div>
	        	<input type="hidden" id="token" name="token" value="${token}"/>	
	        	<input type="hidden" name="recipientUserId" id="recipientUserId">
			    <input type="hidden" name="recipientUserName" id="recipientUserName">
			</div>
	       
	        <%-- 已经存在的用户 --%>
			<div id = "migrateToExistUserDiv">
			   <div class="form-search" style="height: 50px;">
				<div class="pull-left" style="margin-left: 20px">
					<%-- 选择认证方式 --%>
					<select class="span3 width-w180" id="authenticationMethod" name="authenticationMethod">
						<c:forEach items="${authServerList}" var="authServer">
							<option value="<c:out value='${authServer.id}'/>" <c:if test="${localTypeId == authServer.id}">selected</c:if>>
								<c:if test="${authServer.type != 'LocalAuth'}"><c:out value='${authServer.name}'/></c:if>
								<c:if test="${authServer.type == 'LocalAuth'}"><spring:message  code="authserver.type.local"  /></c:if>
							</option>
						</c:forEach>
					</select>
				</div>

					<div class="pull-left input-append">                   
				         <input type="text" id="filter" name="filter" class="span3"  value="" placeholder="<spring:message code="user.manager.searchDescription"/>">
				    </div>
				    	<div class="pull-left">  
				    	 <button type="button" class="btn" id="searchButton" style="margin-left: 0px;"><i class="icon-search"></i></button>    
				    	</div>
			    </div>
			    <div class="table-con" style="width: 650px; margin-left: 20px;">
					<div id="userList" style="height: 250px;overflow: auto;"></div>
				</div>
			</div>
		</form>
 	</div>
</div>
<script type="text/javascript">
var headData = {
		"name" : {
			"title" : "<spring:message code='user.manager.loginName'/>",
			"width" : "20%",
			"taxis" : true
		},
		"email" : {
			"title" : "<spring:message code='user.manager.email'/>",
			"width" : "35%",
			"taxis":true
		},
		"mobile" : {
			"title" : "<spring:message code='enterpriseList.contactPhone'/>",
			"width" : "35%",
			"taxis":true
		}
};
var catalogData;
var opts_viewGrid = $("#userList").comboTableGrid({
	headData : headData,
	checkBox : false,
	checkAll : false,
	radioBtn : true,
	dataId : "id",
	dataNullTip : "<spring:message code='departure.migrate.data.nulltip'/>",
	taxisFlag : true
});


/** 查询用户 **/
function searchUserByCondition() {
	var authServerId = $("#localTypeId").val();;
	var url = "${ctx}/enterprise/admin/user/employeeManage";
	var filter = $("#filter").val();
	var dn = $("#dn").val();
	var migrationType = $("input[type=radio][name=optionsRadiosinline]:checked").val();
	if (migrationType == 2){
		authServerId = $("#authenticationMethod").find("option:selected").val();
	}

	var params = {
		"page" : 1,
		"authServerId" : authServerId,
		"filter" : filter,
		"token" : "${token}",
		"dn" : dn,
		"newHeadItem": "",
		"newFlag":false
	};	
	
	$("#userList").showTableGridLoading();
	$.ajax({
		type : "POST",
		url : url,
		data : params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
		},
		success : function(data) {
			catalogData = data[1].content;
			$("#userList").setTableGridData(catalogData, opts_viewGrid);
			var pageH = $("body").outerHeight();
			iframeAdaptHeight(pageH);
		}
	});
}
	
$(document).ready(function() {
	$("#searchButton").on("click",function(){
		searchUserByCondition();
	});	
	
	$("#filter").keydown(function(){
		var evt = arguments[0] || window.event;
		if(evt.keyCode == 13){
			searchUserByCondition();
			
			if(window.event){
				window.event.cancelBubble = true;
				window.event.returnValue = false;
			}else{
				evt.stopPropagation();
				evt.preventDefault();
			}
		}
	});

	$("input[type=radio][name=optionsRadiosinline]").click(function(){
		var selVal = $(this).val();
		
		if (selVal == 1){
			$("#migrateToExistUserDiv").hide();
			$("#migrateToNewUserDiv").show();
		} else {
			$("#migrateToNewUserDiv").hide();
			$("#migrateToExistUserDiv").show();
		}
	});
	
});

/** 数据或者账户迁移 **/
function migrateData() {
	var authServerId = $("#authServerId").val();
	var departureUserId = $('#departureUserId').val();
	var departureUserAppIds = $('#appIds').val();
	var migrationType = $("input[type=radio][name=optionsRadiosinline]:checked").val();
	var paramJson = {};
	var authServerId = $("#localTypeId").val();
	
	paramJson.appIds = departureUserAppIds;
	paramJson.departureUserId = departureUserId;
	paramJson.departureUserName = $('#departureUserName').val();
	paramJson.token = '${token}';
	paramJson.migrateToken = '${migrateToken}';
	migrationType=2;
	if (migrationType == 1){
		paramJson.name = $("#name").val();
		paramJson.alias = $("#alias").val();
		paramJson.email = $("#email").val();
		paramJson.mobile = $("#mobile").val();
		paramJson.description = $("#description").val();
	} else if (migrationType == 2){
		var selUserIds  = $("#userList").getTableGridSelected();
		if (!selUserIds || selUserIds.length < 1){
			handlePrompt("error", '<spring:message code="departure.migrate.data.choose.recipient.user" />');
			return;
		}
		
		var recipientUserName, authAppIds;
		for(var index in catalogData){
			var tempData = catalogData[index];
			if (tempData.id == selUserIds[0]){
				recipientUserName = tempData.name;
				authAppIdList = tempData.authAppIdList.join(',');
				break;
			}
		}
		
		if (authAppIdList && (authAppIdList != departureUserAppIds)){
			handlePrompt("error", '<spring:message code="departure.migrate.data.app.difference" />');
			return;
		}
		
		authServerId = $("#authenticationMethod").find("option:selected").val();
		paramJson.recipientUserName = recipientUserName;
		paramJson.recipientUserId = selUserIds[0];
	}
	paramJson.authServerId = authServerId;
	
	var url="${ctx}/enterprise/admin/user/migrateData/" + authServerId + "/2";
	$.ajax({
        type: "POST",
        url:url,
        data: paramJson,
        error: function(request) {
        	var status = request.status;
        	if (status == 429) {
        		handlePrompt("error",'<spring:message code="departure.migrate.data.repeat.submit"/>');
        	} else if (status == 301) {
        		handlePrompt("error",'<spring:message code="departure.migrate.data.has.migrated"/>');
        	} else {
        		handlePrompt("error",'<spring:message code="operation.failed"/>');
        	}
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="departure.operation.success"/>');
        	refreshWindow();
        }
    });
}

function refreshWindow() {
	<%--top.window.frames[0].location = "${ctx}/enterprise/admin/user/employeeManage/0";--%>
    top.window.frames[0].window.refreshWindow();
}

function checkValidLoginName(){
	var ret = false;
	   $.ajax({
	        type: "POST",
	        async: false,
	        url:"${ctx}/enterprise/admin/user/validLoginName",
	        data:$("#creatUserForm").serialize(),
	        success: function(data) {
	        	ret = true;
	        }
	    });
    return ret;
}

function isValidLoginName(){
	if(!checkValidLoginName()){
		$("#isValidLoginName").removeAttr("style"); 
		$("#isValidLoginNameSpan").removeAttr("style"); 
		$("#isValidLoginName").html("<spring:message code='enterprise.user.login.name'/>"); 
	    return false;
	}
	$("#isValidLoginName").attr("style","display: none"); 
	return true;
}

</script>
</body>
</html>
