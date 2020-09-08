<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/common.jsp"%>
</head>
<body>
<div class="header">
    <div class="header-con">
        <div class="logo pull-left"><a href="#"  id="logoBackgroudId"><spring:message code="main.title" /></a></div>
           <div class="header-R pull-right clearfix">
        	<ul class="clearfix pull-right">
            	
            </ul>
        </div>
    </div>
</div>
<div class="body">
	<div class="sys-content body-con clearfix">
       <div class="form-horizontal form-con clearfix">
	        <div class="control-group">
	            <div class="controls">
	            <label><spring:message code="anon.forgetPwdMsg" /></label>
	            </div>
	        </div>
		</div>
	</div>
</div>

<div class="footer">
	<div class="footer-con">
    	<p><span class="logo-small" id="copyRightId"><spring:message code="corpright" /></span></p>
    </div>
</div>
</body>
<script type="text/javascript">
$(document).ready(function(){
});
</script>
</html>
