<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>

<body>
<%@ include file="../../common/header.jsp"%>
<div class="body">
	<div class="body-con clearfix system-con">
    	<div class="breadcrumb">
        	<div class="breadcrumb-con">
        		<p id="breadcrumbText"></p>
        	</div>
        </div>
       	<iframe id="systemFrame" src="" scrolling="no" frameborder="0"></iframe>
    </div>
</div>
<%@ include file="../../common/footer.jsp"%>
</body>
</html>