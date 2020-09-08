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
<%
%>
</head>
<body>
<div class="sys-content">
	<div class="clearfix control-group">
		<a  class="return btn btn-small pull-right" href="${ctx}/enterprise/admin/authserver/enterList">
		<i class="icon-backward"></i>&nbsp;<spring:message  code="common.back"  /></a>
		<h5 class="pull-left" style="margin: 3px 0 0 4px;"><a href="${ctx}/enterprise/admin/authserver/enterList">
		<c:if test="${authType != 'LocalAuth'}"><c:out value='${name}'/></c:if>
		<c:if test="${authType == 'LocalAuth'}"><spring:message  code="authserver.type.local"  /></c:if>
		</a>&nbsp;>&nbsp;<spring:message code="enterpriseList.catch.app"/></h5>
	</div>
	<div class="clearfix table-con">
		<button type="button" class="btn btn-primary" onclick="createBindApp('<c:out value="${authServerId}"/>')"><i class="icon-plus"></i><spring:message code="enterpriseList.catch.addapp"/></button>
	</div>
    <div class="table-con">
        <table class="table table-bordered table-condensed">
        	<thead>
        		<tr>
        			<th><spring:message code="header.app"/></th>
        			<th><spring:message code="authorize.createAccountStyle"/></th>
        			<th><spring:message code="common.operation"/></th>
        		</tr>
        	</thead>
	       <tbody>
           <c:forEach items="${accountAuthServers}" var="authApp">
           <tr>
               <td><c:out value="${authApp.authAppId}"/></td>
               <td>
               		<c:if test="${authApp.type == 2}"><spring:message code="bindApp.openaccount.open"/></c:if>
               		<c:if test="${authApp.type == 1}"><spring:message code="authorize.rounceCreateAccount"/></c:if>
               </td>
               <td>
               		
               		<c:if test="${networkAuthStatus == 1}">
                 	<button type="button" class="btn" onclick="createAuthServerNetwork('<c:out value="${authApp.accountId}"/>','<c:out value="${authServerId}"/>')" id="createNetwork"><spring:message code="authserver.network.config"/></button>
                 	</c:if>
                 	<button type="button" class="btn" onclick="doUnBindApp('<c:out value="${authApp.accountId}"/>','<c:out value="${authServerId}"/>')" id="doUnBindAppBtn"><spring:message code="teamSpace.label.delete"/></button>
                 	<c:if test="${authType != 'LocalAuth'}">
                 	<button type="button" class="btn" onclick="modifyBindAppBtn('<c:out value="${authApp.accountId}"/>','<c:out value="${authServerId}"/>')" id="modifyBindAppBtn"><spring:message code="common.update"/></button>
                 	</c:if>
                </td>
            </tr>
            </c:forEach>
            <input type="hidden" name="token" value="<c:out value='${token}'/>"/>
        </table>
	        
    </div>
</div>

</body>
<script type="text/javascript">

function createBindApp(authServerId){
	top.ymPrompt.win({
		message:'${ctx}/enterprise/admin/authserver/bindApp/' + authServerId,
		width:700,
		height:430,
		title:'<spring:message  code="enterpriseList.catch.app"/>', 
		iframe:true,
		btn:[
		     ['<spring:message  code="selectAdmin.bind"/>','yes',false,"btn-focus"],
		     ['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],
		     handler:doBindApp});
	top.ymPrompt_addModalFocus("#btn-focus");
}
function doBindApp(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitBindApp();
	} else {
		top.ymPrompt.close();
	}
}
function modifyBindAppBtn(accountId,authServerId){
	top.ymPrompt.win({
		message:'${ctx}/enterprise/admin/authserver/entermodifyBindApp/'+accountId+'/'+authServerId,
		width:700,
		height:430,
		title:'<spring:message code="common.update"/>', 
		iframe:true,
		btn:[
		     ['<spring:message code="common.update"/>','yes',false,"btn-focus"],
		     ['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],
		     handler:domodifyBindAppBtn});
	top.ymPrompt_addModalFocus("#btn-focus");
}
function domodifyBindAppBtn(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModiFyBindApp();
	} else {
		top.ymPrompt.close();
	}
}
function doUnBindApp(accountId,authServerId)
{
	top.ymPrompt.confirmInfo({
		title : '<spring:message code="authserver.bind.delete"/>',
		message : '<spring:message code="authserver.bind.delete"/>'
				+ '<br/>'
				+ '<spring:message code="authserver.bind.deleteDesc"/>',
		width : 450,
		closeTxt : '<spring:message code="common.close"/>',
		handler : function(tp) {
			if (tp == "ok") {
				deleteBindedApp(accountId,authServerId);
			}
		},
		btn : [
				[ '<spring:message code="common.OK"/>', "ok" ],
				[ '<spring:message code="common.cancel"/>',
						"cancel" ] ]
	});
}
function deleteBindedApp(accountId,authServerId) {
	$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/admin/authserver/unbindApp",
				data:{accountId:accountId,authServerId:authServerId,token:'<c:out value="${token}"/>'},
				error : function(request) {
					top.handlePrompt("error",
									'<spring:message code="user.manager.deleteFailed"/>');
				},
				success : function() {
					top.handlePrompt("success",
									'<spring:message code="user.manager.deteteSuccessed"/>');
					refreshWindow();
				}
			});
}

function createAuthServerNetwork(accountId,authServerId)
{
	window.location = '${ctx}/enterprise/admin/accountauthservernetwork/enterList/'+accountId+"/"+authServerId;
}

function refreshWindow() {
	window.location.reload();
}

</script>
</html>
