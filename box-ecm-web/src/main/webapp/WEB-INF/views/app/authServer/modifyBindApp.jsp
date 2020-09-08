<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="modifyBindAppForm" name="modifyBindAppForm">
   	        <input type="hidden" id="authServerId" name="authServerId" value="<c:out value='${accountAuthserver.authServerId}'/>"  class="span4" />
   	        <input type="hidden" id="accountId" name="accountId" value="<c:out value='${accountAuthserver.accountId}'/>"  class="span4" />
   	        <input type="hidden" id="authAppId" name="authAppId" value="<c:out value='${accountAuthserver.authAppId}'/>"  class="span4" />
	        <div class="control-group">
	        	<label class="control-label" for=""><spring:message code="common.name"/>:</label>
	            <div class="controls">
	            	<span class="uneditable-input span4"><c:out value='${authServer.name}'/></span>
	            </div>
	        </div>
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code="authorize.createAccountStyle"/>:</label>
	            <div class="controls">
	                <select id="type${accountAuthserver.type}" name="type">
        		   			<option value="2" <c:if test="${accountAuthserver.type == 2}">selected="selected"</c:if>><spring:message code="bindApp.openaccount.open"/></option>
        		   			<option value="1" <c:if test="${accountAuthserver.type == 1}">selected="selected"</c:if>><spring:message code="authorize.rounceCreateAccount"/></option>
               			 </select>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" name="token" value="<c:out value='${token}'/>"/>
	</form>
    </div>
</div>
<script type="text/javascript">

function submitModiFyBindApp(){
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/admin/authserver/modifyBindApp",
        data:$('#modifyBindAppForm').serialize(),
        error: function(request) {
        	handlePrompt("error",'<spring:message code="selectAdmin.bindFailed"/>');
        },
        success: function() {        	
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
        	top.window.frames[0].location = "${ctx}/enterprise/admin/authserver/bindAppList/" + "<c:out value='${accountAuthserver.authServerId}'/>";
        }
    });
}

</script>
</body>
</html>
