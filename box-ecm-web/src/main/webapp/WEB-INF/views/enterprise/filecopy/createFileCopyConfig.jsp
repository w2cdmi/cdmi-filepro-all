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
   	<form class="form-horizontal" id="creatForm" name="creatForm">
   	 	<div class="control-group ">
                <span><spring:message code="fileCopy.message.tip"/></span>
       	</div>
       	<div class="control-group">
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="fileCopy.title.owner"/></p><br/>
                    <div class="control-new-label">
		        		<select class="span3" id="srcSafeRoleId" name="srcSafeRoleId" size="9">
		               	 	<option value="-1" selected><spring:message code="security.role.any"/></option>
	        				<c:forEach items="${safeRoleList}" var="oper">
	        					<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
	        				</c:forEach>
						</select>
                    </div>
                </div>
                <div class="pull-left icon-add"><i class="icon-arrow-right"></i></div>
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="fileCopy.title.spaceowner"/></p><br/>
                    <div class="control-new-label">
	       				<select class="span3" id="targetSafeRoleId" name="targetSafeRoleId" size="9">
	                		<option value="-1" selected><spring:message code="security.role.any"/></option>
	        				<c:forEach items="${targetSafeList}" var="oper">
	        					<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
	        				</c:forEach>
						</select>
                    </div>
                </div>
            </div> 
	        <input type="hidden" id="token" name="token" value="${token}"/>
	</form>
    </div>
</div>
<script type="text/javascript">  
$(document).ready(function() {
		
});

$(function(){
    $(".span3  option:first-child").addClass("active");
    $(".span3  option").click(function(){
        $(this).addClass("active").siblings().removeClass("active");
    })
})

function submitCreate() {
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/fileCopy/<c:out value='${appId}'/>",
        data:$('#creatForm').serialize(),
        error: function(data) {
        	if(data.status==409){
        		handlePrompt("error",'<spring:message code="fileCopy.tip.conflict"/>');
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
