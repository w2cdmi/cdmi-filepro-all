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
</head>
<body>
<div class="sys-content sys-content-en">
    <div class="clearfix control-group" >
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
        <li class="active"><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
    	<li><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
    </ul>
    <div class="alert"><i class="icon-lightbulb"></i><spring:message code="manage.title.email.hit"/></div>
    
    <div class="form-con">
    <h5><spring:message  code="account.attributes.email.receive"/></h5>
    <form id="accountEmailReceive" name="accountEmailReceive" class="form-horizontal">
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.server"/>:</label>
            <div class="controls">
                <input class="span4" type="text" id="serverReceive" name="serverReceive" value="<c:out value='${serverReceive.value}'/>" />
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.protocol"/>:</label>
            <div class="controls">
                    <select class="span4" id="protocolReceive"  name="protocolReceive">
                            <option value="imap" <c:if test="${protocolReceive.value == 'imap'}">selected="selected"</c:if>>imap</option>
                            <option value="pop3" <c:if test="${protocolReceive.value == 'pop3'}">selected="selected"</c:if>>pop3</option>
                    </select>
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.port"/>:</label>
            <div class="controls">
                <input class="span4" type="text" id="portReceive" name="portReceive" value="<c:out value='${portReceive.value}'/>" />
                <span class="validate-con"><div></div></span>
            </div>
        </div>
          <div class="control-group">
            <div class="controls">
                <button type="button" class="btn btn-primary" onclick="saveAccountEmail(true)"><spring:message code="common.save"/></button>
            </div>
        </div>
    </form>
    </div>
    
    <div class="form-con">
    <form id="accountEmailSend" name="accountEmailSend" class="form-horizontal">
        <h5><spring:message  code="account.attributes.email.send"/></h5>
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.server"/>:</label>
            <div class="controls">
                <input class="span4" type="text" id="serverSend" name="serverSend" value="<c:out value='${serverSend.value}'/>" />
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.protocol"/>:</label>
            <div class="controls">
                <input readonly="readonly"  class="span4" type="text" id="protocolSend" name="protocolSend" value="smtp" />
                <span class="validate-con"><div></div></span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label" for="input"><em>*</em><spring:message code="account.attributes.email.port"/>:</label>
            <div class="controls">
                <input class="span4" type="text" id="portSend" name="portSend" value="<c:out value='${portSend.value}'/>" />
                <span class="validate-con"><div></div></span>
            </div>
        </div>
          <div class="control-group">
            <div class="controls">
                 <button type="button" class="btn btn-primary" onclick="saveAccountEmail(false)"><spring:message code="common.save"/></button>
            </div>
        </div>
    </form>
    </div>
    
    </div>
</body>

<script type="text/javascript">

$(document).ready(function() {
        $("#accountEmailReceive").validate({
            rules: { 
                serverReceive:{
                       required:true, 
                       maxlength:[127],
                       serverCheck : true
                   },
                   portReceive: {
                       required:true, 
                       digits:true,
                       min:1,
                       max:65535
                   }
            },
            messages : {
                serverReceive : {
                    serverCheck : '<spring:message  code="account.attributes.email.server.rule"/>'
                }
            },
        }); 
        $("#accountEmailSend").validate({
            rules: { 
                serverSend:{
                       required:true, 
                       maxlength:[127],
                       serverCheck : true
                   },
                   portSend: {
                       required:true, 
                       digits:true,
                       min:1,
                       max:65535
                   }
            },
            messages : {
                serverSend : {
                    serverCheck : '<spring:message  code="account.attributes.email.server.rule"/>'
                }
            },
        }); 
        $.validator.addMethod(
                "serverCheck", 
                function(value, element) {  
                    var pattern = /^[a-zA-Z0-9-_.]*$/;
                    if(!pattern.test(value)){
                       return false;
                    }
                    return true;
                }
        ); 
        
        var pageH = $("body").outerHeight();
        top.iframeAdaptHeight(pageH);
        $("button").tooltip({ container:"body", placement:"top", delay: { show: 100, hide: 0 }, animation: false });
});

function saveAccountEmail(isReceive) 
{
    var emailConfig = "";
    if(isReceive)
    {
        if(!$("#accountEmailReceive").valid()) 
        {
            return false;
        }
        emailConfig = $("#serverReceive").val() + ";" +  $("#protocolReceive").val() + ";" +  $("#portReceive").val();
    }
    else
    {
        if(!$("#accountEmailSend").valid()) 
        {
            return false;
        }
        emailConfig = $("#serverSend").val() + ";" +  $("#protocolSend").val() + ";" +  $("#portSend").val();
    }
   
    $.ajax({
        type: "POST",
        async:false,
        url:"${ctx}/enterprise/admin/accountEmail",
        data:{emailConfig:emailConfig, appId:"<c:out value='${appId}'/>", isReceive:isReceive, token:'${token}'},
        error: function(request) {
            errorMessage(request);
        },
        success: function() {
            top.handlePrompt("success",'<spring:message code="common.saveSuccess"/>');
            window.location.reload();
        }
    });
}

function errorMessage(request)
{
    switch(request.status)
    {
     case 400:
         handlePrompt("error",'<spring:message code="error.invalidRequest"/>');
         break;
      default:
         top.handlePrompt("error",'<spring:message code="common.saveFail"/>');
         break;
    }
}

</script>
</html>
