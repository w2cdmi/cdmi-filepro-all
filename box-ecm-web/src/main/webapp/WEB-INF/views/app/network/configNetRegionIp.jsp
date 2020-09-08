<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="createForm" name="createForm">
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='app.network.region.table.startip'/>:</label>
	            <div class="controls">
	                <input type="text" id="ipStart" name="ipStart" class="span3" value="<c:out value='${regionConfig.ipStart }'/>"/>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='app.network.region.table.endip'/>:</label>
	            <div class="controls">
	                <input type="text" id="ipEnd" name="ipEnd" class="span3" value="<c:out value='${regionConfig.ipEnd }'/>"/>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='app.network.region.table.region'/>:</label>
	            <div class="controls">
	                <select class="span3"  name="regionId">
	                    <c:forEach items="${regionList}" var="region">
	        				<option value="<c:out value='${region.id}'/>" <c:if test="${regionConfig.regionId == region.id}">selected="selected"</c:if>><c:out value='${region.name}'/></option>
	        			</c:forEach>
	                </select>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="id" name="id" value="<c:out value='${regionConfig.id}'/>" class="span1" />
	        <input type="hidden" id="authAppId" name="authAppId" value="<c:out value='${appId}'/>" class="span1" />
	        <input type="hidden" name="token" value="<c:out value='${token}'/>"/>
	</form>
    </div>
</div>
<script type="text/javascript">  

$(document).ready(function() {
	$("#createForm").validate({ 
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

function submitForm() {
	if(!$("#createForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        url:"${ctx}/app/network/config/saveConfig",
        data:$('#createForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="space.tip.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="app.network.region.save.fail"/>');
        	}	
        },
        success: function(data) {
        	    top.ymPrompt.close();
        	    top.handlePrompt("success",'<spring:message code="app.network.region.save.success"/>');
        	    window.parent.document.getElementById('systemFrame').contentWindow.initDataList(<c:out value='${currentPage}'/>);
        }
    });
}

</script>
</body>
</html>
