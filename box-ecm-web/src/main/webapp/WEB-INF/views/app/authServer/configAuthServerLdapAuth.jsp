<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<%@ page import="java.util.*"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%
request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
<%@ include file="../../common/messages.jsp"%>
<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />
<script src="${ctx}/static/zTree/jquery.ztree.core-3.5.js" type="text/javascript"></script>
<script src="${ctx}/static/zTree/jquery.ztree.excheck-3.5.js" type="text/javascript"></script>
</head>
<body>

<div class="sys-content sys-content-en">
	<div class="clearfix control-group">
		<a  class="return btn btn-small pull-right" href="${ctx}/enterprise/admin/authserver/enterList">
		<i class="icon-backward"></i>&nbsp;<spring:message  code="common.back"  /></a>
		<h5 class="pull-left" style="margin: 3px 0 0 4px;"><a href="${ctx}/enterprise/admin/authserver/enterList">${authServer.name}</a>&nbsp;>&nbsp;<spring:message code="configAuthServerLdapAuth.paramter.setter"/></h5>
	</div>
	<div class="alert"><i class="icon-lightbulb"></i><spring:message  code="cluterManager.lightbulb"  /></div>
	<div class="form-horizontal form-con clearfix">
   	    <h5><spring:message  code="cluterManager.configlink"  /></h5>
        <form id="ldapBasciConfig" class="form-horizontal">
        <input type="hidden" id="authServerId" name="authServerId" value="${authServer.id}" />
        <input type="hidden" name="token" id="token" value="${token}"/>
        <input type="hidden" id="securityProtocol" name="securityProtocol" value="<c:out value='${serverConfig.ldapBasicConfig.securityProtocol}'/>" />
        <div class="control-group" id="ldapBasciConfigDiv">
	   	    <div class="control-group">
	   	    
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.controlDomain"  />:</label>
	            <div class="controls">
	                <textarea class="span8" rows="4" type="text" id="domainControlServer" name="domainControlServer" 
	                placeholder='<spring:message  code="clusterManage.domainControlServer"  />'>${serverConfig.ldapBasicConfig.domainControlServer}</textarea>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message code="authorize.ladpport"/>:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="ldapPort" name="ldapPort" value="${serverConfig.ldapBasicConfig.ldapPort == null ? 389 : serverConfig.ldapBasicConfig.ldapPort}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	         <div class="control-group">
	            <label class="control-label" for="input"><em>*</em>Base DN:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="ldapBaseDN" name="ldapBaseDN" value="${serverConfig.ldapBasicConfig.ldapBaseDN}"/>
	                <span class="validate-con"><div></div></span>
	                <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('baseDN.html','520','260')" ><i class="icon-question-sign icon-green"></i></a></div>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.BindAccount"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="ldapBindAccount" name="ldapBindAccount" placeholder='<spring:message  code="clusterManage.ldapBindAccount"  />' value="${serverConfig.ldapBasicConfig.ldapBindAccount}" />
	                <span class="validate-con"><div></div></span>
	                <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('bindAccount.html','520','260')" ><i class="icon-question-sign icon-green"></i></a></div>
	            </div>
	        </div>
			<div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.bindAccountPassword"  />:</label>
	            <div class="controls">
	                <input class="span4" type="password" id="ldapBindAccountPassword" name="ldapBindAccountPassword" value="${serverConfig.ldapBasicConfig.ldapBindAccountPassword}" autocomplete="off" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
             <div class="controls controls-row">
                <label class="radio inline"><input type="radio" onclick="closeProtocol()"  id="protocolClose" name="protocolRadio"  <c:if test="${serverConfig.ldapBasicConfig.securityProtocol=='close'}">checked="checked"</c:if> /><spring:message code="adServer.protocol.close"/> </label>
                <label class="radio inline"><input type="radio" onclick="openProtocolSSL()" id="protocolSSL" name="protocolRadio" title='<spring:message code="mailServer.chkEnableSSL"/>' <c:if test="${serverConfig.ldapBasicConfig.securityProtocol=='ssl'}">checked="checked"</c:if> />SSL</label>
                <label class="radio inline"><input type="radio" onclick="openProtocolTLS()" id="protocolTLS" name="protocolRadio" title='<spring:message code="adServer.protocol.tls.title"/>' <c:if test="${empty serverConfig.ldapBasicConfig.securityProtocol || serverConfig.ldapBasicConfig.securityProtocol =='tls'}">checked="checked"</c:if>  />TLS</label>
                <div class="help-inline"><a class="inline" href="javascript:void(0)" onclick="showMoive()"><i class="icon-question-sign icon-green"></i></a></div>
                <span class="help-block"><spring:message code="adServer.help-block"/></span>
             </div>
           </div>
	    </div>
	    <div id="ntlmDiv"> 
	        <div class="control-group">
	            <div class="controls">
	                <label class="checkbox" for="input"><input type="checkbox" id="isNtlm" name="isNtlm" value="" onclick="changeNtlmConfig()"/><spring:message  code="authorize.supportNTLMAutoLogin.v2"  /></label>
	            </div>
	        </div>
	        <div class="control-group" id="ntlmPcAccountDiv">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.computerAccount"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="ntlmPcAccount" name="ntlmPcAccount" placeholder='<spring:message  code="clusterManage.ntlmPcAccount"  />' value="${serverConfig.ldapBasicConfig.ntlmPcAccount}"/>
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
			<div class="control-group" id="ntlmPcAccountPasswdDiv">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.computerPassword" />:</label>
	            <div class="controls">
	                <input class="span4" type="password" id="ntlmPcAccountPasswd" name="ntlmPcAccountPasswd" value="${serverConfig.ldapBasicConfig.ntlmPcAccountPasswd}" autocomplete="off"/>
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group" id="netBiosDomainNameDiv">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.NetBIOSRegion"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="netBiosDomainName" name="netBiosDomainName" value="${serverConfig.ldapBasicConfig.netBiosDomainName}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group" id="ldapDnsDiv">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.domainControlName"  />:</label>
	            <div class="controls">
	                <textarea class="span8" rows="4" type="text" id="ldapDns" name="ldapDns" placeholder='<spring:message  code="clusterManage.ldapDns"  />'>${serverConfig.ldapBasicConfig.ldapDns}</textarea>
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group" id="checkIPDiv">
	        	<label class="control-label" for="input"><em>*</em><spring:message code="authorize.checkIp.label"/>:</label>
	        	<div class="controls">
	        		<label class="radio inline" for="input"><input type="radio" id="isCheckIpYes" title='<spring:message code="authorize.checkIp.yes"/>' name="isCheckIp"  value ="true"<c:if test="${empty serverConfig.ldapBasicConfig.isCheckIp || serverConfig.ldapBasicConfig.isCheckIp==true}">checked="checked"</c:if> />
	        		<spring:message code="authorize.checkIp.yes"/></label>
	        		<label class="radio inline" for="input"><input type="radio" id="isCheckIpNo" title='<spring:message code="authorize.checkIp.no"/>' name="isCheckIp"  value ="false"<c:if test="${serverConfig.ldapBasicConfig.isCheckIp==false}">checked="checked"</c:if> />
	        		<spring:message code="authorize.checkIp.no"/></label>
	        	</div>
	        </div>
        </div>
        <div class="control-group">
            <div class="controls">
                <input type="button" class="btn btn-primary" id="ldapCreateButton" name="ldapCreateButton" value="<spring:message  code="common.save"/>" onclick="submitLdapBasicConfig()"/>
                <input type="button" class="btn" id="testLdapButton" name="testLdapButton" value="<spring:message  code="common.testConnection"/>" onclick="testConfig()"/>
                <input type="button" class="btn" id="testNtlmButton" name="testNtlmButton" value='<spring:message  code="clusterManage.testNtlmButton"/>' onclick="testNtlmConfig()"/>
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        </form>
        <form id="ldapNodeFilter" class="form-horizontal">
        <input type="hidden" name="token3" id="token3" value="${token}"/>
         <div id="ldapNodeFilterDiv">
         <h5><spring:message  code="clusterManage.sync.filter"/></h5>
         <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.node.filter"/>:</label>
	            <div class="controls">
	                <input class="span3" type="text" id="ldapNodeBaseDN" name="ldapNodeBaseDN" placeholder="DC=china,DC=huawei,DC=com" 
	                value="${serverConfig.ldapBasicConfig.ldapNodeBaseDN}"/>	    
	                 <span class="validate-con bottom inline-span3"><div></div></span>        
	                <input class="span4" type="text" id="searchNodeFilter" name="searchNodeFilter" placeholder="(objectClass=organizationalUnit)" 
	                value="${serverConfig.ldapBasicConfig.searchNodeFilter}"/>
	                <span class="validate-con  bottom inline-span4"><div></div></span>
	                <input type="button" class="btn" id="syncFilterButton" name="syncFilterButton" value='<spring:message  code="clusterManage.filter"/>' onclick="submitNodeFilter()"/>
	                <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('nodeFilter.html','570','260')" ><i class="icon-question-sign icon-green"></i></a></div>
	            </div>
	        </div> 
        </div>
        </form>
        <form id="ldapSyncFilterConfig" class="form-horizontal">
        <input type="hidden" name="token4" id="token4" value="${token}"/>
        <input type="hidden" name="syncCycle" id="syncCycle"/>
        <input type="hidden" name="syncNode" id="syncNode" value="${serverConfig.ldapNodeFilterConfig.syncNode}"/>
        <input type="hidden" name="displayNode" id="displayNode" value="${serverConfig.ldapNodeFilterConfig.displayNode}"/>
        <div class="control-group" id="ldapSyncFilterConfigDiv">
	         <div class="control-group">
	            <label class="control-label" for="input"></label>
	            <div class="controls">
	               <label><spring:message  code="clusterManage.select.sync.node"/></label>
                     <ul id="treeArea" class="ztree"></ul>
	            </div>
	        </div>
	         
	          <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.user"/>:</label>
	            <div class="controls">
	                <input class="span8" type="text" id="userObjectClass" name="userObjectClass" placeholder="(&(objectCategory=person)(objectClass=user))" 
	                value="${serverConfig.ldapNodeFilterConfig.userObjectClass}"/>	                
	                <span class="validate-con bottom"><div></div></span>
	                <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('userObject.html','540','260')" ><i class="icon-question-sign icon-green"></i></a></div>
	            </div>
	         </div>
	         
	         <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="clusterManage.group"/>:</label>
	            <div class="controls">
	                <input class="span8" type="text" id="groupObjectClass" name="groupObjectClass" placeholder="(objectClass=group)" 
	                value="${serverConfig.ldapNodeFilterConfig.groupObjectClass}"/>	                
	                <span class="validate-con bottom"><div></div></span>
	                <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('groupObject.html','520','260')" ><i class="icon-question-sign icon-green"></i></a></div>
	            </div>
	        </div>
	         <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="clusterManage.member"/>:</label>
	            <div class="controls">
	                <input class="span8" type="text" id="memberFlag" name="memberFlag" placeholder='<spring:message  code="clusterManage.member.hit"/>'
	                value="${serverConfig.ldapNodeFilterConfig.memberFlag}"/>	                
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	         <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="authorize.quartzSynchronization"  />:</label>
	            <div class="controls">
	                <label class="checkbox" for="input"><input type="checkbox" id="isTimingSync" name="isTimingSync" value="" onclick="changeTimingConfig()"/><spring:message  code="authorize.starts"  /></label>
	            </div>
	        </div>
	        <div class="control-group" id="syncCycleDiv">
	            <label class="control-label" for="input"><spring:message  code="authorize.synchronizationtime"  />:</label>
	            <div class="controls">
	         		<spring:message  code="authorize.everyDay"  /> 
	            	<select id="syncCycleHour" class="span1" type="select">
					</select>： 
					<select id="syncCycleMinutes" class="span1" type="select">
					</select>： 
					<select id="syncCycleSeconds" class="span1" type="select">
					</select>
					<span class="validate-con"><div></div></span>
	            </div>
	        </div>
	          <div class="control-group">
	            <div class="controls">
	                <input type="button" class="btn btn-primary" id="syncFilterConfigButton" name="syncFilterConfigButton" value='<spring:message  code="common.save"/>' onclick="submitLdapNodeFilter()" />
	            </div>
	        </div>
        </div>
        </form>
        <form id="userSearchRule" class="form-horizontal">
        <input type="hidden" name="token5" id="token5" value="${token}"/>
         <div id="userSearchRuleDiv">
         <h5><spring:message  code="clusterManage.user.search"/></h5>
            <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.fuzzy.search"/>:</label>
	            <div class="controls">
	                <textarea class="span8" rows="4" type="text" id="searchFilter" name="searchFilter" placeholder="(&(objectCategory=person)(objectClass=user)(|(cn=[name]*)(sn=[name]*)(sAMAccountName=[name]*)))">${serverConfig.ldapBasicConfig.searchFilter}</textarea>	    
	                 <span class="validate-con bottom"><div></div></span> 
	                 <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('searchFilter.html','570','260')" ><i class="icon-question-sign icon-green"></i></a></div>         
	            </div>
	        </div>
	         <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.advanced.search"/>:</label>
	            <div class="controls">
	                <textarea class="span8" rows="4" type="text" id="syncFilter" name="syncFilter" placeholder="(&(objectCategory=person)(objectClass=user)((sAMAccountName=[name])))">${serverConfig.ldapBasicConfig.syncFilter}</textarea>	    
	                 <span class="validate-con bottom"><div></div></span> 
	                 <div class="help-inline"><a href="javascript:void(0)" onclick="showHelpMessage('syncFilter.html','570','260')" ><i class="icon-question-sign icon-green"></i></a></div>         
	            </div>
	        </div>
	         <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="clusterManage.pagecount"/>:</label>
	            <div class="controls">
	                <input class="span8" type="text" id="pageCount" name="pageCount"  placeholder="1000" value="${serverConfig.ldapBasicConfig.pageCount}"/>
	                <span class="validate-con bottom"><div></div></span>          
	            </div>
	        </div>
	        <div class="control-group">
            <div class="controls">
                <input type="button" class="btn btn-primary" id="userSearchRuleButton" name="userSearchRuleButton" value="<spring:message  code="common.save"/>" onclick="submitUserSearchRule()"/>
            </div>
          </div>
        </div>
        </form>
        <form id="ldapFiledMapping" class="form-horizontal">
        <input type="hidden" id="authServerId" name="authServerId" value="${authServer.id}" />
        <input type="hidden" name="token1" id="token1" value="${token}"/>
		<div  id="ldapFiledMappingDiv">
		<h5><spring:message  code="authorize.synchnronizeFiledMapping"  /></h5>
			<div class="control-group">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<spring:message  code="authorize.PleaseSelectedMatchingFiledMappingSeting"  /></div>
			<div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.uniquelyIdentity"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="uniqueKey" name="uniqueKey" value="${serverConfig.ldapFiledMapping.uniqueKey}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.label.username"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="loginName" name="loginName" value="${serverConfig.ldapFiledMapping.loginName}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><em>*</em><spring:message  code="authorize.label.name"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="name" name="name" value="${serverConfig.ldapFiledMapping.name}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="authorize.label.mail"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="email" name="email" value="${serverConfig.ldapFiledMapping.email}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="authorize.description"  />:</label>
	            <div class="controls">
	                <input class="span4" type="text" id="description" name="description" value="${serverConfig.ldapFiledMapping.description}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <label class="control-label" for="input"><spring:message  code="clusterManage.test.user"  /></label>
	            <div class="controls">
	                <input class="span4" type="text" id="testUserName" name="testUserName" placeholder='<spring:message  code="clusterManage.testUserName"  />' value="${serverConfig.ldapFiledMapping.testUserName}" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	            <div class="controls">
	                <input type="button" class="btn btn-primary" id="syncCreateButton" name="syncCreateButton" value='<spring:message  code="common.save"/>' onclick="submitFiledMapping()" />
	                <input type="button" class="btn"  value='<spring:message  code="clusterManage.match.test"/>' onclick="testFiledMapping()" />
	                <span class="validate-con"><div></div></span>
	            </div>
	        </div>
        </div>
        </form>
	</div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	var protocolVal = $("#securityProtocol").val();
	if("" == protocolVal || null == protocolVal)
	{
	    $("#securityProtocol").val("tls");
	}
	var isNtlm="${serverConfig.ldapBasicConfig.isNtlm}";
	if(isNtlm==true||isNtlm=="true")
	{
		$("#isNtlm").attr("checked",isNtlm);
	}
	else
	{
		$("#isNtlm").removeAttr("checked");
	}	
	
	var isTiming="${serverConfig.ldapNodeFilterConfig.isTimingSync}";
	if(isTiming==true||isTiming=="true")
	{
		$("#isTimingSync").attr("checked",isTiming);
	}
	else
	{
		$("#isTimingSync").removeAttr("checked");
	}
	isTimingSync(isTiming);
	var syncCycle="${serverConfig.ldapNodeFilterConfig.syncCycle}";
	$("#syncCycle").val(syncCycle);
	if(syncCycle!=null && syncCycle!="")
	{
		var syncCycleStr=syncCycle.split(' ');
		if(syncCycleStr.length>3)
		{
			
			for(var i=0; i<24; i++){
				var t = i;
				if(t<10){ t = "0" + t;}
				if(i == syncCycleStr[2]){
					$("#syncCycleHour").append('<option selected val='+ t +'>'+ t +'</option>');
				}else{
					$("#syncCycleHour").append('<option val='+ t +'>'+ t +'</option>');
				}
			}
			for(var i=0; i<60; i++){
				var t = i;
				if(t<10){ t = "0" + t;}
				if(i == syncCycleStr[1]){
					$("#syncCycleMinutes").append('<option selected val='+ t +'>'+ t +'</option>');
				}else{
					$("#syncCycleMinutes").append('<option val='+ t +'>'+ t +'</option>');
				}
			}
			for(var i=0; i<60; i++){
				var t = i;
				if(t<10){ t = "0" + t;}
				if(i == syncCycleStr[0]){
					$("#syncCycleSeconds").append('<option selected val='+ t +'>'+ t +'</option>');
				}else{
					$("#syncCycleSeconds").append('<option val='+ t +'>'+ t +'</option>');
				}
			}
		
		}
	}else{
		for(var i=0; i<24; i++){
			var t = i;
			if(t<10){ t = "0" + t;}
			if(i == 0){
				$("#syncCycleHour").append('<option selected val='+ t +'>'+ t +'</option>');
			}else{
				$("#syncCycleHour").append('<option val='+ t +'>'+ t +'</option>');
			}
		}
		for(var i=0; i<60; i++){
			var t = i;
			if(t<10){ t = "0" + t;}
			if(i == 0){
				$("#syncCycleMinutes").append('<option selected val='+ t +'>'+ t +'</option>');
			}else{
				$("#syncCycleMinutes").append('<option val='+ t +'>'+ t +'</option>');
			}
		}
		for(var i=0; i<60; i++){
			var t = i;
			if(t<10){ t = "0" + t;}
			if(i == 0){
				$("#syncCycleSeconds").append('<option selected val='+ t +'>'+ t +'</option>');
			}else{
				$("#syncCycleSeconds").append('<option val='+ t +'>'+ t +'</option>');
			}
		}
	}
	
	changeAuthType();
	$.validator.addMethod(
			"isValidDomainControlServer", 
			function(value, element) {   
				var pattern = /^[0-9a-zA-Z\-.;]+$/;		    
			    if(!pattern.test(value)){
			 	   return false;
			    }
			    return true;
			}
	); 
	$.validator.addMethod(
			"isMaxDomainControlServer", 
			function(value, element) {   
			    var count = (value.split(';')).length-1;
			    if(count > 9)
			    {
			    	return false;
			    }
			    return true;
			}
	); 
	$.validator.addMethod(
			"groupMemberFlag", 
			function(value, element) {   
				var pattern = /^[0-9a-zA-Z;]*$/;
			    if(!pattern.test(value)){
			 	   return false;
			    }
			    return true;
			}
	); 
	$.validator.addMethod(
			"groupAssociatedMember", 
			function(value, element) {
				var groupValue = $("#groupObjectClass").val();
				var member = $("#memberFlag").val();
				if (groupValue == "" || groupValue == null)
				{
					if (member != "" &&member != null)
					{
					  return false;
					}
				}
				
			    return true;
			}
	); 
	$.validator.addMethod(
			"memberAssociatedGroup", 
			function(value, element) {
				var member = $("#memberFlag").val();
				var groupValue = $("#groupObjectClass").val();
				if(groupValue!=null&&groupValue!=""){
					if (member == "" || member == null)
					{
					  return false;
					}
				}
			    return true;
			}
	); 
	$.validator.addMethod(
			"isValidNetBiosDns", 
			function(value, element) {   
				var pattern = /[\\\/:*?\"\<\>|]+$/;	
				if(null==value||''==value)
				{
					return true;
				}
			    if(pattern.test(value)){
			 	   return false;
			    }
			    return true;
			}
	);
	$.validator.addMethod(
			"isValidNetBiosName", 
			function(value, element) {   
				var pattern = /^[0-9a-zA-Z\-.;]+$/;	
				if(null==value||''==value)
				{
					return true;
				}
			    if(!pattern.test(value)){
			 	   return false;
			    }
			    return true;
			}
	);
	$.validator.addMethod(
			"isCheckedNtlm", 
			function(value, element) {   
				var isChecked=$("#isNtlm").get(0).checked;
				if(isChecked)
				{
					if(null==value||''==value)
					{
						return false;
					}
				}
			    return true;
			}
	);
	validateLdapBasciConfig();
	validateFiledMapping();
	validateNodeFilter();
	validateLdapNodeFilter();
	validateuserSearchRule();
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
	
	if(!placeholderSupport()){
		placeholderCompatible();
	};
});
function changeAuthType()
{
	var authType="${authServer.type}";
	if(authType=="LdapAuth")
	{
		$("#ldapBasciConfigDiv").show();
		$("#ntlmDiv").hide();
		$("#LdapSyncPolicyDiv").show();
		$("#ldapFiledMappingDiv").show();
		$("#ldapNodeFilterDiv").show();
		$("#ldapSyncFilterConfigDiv").show();
		$("#userSearchRuleDiv").show();
		$("#testLdapButton").show();
		$("#ldapCreateButton").show();
		$("#testNtlmButton").hide();
		isNtlmConfig(false);
	}
	if(authType=="AdAuth")
	{
		$("#ldapBasciConfigDiv").show();
		$("#ntlmDiv").show();
		$("#LdapSyncPolicyDiv").show();
		$("#ldapFiledMappingDiv").show();
		$("#ldapNodeFilterDiv").show();
		$("#ldapSyncFilterConfigDiv").show();
		$("#userSearchRuleDiv").show();
		$("#testLdapButton").show();
		$("#ldapCreateButton").show();
		var isChecked=$("#isNtlm").get(0).checked;
		isNtlmConfig(isChecked);
	}
	if(authType=="LocalAuth")
	{
		$("#ldapBasciConfigDiv").hide();
		$("#ntlmDiv").hide();
		$("#LdapSyncPolicyDiv").hide();
		$("#ldapFiledMappingDiv").hide();
		$("#ldapNodeFilterDiv").hide();
		$("#ldapSyncFilterConfigDiv").hide();
		$("#userSearchRuleDiv").hide();
		$("#ldapCreateButton").hide();
		$("#testLdapButton").hide();
		isNtlmConfig(false);
	}
	var pageH = $("body").outerHeight();
	top.iframeAdaptHeight(pageH);
}
function submitLdapBasicConfig() {
	if(!$("#ldapBasciConfig").valid()) {
        return;
    }
	var url="${ctx}/enterprise/admin/configauthserver/configBasic/${authServer.id}";
	doSubmitAjaxPost("ldapBasciConfig", url, '<spring:message  code="common.saveFail"/>', '<spring:message  code="common.saveSuccess"/>');
}

function submitUserSearchRule() {
	if(!$("#userSearchRule").valid()) {
        return;
    }
	var url="${ctx}/enterprise/admin/configauthserver/userSearchRule/${authServer.id}";
	
	doSubmitAjaxPost("userSearchRule", url, '<spring:message  code="common.saveFail"/>', '<spring:message  code="common.saveSuccess"/>');
}

function submitLdapNodeFilter() {	
	if(!$("#ldapSyncFilterConfig").valid()) {
        return;
    }
	getChecked();
	var isTiming=$("#isTimingSync").val();
	if(isTiming==true||isTiming=="true")
	{
		var syncCycle= parseInt($("#syncCycleSeconds").val(),10)+' '+ parseInt($("#syncCycleMinutes").val(),10)+' '+ parseInt($("#syncCycleHour").val(),10) +' * * ?';
		$("#syncCycle").val(syncCycle);
	}
	var url="${ctx}/enterprise/admin/configauthserver/configNodeFilter/${authServer.id}";
	
	doSubmitAjaxPost("ldapSyncFilterConfig", url, '<spring:message  code="common.saveFail"/>', '<spring:message  code="common.saveSuccess"/>');
}

function submitFiledMapping() {
	if(!$("#ldapFiledMapping").valid()) {
        return;
    }
	var url="${ctx}/enterprise/admin/configauthserver/configMapping/${authServer.id}";
	
	doSubmitAjaxPost("ldapFiledMapping", url, '<spring:message  code="common.saveFail"/>', '<spring:message  code="common.saveSuccess"/>');
}

function testConfig(){
	var url="${ctx}/enterprise/admin/testauthserver/testBasicConfig";
	doTestConfig(url);
}
function testNtlmConfig(){
	var url="${ctx}/enterprise/admin/testauthserver/testNtml";
	doTestConfig(url);
}
function testFiledMapping(){
	var url="${ctx}/enterprise/admin/testauthserver/testFiledMapping/${authServer.id}";
	doTestFiledMapping(url);
}


	function submitNodeFilter() {
		if (!$("#ldapNodeFilter").valid()) {
			return;
		}

		$.ajax({
			type : "POST",
			url : "${ctx}/enterprise/admin/configauthserver/filterNode/${authServer.id}" ,
			data : $('#ldapNodeFilter').serialize(),
			error : function(request) {
				top.handlePrompt("error",
						'<spring:message  code="clusterManage.fail.filter"/>');
			},
			success : function(data) {
				if (typeof (data) == 'string' && data.indexOf('<html>') != -1) {
					window.location.reload();
					return;
				}
				if (data != null) {
					initTree(data.name);
					if (data.checked ==true || data.checked  == "true") {
						var zTree = $.fn.zTree.getZTreeObj("treeArea");
						var nodes = zTree.getNodes()[0];
						if(!nodes.checked)
						{
							nodes.checked = true;
							zTree.updateNode(nodes);
						}
					}
				} else {
					top.handlePrompt("error", failMessage);
				}
			}
		});
	}

	function doTestConfig(url) {
		doAjaxPost(url, "ldapBasciConfig",
				'<spring:message code="common.testConnectionFail"/>',
				'<spring:message code="common.testConnectionSuccess"/>');

	}
	function doTestFiledMapping(url) {
		doAjaxPost(url, "ldapFiledMapping",
				'<spring:message code="common.testConnectionFail"/>',
				'<spring:message code="common.testConnectionSuccess"/>');
	}

	function doAjaxPost(url, id, failMessage, suscessMessage) {
		if (!$("#" + id).valid()) {
			return;
		}

		$.ajax({
			type : "POST",
			url : url,
			data : $('#' + id).serialize(),
			error : function(request) {
				top.handlePrompt("error", failMessage);
			},
			success : function(data) {
				if (typeof (data) == 'string' && data.indexOf('<html>') != -1) {
					window.location.reload();
					return;
				}
				if (data == true || data == "true") {
					top.handlePrompt("success", suscessMessage);
				} else {
					top.handlePrompt("error", failMessage);
				}
			}
		});
	}

	function doSubmitAjaxPost(id, url, failMessage, suscessMessage) {
		$.ajax({
			type : "POST",
			url : url,
			data : $('#' + id).serialize(),
			error : function(request) {
				top.handlePrompt("error", failMessage);
			},
			success : function(data) {
				if (typeof (data) == 'string' && data.indexOf('<html>') != -1) {
					window.location.reload();
					return;
				}
				$("#authType").attr("disabled", 'true');
				top.handlePrompt("success", suscessMessage);
			}
		});
	}

	function isNtlmConfig(isNtlm) {
		if (isNtlm == true || isNtlm == "true") {
			$("#isNtlm").attr("checked", isNtlm);
			$("#isNtlm").val(true);
			$("#testNtlmButton").show();
			$("#ntlmPcAccountDiv").show();
			$("#netBiosDomainNameDiv").show();
			$("#ldapDnsDiv").show();
			$("#checkIPDiv").show();
			$("#ntlmPcAccountPasswdDiv").show();
		} else {
			$("#isNtlm").removeAttr("checked");
			$("#isNtlm").val(false);
			$("#ntlmPcAccountDiv").hide();
			$("#testNtlmButton").hide();
			$("#netBiosDomainNameDiv").hide();
			$("#ldapDnsDiv").hide();
			$("#checkIPDiv").hide();
			$("#ntlmPcAccountPasswdDiv").hide();
		}
	}
	function isTimingSync(isTiming) {
		if (isTiming == true || isTiming == "true") {
			$("#isTimingSync").attr("checked", isTiming);
			$("#isTimingSync").val(true);
			$("#syncCycleDiv").show();
		} else {
			$("#isTimingSync").removeAttr("checked");
			$("#isTimingSync").val(false);
			$("#syncCycleDiv").hide();
		}
	}
	function changeTimingConfig() {
		var isTiming = $("#isTimingSync").get(0).checked;
		isTimingSync(isTiming);
		var pageH = $("body").outerHeight();
		top.iframeAdaptHeight(pageH);
	}
	function changeNtlmConfig() {
		var isNtlm = $("#isNtlm").get(0).checked;
		isNtlmConfig(isNtlm);
		var pageH = $("body").outerHeight();
		top.iframeAdaptHeight(pageH);
	}
	function validateLdapBasciConfig() {
		$("#ldapBasciConfig")
				.validate(
						{
							rules : {
								domainControlServer : {
									isValidDomainControlServer : true,
									isMaxDomainControlServer : true,
									required : true,
									minlength : [ 2 ],
									maxlength : [ 1024 ]
								},
								ldapPort : {
									required : true,
									digits : true,
									min : 1,
									max : 65535,
									maxlength : [ 5 ]
								},
								ldapBaseDN : {
									required : true,
									maxlength : [ 2048 ]
								},
								ldapBindAccount : {
									required : true,
									maxlength : [ 127 ]
								},
								ldapBindAccountPassword : {
									required : true,
									maxlength : [ 127 ]
								},
								ntlmPcAccount : {
									isCheckedNtlm:true,
									maxlength : [ 127 ]
								},
								ntlmPcAccountPasswd : {
									isCheckedNtlm:true,
									maxlength : [ 127 ]
								},
								netBiosDomainName : {
									isValidNetBiosDns : true,
									isCheckedNtlm:true,
									maxlength : [ 15 ]
								},
								ldapDns : {
									isValidNetBiosName : true,
									isCheckedNtlm:true,
									minlength : [ 2 ],
									maxlength : [ 63 ]
								}
							},
							messages : {
								domainControlServer : {
									isValidDomainControlServer : '<spring:message  code="common.domain.control.server"/>',
							    	isMaxDomainControlServer : '<spring:message  code="clusterManage.domainControlServer"/>'
								},
								netBiosDomainName : {
									isValidNetBiosDns : '<spring:message  code="common.net.bios.dns"/>',
									isCheckedNtlm : '<spring:message  code="messages.required"/>'
								},
								ldapDns : {
									isValidNetBiosName : '<spring:message  code="common.domain.control.server"/>',
									isCheckedNtlm : '<spring:message  code="messages.required"/>'
								},
								ntlmPcAccount: {
									isCheckedNtlm : '<spring:message  code="messages.required"/>'
								}
								,
								ntlmPcAccountPasswd: {
									isCheckedNtlm : '<spring:message  code="messages.required"/>'
								}
							},
							onkeyup : function(element) {
								$(element).valid();
							},
							onfocusout : false
						});
	}
	function validateFiledMapping() {
		$("#ldapFiledMapping").validate({
			rules : {
				uniqueKey : {
					required : true,
					maxlength : [ 255 ]
				},
				loginName : {
					required : true,
					maxlength : [ 127 ]
				},
				name : {
					required : true,
					maxlength : [ 127 ]
				},
				email : {
					required : false,
					maxlength : [ 255 ]
				},
				description : {
					required : false,
					maxlength : [ 255 ]
				},
				testUserName : {
					required : false,
					maxlength : [ 127 ]
				},
			},
			onkeyup : function(element) {
				$(element).valid();
			},
			onfocusout : false
		});
	}

	function validateNodeFilter() {
		$("#ldapNodeFilter").validate({
			rules : {
				ldapNodeBaseDN : {
					required : true,
					minlength : [ 1 ],
					maxlength : [ 2048 ]
				},
				searchNodeFilter : {
					required : true,
					minlength : [ 1 ],
					maxlength : [ 2048 ]
				},
			},
			onkeyup : function(element) {
				$(element).valid();
			},
			onfocusout : false
		});
	}

	function validateLdapNodeFilter() {
		$("#ldapSyncFilterConfig").validate({
			rules : {
				userObjectClass : {
					required : true,
					minlength : [ 1 ],
					maxlength : [ 512 ]
				},
				groupObjectClass : {
					required : false,
					groupAssociatedMember : true,
					maxlength : [ 512 ]
				},
				memberFlag : {
					required : false,
					memberAssociatedGroup : true,
					maxlength : [ 2048 ],
					groupMemberFlag : true
				}
			},
			messages : {
				groupObjectClass : {
					groupAssociatedMember : '<spring:message  code="common.group.empty"/>'
				},
				memberFlag : {
					groupMemberFlag : '<spring:message  code="common.group.member.flag"/>',
					memberAssociatedGroup : '<spring:message  code="common.group.member.empty"/>',
					groupAssociatedMember : '<spring:message  code="common.group.empty"/>'
				}
			},
			onkeyup : function(element) {
				$(element).valid();
			},
			onfocusout : false
		});
	}

	function validateuserSearchRule() {
		$("#userSearchRule").validate({
			rules : {
				searchFilter : {
					required : true,
					maxlength : [ 2048 ]
				},
				syncFilter : {
					required : true,
					maxlength : [ 2048 ]
				},
				pageCount : {
					digits : true,
					min : 1,
					max : 1000
				},
			},
			onkeyup : function(element) {
				$(element).valid();
			},
			onfocusout : false
		});
	}

	function validateSyncCycle() {

	}
	function changeAutoCreateUser(isAuto) {
		$("#isAutoCreateUser").val(isAuto);
	}

	//ldap
	function initTree(name) {
		var setting = {
			async : {
				enable : true,
				url : "${ctx}/enterprise/admin/configauthserver/listTreeNode/${authServer.id}",
				autoParam : [ "baseDn", "page"],
				otherParam: { "token":"${token}"}
				
			},
			check : {
				enable : true
			},
			data : {
				simpleData : {
					enable : true
				}
			},
			view : {
				expandSpeed : "",
				showIcon : false
			},
			callback : {
				onAsyncSuccess: onAsyncSuccess,
				onAsyncError : onAsyncError
			}
		};

		var zNodes = [ {name : name, page : 0, isParent : true, baseDn : name} ];
		$.fn.zTree.init($("#treeArea"), setting, zNodes);
		$("#treeArea > li > span").click();
		var treeObj = $.fn.zTree.getZTreeObj("treeArea");
		treeObj.checkAllNodes(false);
	}

	function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus,
			errorThrown) {
		top.handlePrompt("error",
				'<spring:message  code="clusterManage.date.exception"/>');
	}


	function getChecked() {
		var selectCheckbox = "";
		var displayCheckbox ="";
		var treeObj = $.fn.zTree.getZTreeObj("treeArea");
		if (treeObj != null) {
			var nodes = treeObj.getCheckedNodes(true);
			var arrayString = "";
			for ( var i = 0; i < nodes.length; i++) 
			{
				if (nodes[i].check_Child_State != 1) 
				{
					if (nodes[i].check_Child_State == 2) 
					{
						arrayString += nodes[i].tId + ",";
					}
					if (arrayString.indexOf(nodes[i].parentTId) == -1) 
					{
						   selectCheckbox += nodes[i].baseDn + ";";
					}else
						{
						   displayCheckbox += nodes[i].baseDn + ";";
						}
				}else
					{
					       displayCheckbox += nodes[i].baseDn + ";";
					}
			}
			$("#syncNode").val(selectCheckbox);
			$("#displayNode").val(displayCheckbox);
		}
	}
	

	function addDiyDom(treeId, treeNode) {
		var prevFlag = $("#prevBtn_"+treeNode.tId);
		if(!prevFlag.get(0))
		{
			var aObj = $("#" + treeNode.tId+"_switch");
			var addStr = "<span class='button prevPage' id='prevBtn_" + treeNode.tId
			+ "' title='<spring:message code="common.prev.page"/>' onfocus='this.blur();'></span><span class='button nextPage' id='nextBtn_" + treeNode.tId
			+ "' title='<spring:message code="common.next.page"/>' onfocus='this.blur();'></span>";
			aObj.after(addStr);
			var prev = $("#prevBtn_"+treeNode.tId);
			var next = $("#nextBtn_"+treeNode.tId);
			
			prev.bind("click", function(){
				if (!treeNode.isAjaxing) {
					goPage(treeNode, treeNode.page-1);
				}
			});
			next.bind("click", function(){
				if (!treeNode.isAjaxing) {
					goPage(treeNode, treeNode.page+1);
				}
			});
		}
	};
	
	function onAsyncSuccess(event, treeId, treeNode, msg) {
		var childrenNode = treeNode.children;
		if(childrenNode)
		{
		  var pageCount = $("#pageCount").val();
		  var nodesLength = treeNode.children.length;
		  if(pageCount >0 && nodesLength >= pageCount)
		  {
				addDiyDom(treeId, treeNode);
		  }
       }
	}
	
	function goPage(treeNode, page) {
		if (page < 0)
		{
			return;
		}
		
		var childrenNode = treeNode.children;
		if(childrenNode)
		{
		  var nodesLength = treeNode.children.length;
		  if(nodesLength != 0 || (page+1) == treeNode.page)
		  { 
			  treeNode.page = page;
		      var zTree = $.fn.zTree.getZTreeObj("treeArea");
		      zTree.reAsyncChildNodes(treeNode, "refresh");
		  }
       }	
	}
	
	function showHelpMessage(findhtml,tableWidth,tableHeight){
		var url = '${ctx}/static/help/'+findhtml;
		if('<spring:message code="main.language"/>' == 'en'){
			url = '${ctx}/static/help/en/'+findhtml;
		}
		top.ymPrompt.win({
			message:url,
			width:tableWidth,height:tableHeight,
			title:'<spring:message code="common.config.example"/>', iframe:true,
			btn: [['<spring:message code="common.close"/>', "close", false]],
			handler : function(tp) {
				top.ymPrompt.close();
			}
		});
		top.ymPrompt_addModalFocus("#close");
		}
	
	function showMoive(){
	    var url = '${ctx}/static/help/openSSL.html';
	    if('<spring:message code="main.language"/>' == 'en'){
	        url = '${ctx}/static/help/en/openSSL.html';
	    }
	    top.ymPrompt.win({
	        message:url,
	        width:430,height:440,
	        title:'<spring:message code="common.guide"/>', iframe:true,
	        btn: [['<spring:message code="button.replay"/>', "replay", false,"focusBtn"],['<spring:message code="button.summary"/>', "summary", false]],
	        handler : function(tp) {
	            if(tp == "replay"){
	                top.ymPrompt.getPage().contentWindow.replay();
	            }else if(tp == "summary"){
	                top.ymPrompt.getPage().contentWindow.summary();
	            }
	        }
	    });
	    top.ymPrompt_addModalFocus("#focusBtn");
	    }
	
	var preProtocol = "close";
	function closeProtocol(){
	    top.ymPrompt.confirmInfo( {
	        title:'<spring:message code="common.warning"/>',
	        message :'<spring:message code ="adServer.warning.message"/>',
	        width:450,
	        closeTxt:'<spring:message code="common.close"/>',
	        handler : function(tp) {
	            if(tp == "ok"){
	                $("#securityProtocol").val("close");
	                if($("#ldapPort").val() == 636){
	                    $("#ldapPort").val(389);
	                }
	            }else{
	                 if("ssl" == preProtocol)
	                 {
	                    $("#protocolSSL").get(0).checked = true; 
	                 }
	                 else
	                 {
	                    $("#protocolTLS").get(0).checked = true; 
	                 }
	                 if($("#ldapPort").val() == 389)
	                 {
                        $("#ldapPort").val(636);
                     }
	            }
	        },
	        btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	    });        
	}

	function openProtocolSSL()
	{
	    preProtocol = "ssl";
	    $("#securityProtocol").val("ssl");
	    if($("#ldapPort").val() == 389){
	        $("#ldapPort").val(636);
	    }
	}
	
	function openProtocolTLS()
	{
	    preProtocol = "tls";
	    $("#securityProtocol").val("tls");
	    if($("#ldapPort").val() == 389){
	        $("#ldapPort").val(636);
	    }
	}
	
</script>
</body>
</html>

