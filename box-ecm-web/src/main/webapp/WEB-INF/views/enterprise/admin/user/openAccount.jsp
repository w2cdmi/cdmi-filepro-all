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
<%@ include file="../../../common/popCommon.jsp"%>
</head>
<body>
<div class="pop-content pop-content-en">
	<div class="clearfix">
		<div class="pull-left"><label class="control-label" for=""><spring:message code="employeeManage.open.account.message"/>:</label></div>
	</div>

    <div class="clearfix">
	        <form class="form-horizontal" id="openAccountForm" name="openAccountForm">
		        <table class="table table-bordered table-condensed">
		         <thead>
                <tr>
            	<th style="width:6%"><input type="checkbox" id="checkall" name="checkall" /></th>
                <th><spring:message code="appList.appId"/></th>
                <th><spring:message code="authorize.description"/></th>
                </tr>
                </thead>
			       <tbody>
		           <c:forEach items="${AccountAuthserverList}" var="accountAuthserver">
		           <tr>
		           <td><input type="checkbox" id="<c:out value='${accountAuthserver.authAppId}'/>" name="checkname" value="<c:out value='${accountAuthserver.authAppId}'/>"/></td>
		           <td title="${cse:htmlEscape(accountAuthserver.authAppId)}"><c:out value='${accountAuthserver.authAppId}'/></td>
                    <c:if test="${empty accountAuthserver.description}">
                      		  	<td>-</td>
                    </c:if>
                    <c:if test="${not empty accountAuthserver.description}">
                        <td title="${cse:htmlEscape(accountAuthserver.description)}"><c:out value='${accountAuthserver.description}'/></td>
                    </c:if>		           
		            </tr>
		            </c:forEach>
		        </table>
	        </form>
    </div>
</div>

</body>
<script type="text/javascript">

function submitOpenAccount(userIds, authServerId, filter, dn){
	var appIds = '';
	$("input[name='checkname']:checked").each(function () {
        if (appIds != '') {
        	appIds = appIds + "," + this.value;
        } else {
        	appIds = this.value;
        }
    });
	if (appIds == '') {
		handlePrompt("error",'<spring:message code="appList.appSelect"/>');
		return;
	}
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/admin/user/createUserAccount",
        data:{ids:userIds,appIds:appIds,authServerId:authServerId,filter:filter,dn:dn,"token" : "${token}"},
        error: function(request) {
        	doErr(request);
        },
        success: function() {        	
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="enterpriseAdmin.employee.open.account.success"/>');
        	refreshWindow(authServerId);
        }
    });
}

function doErr(request)
{
	if(409 == request.status)
	{
		handlePrompt("error",'<spring:message  code="admin.opent.exist"/>');
	}
	else
	{
		handlePrompt("error",'<spring:message code="enterpriseAdmin.employee.open.account.failed"/>');
	}
}

function refreshWindow(authServerId) {
/*
	top.window.frames[0].location = "${ctx}/enterprise/admin/user/employeeManage/"+authServerId;
*/
	top.window.frames[0].window.refreshWindow();
}

$("#checkall").click(function(){ 
	if(this.checked){ 
		$("input[name='checkname']:checkbox").each(function(){
			this.checked=true;
		});
	}else{ 
		$("input[name='checkname']:checkbox").each(function(){
			 this.checked=false;
		});
	}
});

</script>
</html>
