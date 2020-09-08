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
<div class="pop-content pop-content-en">
	<div class="form-con">
   	<form class="form-horizontal" id="creatUserForm" name="creatUserForm">
        <div class="control-group">
        	<label class="control-label" for=""><spring:message code="common.role"/>:</label>
            <div class="controls">
               <select  class="span3" id="roleId" name="roleId">
               <option value="0"><spring:message code="employeeManage.select.role"/></option>
	                  <c:forEach items="${SecurityRoles}" var="role">
	           	  		<option value="<c:out value='${role.id}'/>">
	            			 <c:out value='${role.roleName}'/>
	             		</option>
	                  </c:forEach>
				</select>
            </div>
        </div>
	</form>
    </div>
</div>
<script type="text/javascript">
function submitSetter(ids, appId, authServerId,userStatus, filter, dn) 
{	
	var roleId = $("#roleId").find("option:selected").val();
	var url="${ctx}/enterprise/admin/accountuser/setRole";
	
	var params = {
			"filter" : filter,
			"dn" : dn,
			"selStatus" : userStatus,
			"authServerId" : authServerId,
			"status" : status,
			"appId" : appId,
			"roleId":roleId,
			"userIds":ids,
			"token" : "${token}"
		};
	$.ajax({
        type: "POST",
        url:url,
        data:params,
        error: function(request) {
        	handlePrompt("error",'<spring:message code="employeeManage.setter.fail"/>');
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="anon.setPwdSuccess"/>');
        	refreshWindow(appId, authServerId);
        }
    });
}

function refreshWindow(appId,authServerId) {
	top.window.frames[0].location = "${ctx}/enterprise/admin/accountuser/list/"+appId+"/"+authServerId;
}
</script>
</body>
</html>
