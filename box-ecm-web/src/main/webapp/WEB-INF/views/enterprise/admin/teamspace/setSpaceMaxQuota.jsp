<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/validate/jquery.validate.min.js" type="text/javascript"></script>
<%@ include file="../../../common/messages.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="setSpaceQuotaForm" >
        <br />
        <div class="control-group">
        	<label class="control-label" for=""><em>*</em><spring:message code="clientManage.teamSpaces"/>:</label>
            <div class="controls">
                <input type="text" id="spaceQuota" name="spaceQuota" maxlength="11" value="${cse:htmlEscape(spaceQuota)}"/>&nbsp;GB
                <span class="validate-con bottom"><div></div></span>
            </div>
        </div>
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	
	$("#spaceQuota").focus();
	
    	$("#setSpaceQuotaForm").validate({ 
			rules: {
					spaceQuota: {
					   required:true, 
					   digits:true,
					   max:999999,
					   min:1
				   }
			}
	    });
 
});	
	function setSpaceQuota(appId, idArray,keyword) {
		$("#spaceQuota").val($.trim($("#spaceQuota").val()));
		if(!$("#setSpaceQuotaForm").valid()) {
	        return false;
	    }
	    
	    $("#spaceQuota").blur();
	
		top.ymPrompt_disableModalbtn("#btn-focus");
		
	    var params= {
			    "teamIds": idArray, 
			    "keyword" : keyword,
			    "spaceQuota": $("#spaceQuota").val(),
			    token:'${token}'
		    };
	    
		$.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/admin/teamspace/config/setspacequota/" + appId,
	        data:params,
	        error: function(request) {
            	top.ymPrompt.close();
	        	top.handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        },
	        success: function(data) {
            	top.ymPrompt.close();
	        	if(data !="")
	        	{
	        		top.handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        	}
	        	else
	        	{
	            	top.handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
	            	refreshWindow();
	        	}
	        }
	    });
	}
	
	function refreshWindow() {
		top.window.frames[0].refreshWindow();
	}
</script>
</body>
</html>
