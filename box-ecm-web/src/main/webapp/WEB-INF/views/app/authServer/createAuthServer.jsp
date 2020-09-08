<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%
request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content pop-content-en">
	<div class="form-con">
   	<form class="form-horizontal" id="creatAuthServerForm" name="creatAuthServerForm">
        <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
			<button class="close" data-dismiss="alert">×</button><spring:message code="createAuthServer.add.authserver.failed"/>
		</div>
		
		 <div class="control-group" >
            <label class="control-label" for="input"><em>*</em><spring:message  code="clusterManage.authenticationTpye"  />:</label>
            <div class="controls">
                <select class="span4" id="type" name="type">
                    <option value="AdAuth"><spring:message  code="authorize.regionAD"  /></option>
                	<option value="LdapAuth"><spring:message  code="clusterManage.LdapAuth"  /></option>
				</select>
            </div>
        </div>
		
         <div class="control-group">
        	<label class="control-label" for=""><em>*</em><spring:message code="common.name"/>:</label>
            <div class="controls">
                <input type="text" class="span4" id="name" name="name" maxlength="127"/>
                <span class="validate-con bottom inline-span3"><div></div></span>
            </div>
        </div>
                 
        <div class="control-group">
        	<label class="control-label" for=""><spring:message code="user.manager.labelDecription"/></label>
            <div class="controls">
                <textarea class="span4" id="description" name="description" maxlength="255"></textarea>
                <span class="validate-con bottom inline-span4"><div></div></span>
            </div>
        </div>
        <input type="hidden" name="token" value="<c:out value='${token}'/>"/>
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function()
{
	$("#creatAuthServerForm").validate({
		rules: {
			name: { 
				   required:true,
				   maxlength:[64]
			   },
		   type: {
			   required:true,
			   maxlength:[64]
		   },
		   description: {
			   maxlength:[255]
		   }
		}
    });
	
});

function submitAuthServer() 
{
	if(!$("#creatAuthServerForm").valid()) {
        return;
    }
	var url="${ctx}/enterprise/admin/authserver/create";
	$.ajax({
        type: "POST",
        url:url,
        data:$('#creatAuthServerForm').serialize(),
        error: function(request) {
        	var status = request.statusText;
        	if (status == "forbidden") {
        		handlePrompt("error",'<spring:message code="authServer.forbidden"/>');
        	} else {
        		handlePrompt("error",'<spring:message code="createAuthServer.add.authserver.failed"/>');
        	}
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="createAuthServer.add.authserver.success"/>');
        	refreshWindow();
        }
    });
}

function refreshWindow() {
	top.window.frames[0].location = "${ctx}/enterprise/admin/authserver/enterList";
}
</script>
</body>
</html>
