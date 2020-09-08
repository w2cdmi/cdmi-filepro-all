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
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content pop-content-en">
	<div class="form-con">
   	<form class="form-horizontal" id="creatAuthServerForm" name="creatAuthServerForm">
		 <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='clusterManage.startIp'/></label>
	            <div class="controls">
	                <input type="text" id="ipStart" name="ipStart" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	         <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='clusterManage.endIp'/></label>
	            <div class="controls">
	                <input type="text" id="ipEnd" name="ipEnd" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="authServerId" name="authServerId" value="<c:out value='${authServerId}'/>" class="span4" />
	        <input type="hidden" id="accountId" name="accountId" value="<c:out value='${accountId}'/>" class="span4" />
	        <input type="hidden" id="token" name="token" value="<c:out value='${token}'/>"/>
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	$("#creatAuthServerForm").validate({ 
		rules: { 
			   ipStart:{
				   required:true, 
				   maxlength:[32]
			   },
			   ipEnd: { 
				   required:true,
				   maxlength:[32]
			   }
		}
    });
});

function submitCreate() 
{
	if(!$("#creatAuthServerForm").valid()) {
        return;
    }
	var url="${ctx}/enterprise/admin/accountauthservernetwork/create";
	$.ajax({
        type: "POST",
        url:url,
        data:$('#creatAuthServerForm').serialize(),
        error: function(request) {
        	var status = request.statusText;
        	if (status == "forbidden") {
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	} else {
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="common.createSuccess"/>');
        	top.ymPrompt.close();
        }
    });
}
function backList()
{
	window.location = '${ctx}/enterprise/admin/accountauthservernetwork/enterList/'+<c:out value="${accountId}"/>+'/'+<c:out value="${authServerId}"/>;
}
</script>
</body>
</html>
