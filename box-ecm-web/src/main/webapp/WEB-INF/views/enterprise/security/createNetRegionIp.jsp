<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="creatEnterpriseForm" name="creatEnterpriseForm">
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='network.region.start.ip'/>:</label>
	            <div class="controls">
	                <input type="text" id="ipStart" name="ipStart" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	         <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='network.region.end.ip'/>:</label>
	            <div class="controls">
	                <input type="text" id="ipEnd" name="ipEnd" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="netRegionId" name="netRegionId" value="<c:out value='${id}'/>" class="span4" />
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	</form>
    </div>
</div>
<script type="text/javascript">  

$(document).ready(function() {
		$("#creatEnterpriseForm").validate({ 
			rules: { 
				   ipStart:{
					   required:true, 
					   maxlength:[255]
				   },
				   ipEnd: { 
					   required:true,
					   maxlength:[255]
				   }
			}
	    });
});

function submitCreate() {
	if(!$("#creatEnterpriseForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createNetRegionIp/<c:out value='${appId}'/>/",
        data:$('#creatEnterpriseForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="space.tip.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}	
        },
        success: function(data) {
        	    top.ymPrompt.close();
        	    top.handlePrompt("success",'<spring:message code="common.createSuccess"/>');
        	    window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
        }
    });
}

</script>
</body>
</html>
