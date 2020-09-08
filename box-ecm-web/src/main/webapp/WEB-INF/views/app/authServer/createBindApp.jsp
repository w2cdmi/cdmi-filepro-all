<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%> 

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@ include file="../../common/common.jsp"%> 
</head>
<body>
<div class="pop-content pop-content-en">
	<div class="clearfix">
		<div class="pull-left"><label class="control-label" for=""><spring:message code="bindApp.bind"/><b>
         <c:if test="${authType != 'LocalAuth'}"><c:out value='${name}'/></c:if>
		<c:if test="${authType == 'LocalAuth'}"><spring:message  code="authserver.type.local"  /></c:if>
        </b><spring:message code="bindApp.select.bind.app"/>:</label></div>
	</div>

    <div class="clearfix">
	        <form class="form-horizontal" id="bindAppForm" name="bindAppForm">
		        <table class="table table-bordered table-condensed">
			       <tbody>
		           <c:forEach items="${accountAuthServers}" var="authApp">
		           <tr>
		                <td><input type="checkbox" name="accountId" value="<c:out value='${authApp.accountId}'/>"
		                <c:if test="${authApp.isBind == true}">checked="checked"</c:if>/>
		                <c:out value='${authApp.authAppId}'/>
		                </td>
		                <c:if test="${authType == 'LocalAuth'}">
		                <input type="hidden" id="type<c:out value='${authApp.accountId}'/>" name="type<c:out value='${authApp.accountId}'/>" value="-1"/>
		                </c:if>
		               <c:if test="${authType != 'LocalAuth'}">
		               <td>
		                 <select id="type<c:out value='${authApp.accountId}'/>" name="type">
        		   			<option value="-1"><spring:message code="bindApp.select.openaccount.type"/></option>
        		   			<option value="2" <c:if test="${authApp.type == 2}">selected="selected"</c:if>><spring:message code="bindApp.openaccount.open"/></option>
        		   			<option value="1" <c:if test="${authApp.type == 1}">selected="selected"</c:if>><spring:message code="authorize.rounceCreateAccount"/></option>
               			 </select>
		                </td>
		                </c:if>
		            </tr>
		            </c:forEach>
		        </table>
	        </form>
	        
    </div>
</div>

</body>
<script type="text/javascript">
function submitBindApp(){
	var ids = '';
	$("input[name='accountId']:checked").each(function () {
        if (ids != '') {
        	ids = ids + ";" + this.value+","+$("#type"+this.value+"").val();
        } else {
        	ids = this.value+","+$("#type"+this.value+"").val();
        }
    });
	if (ids == '') {
		handlePrompt("error",'<spring:message code="appList.appSelect"/>');
		return;
	}
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/admin/authserver/bindApp",
        data:{accountIds:ids,authServerId:"<c:out value='${authServerId}'/>",token:'<c:out value='${token}'/>'},
        error: function(request) {
        	handlePrompt("error",'<spring:message code="selectAdmin.bindFailed"/>');
        },
        success: function() {        	
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
        	top.window.frames[0].location = "${ctx}/enterprise/admin/authserver/bindAppList/" + "<c:out value='${authServerId}'/>";
        }
    });
}
</script>
</html>
