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
<div class="pop-content pop-content-en">
	<div class="form-con">
   	<form class="form-horizontal" id="setMaxMemberForm" >
        <br />
        <div class="control-group">
        	<label class="control-label" for=""><em>*</em><spring:message code="clientManage.teamMember"/>:</label>
            <div class="controls">
                <input type="text" id="maxMember" name="maxMember" maxlength="11" value="${cse:htmlEscape(maxMember)}"/>
                <span class="validate-con bottom"><div></div></span>
            </div>
        </div>
	</form>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function() {
	
	$("#maxMember").focus();
	
	$("#setMaxMemberForm").validate({ 
			rules: {
					maxMember: {
					   required:true, 
					   digits:true,
					   max:999999,
					   min:1
				   }
			}
	    });
    
});	
	function setMaxMember(appId, idArray,keyword) {
		$("#maxMember").val($.trim($("#maxMember").val()));
		if(!$("#setMaxMemberForm").valid()) {
	        return false;
	    }
	    
	    $("#maxMember").blur();
	
		top.ymPrompt_disableModalbtn("#btn-focus");
		
	    var params= {
			    "teamIds": idArray, 
			    "keyword" : keyword,
			    "maxMembers": $("#maxMember").val(),
			    token:'${token}'
		    };
	    
		$.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/admin/teamspace/config/setmaxmember/" + appId,
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
