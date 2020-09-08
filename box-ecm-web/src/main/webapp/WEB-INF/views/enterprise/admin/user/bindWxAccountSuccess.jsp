<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=10"/>
    <meta http-equiv="X-UA-Compatible" content="IE=9"/>
    <meta http-equiv="X-UA-Compatible" content="IE=8"/>
    <META HTTP-EQUIV="Expires" CONTENT="0">
    <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Cache-control" content="no-cache, no-store, must-revalidate">
    <META HTTP-EQUIV="Cache" CONTENT="no-cache">
    <title><spring:message code="main.title"/></title>
    <link rel="shortcut icon" type="image/x-icon" href="${ctx}/static/skins/default/img/temp/logo.ico">
    <link href="${ctx}/static/skins/default/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
    <link href="${ctx}/static/skins/default/css/public.css" rel="stylesheet" type="text/css"/>

    <script src="${ctx}/static/js/public/jquery-1.10.2.min.js" type="text/javascript"></script>
    <script src="${ctx}/static/js/public/bootstrap.min.js" type="text/javascript"></script>
    <script src="${ctx}/static/js/public/common.js" type="text/javascript"></script>
    <%
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.setHeader("Access-Control-Allow-Origin", "*");
    %>

    <script type="text/javascript">
			
    </script>
    <style type="text/css">
    	body {
		    background: #09122b;
		    overflow-x: hidden;
		    overflow-y: scroll;
		    position: relative;
		}
    	.bodys{
			overflow-y: hidden;
			background: #eaeaea;
		}
		.background{
		    width: 100%;
		    height: 673px;
		    position: absolute;
		}
		.background>img{
			position: relative;
			left: 10%;
			width: 80%;
			top: 120px;
		}
		.login-header{
			width: 100%;
			background: #333;
			position: absolute;
			height: 60px;
			top: 0;
		}
		.login-header-middle{
			position: absolute;
			top: 0;
			left: 50%;
			margin: 0 0 0 -500px;
			width: 1020px;
			height: 40px;
			padding-top: 13px;
			padding-bottom: 20px;
		}
		.login-header .login-header-icon{
			width: 184px;
			height: 38px;
		}
		.login-header .login-header-icon img{
			max-height: 40px;
			max-width: 200px !important;
			vertical-align: middle;
		}
		.login-header .login-header-icon span{
			font-size: 18px;
			color: #FFFFFF;
			line-height: 38px;
			
		}
		.content{
			width: 411px;
			height: 332px;
			position: absolute;
			top: 180px;
			left: 50%;
			-webkit-transform: translateX(-50%);
		}
		.content-header{
			width: 100%;
			height: 50px;
			line-height: 50px;
			text-align: center;
			font-size: 14px;
			margin-top: 20px;
		}
		.content-header>span{
			font-size: 18px;
			color: #fec016;
		}
		.content-success-icon{
			width: 100%;
			height: 100px;
			position: relative;
			margin-top: 31px;
			margin-bottom: 31px;
		}
		.content-success-icon>img{
			width: 100px;
			height: 100px;
			position: absolute;
			top: 0;
			left: 50%;
			-webkit-transform: translateX(-50%);
		}
		.content-tail{
			font-size: 50px;
			text-align: center;
			width: 100%;
			height: 100px;
			line-height: 100px;
		}
    </style>
</head>
<body class="bodys">
<div class="login-header">
	<div class="login-header-middle">
		<div class="login-header-icon">
			<img src="${ctx}/static/skins/default/img/logo.png"/>
		</div>
	</div>
</div>
<div class="content">
	<img style="box-shadow: 2px 2px 2px #E6E3E3;" src="${ctx}/static/skins/default/img/bind-wx-account-success.png"/>
</div>
</body>
</html>