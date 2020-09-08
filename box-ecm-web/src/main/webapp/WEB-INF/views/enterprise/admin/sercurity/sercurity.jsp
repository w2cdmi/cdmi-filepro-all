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
<meta charset="UTF-8">
<title>Title</title>
<style type="text/css">
.table-bordered>thead>tr>td, .table-bordered>thead>tr>th {
	border-bottom-width: 1px;
}
</style>
<link href="${ctx}/static/enterprise/safeControl/safe_control.css"
	type="text/css" rel="stylesheet" />
<script src="${ctx}/static/enterprise/safeControl/safe_control.js">  </script>
<script type="text/javascript">
    var appId= window.parent.defaltAppId;
    var token="<c:out value='${token}'/>";
    
    var docSecretLevel=false;
    var approveId;
    
    $(document).ready(function() {
    	   window.parent.iframCallback();
    	   initBasicConfig();
    	   $("#accountSafe").css("display", "block");
	}); 
    
    function initBasicConfig() {
		$.ajax({
			type : "GET",
			url : '${ctx}/enterprise/admin/basicconfig/config/' +appId,
			data : {token:token},
			error : function(request) {
				handlePrompt("error",
						'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				fullBasicInput(data);
			}
		})

		$.ajax({
			type : "GET",
			url : '${ctx}/enterprise/config/basic/' + appId,
			data :  {token:token},
			error : function(request) {
				handlePrompt("error",
						'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				for (var i = 0; i < data.length; i++) {
					fullBasicSelect(data[i]);
				}
				if(docSecretLevel==false){
					 $("#normal").addClass("active");
					 $("#normalNav").addClass("active"); 
					 $("#generalNav").css("display","none");
					 $("#noSecretDocNav").css("display","none");
					 $("#secretDocNav").css("display","none");
				}
			}
		})
		listVisitSecretDoc();
	}
	function fullBasicInput(basicconfig) {
		for(var k in basicconfig){
			if($("[id='" + k + "']").is("input")){
				$("[id='" + k + "']").val(basicconfig[k]);
			}
		}
		
	}
	function fullBasicSelect(config) {
		if($("[id='" + config.name + "']").is("input")){
			$("[id='" + config.name + "']").val(config.value);
		}
		if("customer.storbox.doc.secretlevel.enable"==config.name){
			if(config.value!=""&&config.value=="true"){
				 docSecretLevel=true;
				 $("#generalNav").addClass("active");
				 $("#general").addClass("active");
				 $("#normalNav").css("display","none");
			}else{
				 $("#normal").addClass("active");
				 $("#normalNav").addClass("active"); 
				 $("#generalNav").css("display","none");
				 $("#noSecretDocNav").css("display","none");
				 $("#secretDocNav").css("display","none");
			}
		}
		if("customer.storbox.sendfile.normal.approve.id"==config.name
	        ||"customer.storbox.sendfile.notsecret.approve.id"==config.name
	        ||"customer.storbox.sendfile.secretdoc.approve.id"==config.name){
			if(config.value!=""&&config.value!="0"){
				getUserName(config.value,config.name)
			}
		}
		$(":radio").each(function(){
			if($(this).attr("name")==config.name&&$(this).attr("value")==config.value){
				$(this).attr('checked','true');
			}
		});
		if (config.value == "true") {
			$("[id='" + config.name + "']").addClass("ui-checkbox-selected");
		}
		if($("[id='" + config.name + "']").is("select")){
			$("[id='" + config.name + "']").val(config.value);
		}
	}
	
	function accountSafeSave(){
		var loginfail=getCheckboxValue("customer.storbox.security.loginfail.notice.enable");
		var json="[{\"name\":\"customer.storbox.security.loginfail.notice.enable\",\"value\":\""+loginfail+"\"}]";
		$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
				data : {data:json},
				error : function(request) {
					top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
				},
				success : function() {
					showMsg('<spring:message code="common.saveSuccess"/>');
				}
			});
	}
	function normalSave(){
		var approveEn=getCheckboxValue("customer.storbox.sendfile.normal.approve.enable");
		var Rang= getRadioValue("customer.storbox.sendfile.normal.approve.range");
		var forbid=getCheckboxValue("customer.storbox.sendfile.normal.extuser.forbid");
		var json="[{\"name\":\"customer.storbox.sendfile.normal.approve.enable\",\"value\":\""+approveEn+"\"},"+
			        "{\"name\":\"customer.storbox.sendfile.normal.approve.range\",\"value\":\""+Rang+"\"},"+
			        "{\"name\":\"customer.storbox.sendfile.normal.extuser.forbid\",\"value\":\""+forbid+"\"}]";
		$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
				data : {data:json},
				error : function(request) {
					top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
				},
				success : function() {
					showMsg('<spring:message code="common.saveSuccess"/>');
				}
			});
	}
	
	function generalSave(){
		var forbid=getCheckboxValue("customer.storbox.sendfile.secretlevel.extuser.forbid");
		var json="[{\"name\":\"customer.storbox.sendfile.secretlevel.extuser.forbid\",\"value\":\""+forbid+"\"}]";
		$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
				data : {data:json},
				error : function(request) {
					top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
				},
				success : function() {
					showMsg('<spring:message code="common.saveSuccess"/>');
				}
			});
	}
	function noSecretDocSave(){
		var sendfile= getRadioValue("customer.storbox.sendfile.range");
		var approveEn=getCheckboxValue("customer.storbox.sendfile.notsecret.approve.enable");
		var approveId=getCheckboxValue("customer.storbox.sendfile.notsecret.approve.id");
		var json="[{\"name\":\"customer.storbox.sendfile.approve.enable\",\"value\":\""+approve+"\"},"+
        "{\"name\":\"customer.storbox.sendfile.range\",\"value\":\""+sendfile+"\"}]";
		console.debug(json);
        $.ajax({
				type : "POST",
				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
				data : {data:json},
				error : function(request) {
					top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
				},
				success : function() {
					showMsg('<spring:message code="common.saveSuccess"/>');
				}
		});
	}
	
	function secretDocSave(){
		var approveEn=getCheckboxValue("customer.storbox.sendfile.secretdoc.approve.enable");
		var approveId=getCheckboxValue("customer.storbox.sendfile.secretdoc.approve.id");
		var range=getCheckboxValue("customer.storbox.sendfile.secretdoc.approve.range");
		var level=$("[id='customer.storbox.sendfile.secretdoc.level']").val();
		
		var json="[{\"name\":\"customer.storbox.sendfile.secretdoc.approve.enable\",\"value\":\""+approveEn+"\"},"+
	    "{\"name\":\"customer.storbox.sendfile.secretdoc.approve.id\",\"value\":\""+approveId+"\"},"+
        "{\"name\":\"ccustomer.storbox.sendfile.secretdoc.approve.range\",\"value\":\""+range+"\"},"+
        "{\"name\":\"customer.storbox.sendfile.secretdoc.level\",\"value\":\""+level+"\"}]";
        $.ajax({
				type : "POST",
				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
				data : {data:json},
				error : function(request) {
					top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
				},
				success : function() {
					showMsg('<spring:message code="common.saveSuccess"/>');
				}
		});
	}
	
    function saveSecurityConfig(th){
    	   var params = {
    			"token" : token,
    			"name" : $(th).attr("name"),
    			"value" :$(th).attr("value"),
    		};
    		$.ajax({
    			type : "POST",
    			url : '${ctx}/enterprise/config/basic/' + appId,
    			data : params,
    			error : function(request) {
    				handlePrompt("error",
    						'<spring:message code="common.operationFailed" />');
    			},
    			success : function(data) {
    				showMsg('<spring:message code="common.saveSuccess"/>');
    			}
    		})
    	
    }
 function saveVisitSecretDoc(){
	 var  level1=$("#doc_level_1").val();
	 var  level2=$("#doc_level_2").val();
	 var  level3=$("#doc_level_3").val();
	 var  visitLimit = $("[id='secretdoc.visitLimit.enable']").attr("class") == "ui-checkbox"?"false":"true";
	 var  objects="[{\"secretLevel\":1,\"staffLevel\":"+level1+"},{\"secretLevel\":2,\"staffLevel\":"+level2+"},{\"secretLevel\":3,\"staffLevel\":"+level3+"}]"
	 $.ajax({
 		type: "POST",
 		url:"${ctx}/app/securityconfig/saveVisitSecretDoc?token="+token,
 		data:{objects:objects,appId:appId},
 		error: function(request) {
 			showMsg('<spring:message code="common.saveFail"/>');
 		},
 		success: function() {
 			var json="[{'name':'secretdoc.visitLimit.enable','value':'"+visitLimit+"'}]";
 			$.ajax({
 				type : "POST",
 				url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
 				data : {data:json},
 				error : function(request) {
 					top.handlePrompt("error",
 							'<spring:message code="common.saveFail"/>');
 				},
 				success : function() {
 					showMsg('<spring:message code="common.saveSuccess"/>');
 				}
 			});
 		}
	 })
 }
 
 function listVisitSecretDoc(){
	 $.ajax({
 		type: "GET",
 		url:"${ctx}/app/securityconfig/secretStaff?token="+token,
 		data:{appId:appId},
 		error: function(request) {
 			top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
 		},
 		success: function(data) {
 			for(var i=0;i<data.length;i++){
 				 $("#doc_level_"+data[i].secretLevel).val(data[i].staffLevel);
 			}
 		}
	 })
 }
 
 function getapprove(name) {
     var url = "${ctx}/enterprise/admin/user/chooseEnterpriseUser/0?dataId=cloudUserId";
     top.ymPrompt.win({
         message: url,
         width: 900,
         height: 650,
         title: '<spring:message code="enterprise.security.manager.add"/>',
         iframe: true,
         btn: [
             ['<spring:message code="common.OK"/>', 'yes', false, "btn-focus"],
             ['<spring:message code="common.close"/>', 'no', true, "btn-cancel"]
         ],
         handler: function (tp) {
             if (tp == 'yes') {
                 var array = top.ymPrompt.getPage().contentWindow.getSelectedUser();
                 top.ymPrompt.close();
                 submitApprove(array[0],name);
             }
         }
     });
 }
 
 function submitApprove(employerId,name){
	 var params = {
 			"token" : token,
 			"name" : name,
 			"value" :employerId,
 		};
 		$.ajax({
 			type : "POST",
 			url : '${ctx}/enterprise/config/basic/' + appId,
 			data : params,
 			error : function(request) {
 				handlePrompt("error",
 						'<spring:message code="common.operationFailed" />');
 			},
 			success : function(data) {
 				showMsg('<spring:message code="common.saveSuccess"/>');
 				getUserName(employerId,name);
 			}
 		})
	 
 }
 
 
 function deleteApprove(name,employerId){
	 var params = {
	 			"token" : token,
	 			"name" : name,
	 			"value" :employerId,
	 		};
	 		$.ajax({
	 			type : "POST",
	 			url : '${ctx}/enterprise/config/basic/' + appId,
	 			data : params,
	 			error : function(request) {
	 				handlePrompt("error",
	 						'<spring:message code="common.operationFailed" />');
	 			},
	 			success : function(data) {
	 				showMsg('<spring:message code="common.modifySuccess"/>');
	 				$("[id='" + name + "']").text("");
	 			}
	 		})
 }
 
 
 function saveFileLevel(){
	var securityCreatorEnable = $("[id='secretdoc.securityCreator.enable']").attr("class") == "ui-checkbox"?"false":"true";
	var staffCreatorEnable = $("[id='secretdoc.staffCreator.enable']").attr("class") == "ui-checkbox"?"false":"true";
	var staffCreatorLevel = $("[id='secretdoc.staffCreator.secretlevel']").val();
	var json="[{'name':'secretdoc.securityCreator.enable','value':'"+securityCreatorEnable+"'},{'name':'secretdoc.staffCreator.enable','value':'"+staffCreatorEnable+"'},"+
		"{'name':'secretdoc.staffCreator.secretlevel','value':'"+staffCreatorLevel+"'}]";
	
	$.ajax({
		type : "POST",
		url : "${ctx}/enterprise/config/modifyBasicArray/"+appId+"?token="+"<c:out value='${token}'/>",
		data : {data:json},
		error : function(request) {
			top.handlePrompt("error",
					'<spring:message code="common.saveFail"/>');
		},
		success : function() {
			top.handlePrompt("success",
					'<spring:message code="common.saveSuccess"/>');
		}
	});
 }
 
 function addWhiteList(){
	 showMsg('该功能暂未开放');
 }
 
 
 function getUserName(cloudUserId,span){
	 $.ajax({
			type : "GET",
			url : "${ctx}/enterprise/admin/user/getEnterPriseUserName/"+cloudUserId+"?token=<c:out value='${token}'/>&appId="+appId,
			error : function(request) {
				top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
			},
			success : function(data) {
				$("[id='" + span + "']").text(" (审批人:"+data+")");
			}
	});
 }
</script>
</head>
<body>
	<div class="content">
		<div class="c_main">
			<div class="option-header">
				<div class="option-item option-header-active" value="accountSafe">账号安全</div>
				<div class="option-item" value="fileSafe">文件收发</div>
				<div class="option-item" value="accessSafe">访问控制</div>
				<div class="option-item" value="employerSafe">员工信息安全等级</div>
				<div class="option-item" value="fileLeve">文档密级</div>
			</div>
			<!--账号安全-->
			<div class="option-content" id="accountSafe">
				<div class="ui-row">
					<div class="checkbox-group">
						<div class="ui-checkbox"
							id="customer.storbox.security.loginfail.notice.enable"></div>
						<div>启用登录失败通知</div>
					</div>
					<div class="ui-explain">启用之后，账号多次尝试登录失败时，会发送通知到邮箱</div>
				</div>
				<div class="ui-row">
					<!--   <div class="checkbox-group">
                          <div class="ui-checkbox" id="customer.storbox.mobile.validate.enable" ></div>
                            <div class="ui-explain">启用关键信息修改手机验证</div>
                        </div>
                        <div class="ui-explain">启用之后，当出现重置密码，修改密码时候还需通过短信验证码验证才能完成操作</div> -->
				</div>
				<div class="ui-btn ui-btn-default" onclick="accountSafeSave()">保存</div>
			</div>
			<!--文件收发-->
			<div class="option-content" id="fileSafe">
				<!-- Nav tabs -->
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" id="normalNav"><a href="#normal"
						aria-controls="normal" role="tab" data-toggle="tab">通用设置</a></li>
					<li role="presentation" id="generalNav"><a href="#general"
						aria-controls="general" role="tab" data-toggle="tab">通用</a></li>
					<li role="presentation" id="noSecretDocNav"><a
						href="#noSecretDoc" aria-controls="noSecretDoc" role="tab"
						data-toggle="tab">非密级文档</a></li>
					<li role="presentation" id="secretDocNav"><a href="#secretDoc"
						aria-controls="secretDoc" role="tab" data-toggle="tab">密级文档</a></li>
				</ul>

				<!-- Tab panes -->
				<div class="tab-content">
					<div role="tabpanel" class="tab-pane" id="normal"
						style="padding: 20px">
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.normal.extuser.forbid"></div>
								<div>外协用户禁止文件外发</div>
							</div>
						</div>
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.normal.approve.enable"></div>
								<div>文件外发进行审批
								    <span id="customer.storbox.sendfile.normal.approve.id" style="color: #337ab7; text-decoration: none;"></span>
								</div>
							</div>
							<div class="ui-explain">
								如果未指定审批人，将默认由部门负责人进行审批
								&nbsp;&nbsp; <a onclick="getapprove('customer.storbox.sendfile.normal.approve.id')">指定/变更审批人</a>   
								&nbsp;&nbsp;<a onclick="deleteApprove('customer.storbox.sendfile.normal.approve.id',0)">删除审批人</a>
							</div>
						</div>
						<div class="ui-row">
							<div class="checkbox-group">
								<div>文件外发范围</div>
							</div>
						</div>
						<div class="ui-row">
							<div class="form-group">
								<label class="radio-inline"> <input type="radio"
									value="all"
									name="customer.storbox.sendfile.normal.approve.range">所有人
								</label> <label class="radio-inline"> <input type="radio"
									value="employer"
									name="customer.storbox.sendfile.normal.approve.range">企业用户
								</label>
							</div>
						</div>
						<div class="ui-btn ui-btn-default" onclick="normalSave()">保存</div>

					</div>

					<div role="tabpanel" class="tab-pane" id="general"
						style="padding: 20px">
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.secretlevel.extuser.forbid"></div>
								<div>外协用户禁止文件外发</div>
							</div>
						</div>
						<div class="ui-btn ui-btn-default" onclick="generalSave()">保存</div>

					</div>

					<div role="tabpanel" class="tab-pane" id="noSecretDoc"
						style="padding: 20px">
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.notsecret.approve.enable"></div>
								<div>文件外发进行审批 <span id="customer.storbox.sendfile.notsecret.approve.id" style="color: #337ab7; text-decoration: none;">
								     <span class="glyphicon glyphicon-remove"></span>
								</div>
							</div>
							<div class="ui-explain">
							如果未指定审批人，将默认由部门负责人进行审批
								     &nbsp;&nbsp;<a onclick="getapprove('customer.storbox.sendfile.notsecret.approve.id')">指定/变更审批人</a>
									 &nbsp;&nbsp;<a onclick="deleteApprove('customer.storbox.sendfile.notsecret.approve.id',0)">删除审批人</a>
							</div>
						</div>
						<div class="ui-row">
							<div class="checkbox-group">
								<div>文件外发范围</div>
							</div>
						</div>
						<div class="ui-row">
							<div class="form-group">
								<label class="radio-inline"> <input type="radio"
									value="all"
									name="customer.storbox.sendfile.notsecret.approve.range">所有人
								</label> <label class="radio-inline"> <input type="radio"
									value="employer"
									name="customer.storbox.sendfile.notsecret.approve.range">企业用户
								</label>
							</div>
						</div>
						<div class="ui-btn ui-btn-default" onclick="noSecretDocSave()">保存</div>
					</div>


					<div role="tabpanel" class="tab-pane" id="secretDoc"
						style="padding: 20px">
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.secretdoc.approve.enable"></div>
								<div>允许带密级的文件外发</div>
							</div>
						</div>
						<div class="ui-row">
							<div class="checkbox-group">
								<div>设置外发文件允许等级</div>
							</div>
						</div>
						<div class="ui-row">
							<select class="form-control"
								id="customer.storbox.sendfile.secretdoc.level"
								style="margin-left: 10px; width: 10%">
								<option value="1">秘密</option>
								<option value="2">机密</option>
								<option value="3">绝密</option>
							</select>
						</div>

						<div class="ui-row" style="margin-top: 30px">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.secretdoc.approve.enable"></div>
								<div>文件外发进行审批  <span id="customer.storbox.sendfile.secretdoc.approve.id" style="color: #337ab7; text-decoration: none;"></div>
							</div>
							<div class="ui-explain">
							           如果未指定审批人，将默认由部门负责人进行审批
								&nbsp;&nbsp;<a onclick="getapprove('customer.storbox.sendfile.secretdoc.approve.id')">指定/变更审批人</a>
								&nbsp;&nbsp;<a onclick="deleteApprove('customer.storbox.sendfile.secretdoc.approve.id',0)">删除审批人</a>
							</div>
						</div>

						<div class="ui-row">
							<div class="checkbox-group">
								<div>文件外发范围</div>
							</div>
						</div>

						<div class="ui-row">
							<div class="form-group">
								<label class="radio-inline"> <input type="radio"
									value="all"
									name="customer.storbox.sendfile.secretdoc.approve.range">所有人
								</label> <label class="radio-inline"> <input type="radio"
									value="employer"
									name="customer.storbox.sendfile.secretdoc.approve.range">企业用户
								</label>
							</div>
						</div>

						<div class="ui-btn ui-btn-default" onclick="secretDocSave()">保存</div>
					</div>
				</div>
			</div>
			<!--访问控制-->
			<div class="option-content" id="accessSafe">
				<!-- Nav tabs -->
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#terminal"
						aria-controls="terminal" role="tab" data-toggle="tab">终端访问</a></li>
					<li role="presentation"><a href="#network"
						aria-controls="network" role="tab" data-toggle="tab" style="display: none">网络访问</a></li>
				</ul>
				<div class="tab-content">
					<div role="tabpanel" class="tab-pane active" id="terminal"
						style="padding: 20px">
						<div class="ui-row">
							<div class="checkbox-group">
								<div class="ui-checkbox"
									id="customer.storbox.sendfile.secretdoc.enable"
									onclick="updateAccountConfig(this)"></div>
								<div>禁止移动客户端访问,但以下白名单企业用户除外(不选择表示所有用户均可使用移动客户端进行访问)</div>
							</div>
						</div>
						<table class="table table-bordered" style="width: 60%">
							<thead>
								<tr>
									<td>用户类型</td>
									<td>用户</td>
									<td></td>
								</tr>
							</thead>
							<tbody>
								
							</tbody>
						</table>
						<div class="ui-btn ui-btn-default" onclick="addWhiteList()">添加白名单</div>
					</div>
					<div role="tabpanel" class="tab-pane active" id="network"
						style="padding: 20px"></div>
				</div> 
			</div>
			<!--员工信息安全等级-->
			<div class="option-content" id="employerSafe" style="padding: 20px">
				<div class="ui-row">
					<p>员工信息安全等级越高，就可以持有具有更高密级权限的文件；同时安全等级低的人员在外发文件时候，将自动抄送同部门中信息等级高的同事。</p>
				</div>

				<div class="ui-row">
					<div class="checkbox-group">
						<div class="ui-checkbox"
							id="secretdoc.visitLimit.enable"></div>
						<div>启动密级文档持有限制</div>
					</div>
					<table class="table table-bordered" style="width: 60%">
						<tbody>
							<tr>
								<td>秘密文档</td>
								<td><select class="form-control" id="doc_level_1">
										<option value="1">一级</option>
										<option value="2">二级</option>
										<option value="3">三级</option>
										<option value="4">四级</option>
										<option value="5">五级</option>
								</select></td>
								<td>以下禁止持有</td>
							</tr>
							<tr>
								<td>机密文档</td>
								<td><select class="form-control" id="doc_level_2">
										<option value="1">一级</option>
										<option value="2">二级</option>
										<option value="3">三级</option>
										<option value="4">四级</option>
										<option value="5">五级</option>
								</select></td>
								<td>以下禁止持有</td>
							</tr>
							<tr>
								<td>绝密文档</td>
								<td><select class="form-control" id="doc_level_3">
										<option value="1">一级</option>
										<option value="2">二级</option>
										<option value="3">三级</option>
										<option value="4">四级</option>
										<option value="5">五级</option>
								</select></td>
								<td>以下禁止持有</td>
							</tr>
						</tbody>
					</table>

				</div>
				<div class="ui-btn ui-btn-default" onclick="saveVisitSecretDoc()">保存</div>
			</div>
			<!--文档密级-->
			<div class="option-content" id="fileLeve">
				<div class="ui-row">
					<div class="checkbox-group">
						<div class="ui-checkbox"
							id="secretdoc.securityCreator.enable"></div>
						<div>允许信息安全专员可以设置文档密级</div>
					</div>
				</div>
				<div class="ui-row">
					<div class="checkbox-group" style="width: 40%; float: left;">
						<div class="ui-checkbox"
							id="secretdoc.staffCreator.enable"></div>
						<div>只有员工达到对应信息安全等级才能设置文档密级</div>
					</div>
					<div style="width: 60%">
						<select class="form-control" style="width: 15%"
							id="secretdoc.staffCreator.secretlevel">
							<option value="1">一级</option>
							<option value="2">二级</option>
							<option value="3">三级</option>
							<option value="4">四级</option>
							<option value="5">五级</option>
						</select>
					</div>
				</div>
				<div class="ui-btn ui-btn-default" onclick="saveFileLevel()">保存</div>
			</div>
		</div>
	</div>
</body>
</html>