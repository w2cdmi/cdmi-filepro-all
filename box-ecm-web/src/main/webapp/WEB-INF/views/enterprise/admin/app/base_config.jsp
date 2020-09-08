<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%
	request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<meta charset="UTF-8">
<title>Title</title>
<link href="${ctx}/static/enterprise/base_config/base_config.css"
	type="text/css" rel="stylesheet">
<script src="${ctx}/static/enterprise/base_config/base_config.js"></script>
</head>
<div class="content">
	<input type="hidden" id="token" name="token"
		value="<c:out value='${token}'/>" /> <input type="hidden" id="appId"
		name="appId" />
	<div class="c_main">
		<div class="option-header">
			<div class="option-item option-header-active" value="baseconfig">功能参数</div>
			<div class="option-item" value="domainconfig">域名访问</div>
			<div class="option-item" value="versionconfig">版权管理</div>
			<div class="option-item" value="spaceconfig">配额管理</div>
			<div class="option-item" value="mailconfig">邮件参数设置</div>
			<!-- <div class="option-item" value="clientmade">定制客户端</div> -->
		</div>
		<!--功能参数-->
		<div class="option-content" style="padding-right: 200px;"
			id="baseconfig">
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" onclick="openOrganization()"
						id="organization"></div>
					<div>启用组织机构</div>
				</div>
				<div class="ui-explain">一般的说当企业人数少于50人时，可以不使用组织结构模块，人员的管理可以采用群组方式进行管理该选项一旦被选择，则不允许取消。</div>
			</div>
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" onclick="updateAccountConfig(this)"
						id="customer.storbox.staff.staffid.enable"></div>
					<div>启用企业员工工号登陆</div>
				</div>
				<div class="ui-explain">
					启用后，员工可以通过员工工号进行登陆系统。如果是公有云，企业员工通过企业域名/员工工号进行登陆(需要判断部署环境是否是公有云还是私有云，公有云要提示使用企业二级域名路径下使用员工工号登陆或在通用登陆页面上使用企业域名/员工工号登陆，如果是私有云就直接提示可通过员工工号进行登陆系统)
				</div>
			</div>
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" onclick="updateAccountConfig(this)"
						id="customer.storbox.doc.secretlevel.enable"></div>
					<div>启用文档密级安全控制功能</div>
				</div>
				<div class="ui-explain">可设置文档为秘密，机密，绝密等级，不同等级的文档的操作许可不同</div>
			</div>
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" onclick="updateAccountConfig(this)"
						id="customer.storbox.staff.secretlevel.enable"></div>
					<div>启用员工信息安全等级控制</div>
				</div>
				<div class="ui-explain">启用后，低级别员工文档外发时候，自动抄送本部门或本群组内信息安全级别高的用户</div>
			</div>
			<!-- <div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox"></div>
					<div>启用短信网关功能</div>
				</div>
				<div class="ui-explain">
					<div class="order-message">订购短信包</div>
					<div class="config-message">配置短信网关</div>
				</div>
			</div> -->
			<!-- <div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox"></div>
					<div>启用邮件服务功能</div>
				</div>
				<div class="ui-explain">
					<div class="config-email-serve-info">重新配置邮件服务器信息</div>
				</div>
			</div> -->
			<div class="ui-row">
				<div class="ui-btn save-config-func">保存</div>
			</div>
		</div>
		<!--域名访问-->
		<div class="option-content" id="domainconfig">
			<div class="ui-row">
				<div>设置二级访问域名或绑定客户自有域名</div>
				<div style="font-size: 12px; color: #889097; margin-top: 5px;">如果是私有云，则只会出现绑定自有域名</div>
			</div>
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" id="customer.storbox.subdomain.enable"></div>
					<div>使用二级域名</div>
				</div>

				<div style="width: 300px; margin-top: 5px; margin-left: 20px;">

					<form action="">
						<div class="input-group">
							<input type="text" class="form-control" id="customer.storbox.subdomain.value">
							<span class="input-group-addon">.storbox.cn</span>
						</div>
					</form>
				</div>
			</div>
			<div class="ui-row">
				<div class="checkbox-group">
					<div class="ui-checkbox" id="customer.storbox.inddomain.enable"></div>
					<div>使用自有域名</div>
				</div>
				<div class="ui-explain">收费功能，与版权信息，定制客户端一起，可以为你生成具有你完全版权信息的应用，不过这里可能存在证书问题</div>
				<div style="margin-top: 5px; margin-left: 20px;">
					<input type="text" class="personal-domain" id="customer.storbox.inddomain.value"  style="padding: 6px 12px;"/>
					<span style="color: #889097; line-height: 32px; font-size: 12px;">如何配置域名，请参看</span>
				</div>
			</div>
			<div class="ui-btn save-config-domain" onclick="saveDomain()">保存</div>
		</div>
		<div class="option-content" id="versionconfig">
			<form action="" id="versionconfigFrom">
				<div class="row">
					<div class="ui-row" style="height: 25px;">
						<div>对Office以外的文档提供多版本支持</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="multiVersionContentSelect" name="configSelect">
							<option value="true">是</option>
							<option value="false">否</option>
						</select>
					</div>
					<div class="col-xs-3">
					    <div class="input-group">
						 	<input type="text" class="form-control" placeholder='多种文件以,分隔后缀名'
								id="multiVersionContent" name="multiVersionContent">
						</div>
					</div>
				</div>

				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>支持多版本文件的大小</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="maxVersionFileSizeSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" placeholder='请填写文件大小上限'
								id="maxVersionFileSize" name="maxVersionFileSize"> <span
								class="input-group-addon">MB</span>
						</div>
					</div>
				</div>
				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>个人文件最大版本数</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="userVersionsSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" placeholder='请填写文件最大版本数'
								id="userVersions" name="userVersions"> <span
								class="input-group-addon" id="basic-addon2">个</span>
						</div>
					</div>
				</div>
				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>项目文件最大版本数</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="teamSpaceVersionsSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" placeholder='请填写文件最大版本数'
								id="teamSpaceVersions" name="teamSpaceVersions"> <span
								class="input-group-addon">个</span>
						</div>
					</div>
				</div>
			</form>
			<div class="ui-row" style="margin-top: 10px">
				<div class="ui-btn save-config-func" onclick="saveVersionconfig()">保存</div>
			</div>
		</div>
		<form id="spaceConfigForm" method="post">
			<div class="option-content" id="spaceconfig">
				<div class="ui-row">
					<div>为员工及团队空间设置配额，可以更精细化的管理存储资源的开销</div>
				</div>

				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>个人空间总容量</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="userSpaceQuotaSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" placeholder='请填写最大容量'
								id="userSpaceQuota" name="userSpaceQuota"> <span
								class="input-group-addon">GB</span>
						</div>
					</div>
				</div>

				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>项目空间总容量</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="teamSpaceQuotaSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" id="teamSpaceQuota"
								name="teamSpaceQuota" placeholder='请填写最大容量'> <span
								class="input-group-addon">GB</span>
						</div>
					</div>
				</div>

				<div class="row" style="margin-top: 20px">
					<div class="ui-row" style="height: 25px;">
						<div>项目空间文件总数量</div>
					</div>
					<div class="col-xs-3">
						<select class="form-control" id="maxTeamSpacesSelect" name="configSelect">
							<option value="false">无限制</option>
							<option value="true">限制</option>
						</select>
					</div>
					<div class="col-xs-3">
						<div class="input-group">
							<input type="text" class="form-control" id="maxTeamSpaces"
								name="maxTeamSpaces" placeholder='请填写最大数量'> <span
								class="input-group-addon">个</span>
						</div>
					</div>
				</div>
				<div class="ui-row">
					<div class="ui-btn save-config-func" onclick="saveSpaceConfig()">保存</div>
				</div>
			</div>

		</form>
		<div class="option-content" id="mailconfig">
			<div class="ui-row">
				<div>说明:移动客户端如果提供了收发邮件的功能，则需要在这里设置邮箱服务器</div>
			</div>
			<div class="ui-row">
				<div class="custom-client-header">收件箱参数设置</div>
			</div>
			<div class="ui-row">
				<form class="form-horizontal">
					<div class="form-group">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器地址：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="serverReceive"
								name="serverReceive" style="width: 80%" placeholder="">
						</div>
					</div>
					<div class="form-group" style="margin-top: 10px">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器通讯协议：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="protocolReceive"
								name="protocolReceive" style="width: 80%" placeholder="">
						</div>
					</div>
					<div class="form-group" style="margin-top: 10px">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器端口号：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="portReceive"
								name="portReceive" style="width: 80%" placeholder="">
						</div>
					</div>
				</form>
			</div>

			<div class="ui-row">
				<div class="custom-client-header">发件箱参数设置</div>
			</div>
			<div class="ui-row">
				<form class="form-horizontal">
					<div class="form-group">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器地址：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="serverSend"
								name="serverSend" style="width: 80%" placeholder="">
						</div>
					</div>
					<div class="form-group" style="margin-top: 10px">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器通讯协议：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="protocolSend"
								name="protocolSend" value="smtp" style="width: 80%"
								placeholder="">
						</div>
					</div>
					<div class="form-group" style="margin-top: 10px">
						<label for="inputEmail3" class="col-sm-2 control-label">服务器端口号：</label>
						<div class="col-sm-10">
							<input type="text" class="form-control" id="portSend"
								name="portSend" style="width: 80%" placeholder="">
						</div>
					</div>
					<div class="ui-row" style="text-align: center;">
						<div class="ui-btn save-config-func" onclick="saveAccountEmail()">保存</div>
					</div>
				</form>
			</div>

		</div>
		<!--定制客户端-->
		<div class="option-content" id="clientmade">
			<div class="custom-client-box">
				<div class="custom-client-header">使用个性化移动客户端的好处</div>
				<div class="ui-row-p10">
					<div class="custom-client-title">1.对于公有云用户使用移动客户端时候，无须输入域名和登录用户名</div>
					<div class="ui-btn-small">查看原因</div>
				</div>
				<div class="ui-row-p10">
					<div class="custom-client-title">2.对于私有云用户无须使用移动端时候，修改服务器路径配置</div>
					<div class="ui-btn-small">查看原因</div>
				</div>
				<div class="ui-row-p10">
					<div class="custom-client-title">3.使用企业自有的宣传导航页面</div>
					<div class="ui-explain">制作费用2000RMB，特殊需求协商报价</div>
				</div>
				<div class="ui-row-p10">
					<div class="custom-client-title">4.可以与目前使用的其他应用集成</div>
					<div class="ui-explain">需根据需求额外协商报价</div>
				</div>
			</div>
			<!--已拥有-->
			<div class="custom-client-y" style="display: none;">
				<div style="line-height: 50px; color: #525353;">你已经拥有了个性化的移动客户端:</div>
				<div class="ui-row cc-list">
					<div class="cc-item">
						<div class="cc-icon-windows icon icon-windows"></div>
						<div class="cc-item-name">Windows</div>
						<div class="cc-item-update">更新：2017.01.01</div>
						<div class="cc-item-btn">升级</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-android icon icon-android"></div>
						<div class="cc-item-name">Android</div>
						<div class="cc-item-update">更新：2017.01.01</div>
						<div class="cc-item-btn">升级</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-iphone icon icon-iphone"></div>
						<div class="cc-item-name">iphone</div>
						<div class="cc-item-update">更新：2017.01.01</div>
						<div class="cc-item-btn">升级</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-ipad icon icon-pad"></div>
						<div class="cc-item-name">ipad</div>
						<div class="cc-item-update">更新：2017.01.01</div>
						<div class="cc-item-btn">升级</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-mac icon icon-mac"></div>
						<div class="cc-item-name">MAC</div>
						<div class="cc-item-update">更新：2017.01.01</div>
						<div class="cc-item-btn">升级</div>
					</div>
				</div>
			</div>
			<!--未拥有-->
			<div class="custom-client-n">
				<div style="line-height: 50px; color: #525353;">你尚未拥有个性化的移动客户端，如果你希望可以定制移动端，请与我们联系</div>
				<div class="ui-row cc-list">
					<div class="cc-item">
						<div class="cc-icon-windows icon icon-windows"></div>
						<div class="cc-item-name">Windows</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-android icon icon-android"></div>
						<div class="cc-item-name">Android</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-iphone icon icon-iphone"></div>
						<div class="cc-item-name">iphone</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-ipad icon icon-pad"></div>
						<div class="cc-item-name">ipad</div>
					</div>
					<div class="cc-item">
						<div class="cc-icon-mac icon icon-mac"></div>
						<div class="cc-item-name">MAC</div>
					</div>
				</div>
				<div class="ui-row">
					<div class="ccn-item">
						<div class="ccn-icon-offer icon icon-offer"></div>
						<div style="margin: 8px 0;">基础报价</div>
						<div style="color: #3c95ff;">2000RMB</div>
						<div style="font-size: 12px; color: #889097;">五种客户端</div>
					</div>
					<div class="ccn-item">
						<div class="ccn-icon-tel icon icon-tel"></div>
						<div style="margin: 15px 0;">联系电话</div>
						<div style="color: #3c95ff;">4000283273</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>



<script type="text/javascript">
    
	$(document).ready(function() {

		$("#baseconfig").css("display", "block");
		$("#appId").val(window.parent.defaltAppId);
		initAllConfig();

	});

	function initAllConfig() {
		initBasicConfig();
		initOrganization();
	}

	function initOrganization() {
		var params = {
			"token" : "${token}"
		};
		$.ajax({
			type : "POST",
			url : '${ctx}/enterprise/admin/isOpenOrganization',
			data : params,
			error : function(request) {
				handlePrompt("error",
						'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				if (data == true) {
					$("#organization").addClass("ui-checkbox-selected");
				}
			}
		})
	}

	function openOrganization(that) {
		ymPrompt.confirmInfo({
					title : '<spring:message code="enterprise.organizational.switch"/>',
					message : '<spring:message code="enterprise.organizational.switch"/>'
							+ '<br/>'
							+ '<spring:message code="enterprise.org.switch.warn"/>',
					width : 450,
					closeTxt : '<spring:message code="common.close"/>',
					handler : function(tp) {
						if (tp == "ok") {
							var params = {
								"token" : "<c:out value='${token}'/>",
							};
							$.ajax({
										type : "POST",
										url : '${ctx}/enterprise/admin/openOrganization',
										data : params,
										error : function(request) {
											handlePrompt("error",
													'<spring:message code="common.operationFailed" />');
										},
										success : function(data) {
										}
									})
						} 
					},
					btn : [
							[ '<spring:message code="common.OK"/>', "ok" ],
							[ '<spring:message code="common.cancel"/>',
									"cancel" ] ]
				});
	}

	function initBasicConfig() {
		var appId = $("#appId").val();
		var params = {
			"token" : "<c:out value='${token}'/>",
		};
		$.ajax({
			type : "GET",
			url : '${ctx}/enterprise/admin/basicconfig/config/' + appId,
			data : params,
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
			data : params,
			error : function(request) {
				handlePrompt("error",
						'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				for (var i = 0; i < data.length; i++) {
					fullBasicSelect(data[i]);

				}
			}
		})
	}
	function fullBasicInput(basicconfig) {
		for(var k in basicconfig){
			if($("[id='" + k + "']").is("input")){
				$("[id='" + k + "']").val(basicconfig[k]);
			}
			if(basicconfig[k]==-1||basicconfig[k]==""){
				$("#"+k+"Select").val("false");
				$("#"+k).parent().parent().css("display","none");
			}else{
				$("#"+k+"Select").val("true");
			}
		}
		
		
	}
	
	function fullBasicSelect(config) {
		if($("[id='" + config.name + "']").is("input")){
			$("[id='" + config.name + "']").val(config.value);
		}
		if (config.value == "true") {
			$("[id='" + config.name + "']").addClass("ui-checkbox-selected");
		}
	}

	function updateAccountConfig(th) {
		var appId = $("#appId").val();
		var value;
		if ($(th).attr("class") == "ui-checkbox") {
			value = "true";
		} else {
			value = "false";
		}
		var params = {
			"token" : "<c:out value='${token}'/>",
			"name" : $(th).attr("id"),
			"value" : value
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
				console.debug(data);
			}
		})

	}

	function saveSpaceConfig() {
		var appId = $("#appId").val();
		setParameter();
		$.ajax({
			type : "POST",
			url : "${ctx}/enterprise/admin/basicconfig/save?appId="+appId+"&token="+"<c:out value='${token}'/>",
			data : $('#spaceConfigForm').serialize(),
			error : function(request) {
				top.handlePrompt("error",
						'<spring:message code="common.saveFail"/>');
			},
			success : function() {
				top.handlePrompt("success",
						'<spring:message code="common.saveSuccess"/>');
			}
		});
		var pageH = $("body").outerHeight();
		top.iframeAdaptHeight(pageH);
	}
	
	function setParameter(){
		
		if($("#userSpaceQuotaSelect").val() == "false") $("#userSpaceQuota").val("-1");
		if($("#teamSpaceQuotaSelect").val() == "false") $("#teamSpaceQuota").val("-1") ;
		if($("#maxTeamSpacesSelect").val() == "false") $("#maxTeamSpaces").val("-1");
		if($("#multiVersionContentSelect").val() == "false") $("#multiVersionContent").val("") ;
		if($("#maxVersionFileSizeSelect").val() == "false" ) $("#maxVersionFileSize").val("-1") ;
		if($("#userVersionsSelect").val() == "false") $("#userVersions").val("-1") ;
		if($("#teamSpaceVersionsSelect").val() == "false" ) $("#teamSpaceVersions").val("-1");
		
	}
	
	function saveAccountEmail() 
	{
		var appId = $("#appId").val();
	    var receiveEmailConfig = $("#serverReceive").val() + ";" +  $("#protocolReceive").val() + ";" +  $("#portReceive").val();
	    var sendEmailConfig = $("#serverSend").val() + ";" +  $("#protocolSend").val() + ";" +  $("#portSend").val();
	    $.ajax({
	        type: "POST",
	        async:false,
	        url:"${ctx}/enterprise/admin/accountEmail",
	        data:{emailConfig:receiveEmailConfig+","+sendEmailConfig, appId:appId, token:'${token}'},
	        error: function(request) {
	        	 alert('<spring:message code="common.saveFail"/>');
	        },
	        success: function() {
	             alert('<spring:message code="common.saveSuccess"/>');
	            /* window.location.reload(); */
	        }
	    });
	}
	function saveVersionconfig(){
		setParameter();
		var appId = $("#appId").val();
        $.ajax({
			type : "POST",
			url : "${ctx}/enterprise/admin/basicconfig/save?appId="+appId+"&token="+"<c:out value='${token}'/>",
			data : $('#versionconfigFrom').serialize(),
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

	function saveDomain(){
		var appId = $("#appId").val();
		var subdomainEnable=$("[id='customer.storbox.subdomain.enable']").attr("class") == "ui-checkbox"?"false":"true";
		var inddomainEnable=$("[id='customer.storbox.inddomain.enable']").attr("class") == "ui-checkbox"?"false":"true";
		var subdomainValue=$("[id='customer.storbox.subdomain.value']").val();
		var inddomainValue=$("[id='customer.storbox.inddomain.value']").val();
		var json="[{'name':'customer.storbox.subdomain.enable','value':'"+subdomainEnable+"'},{'name':'customer.storbox.inddomain.enable','value':'"+inddomainEnable+"'},"+
			      "{'name':'customer.storbox.subdomain.value','value':'"+subdomainValue+"'},{'name':'customer.storbox.inddomain.value','value':'"+inddomainValue+"'}]";
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
	
	$("select[name='configSelect']").change(function(){
		 var value=$(this).val();
		 if(value=="true"){
			 $(this).parent().next().css("display","block");
		 } else{
			 $(this).parent().next().css("display","none");
		 }
	});
	
	
</script>
</html>
