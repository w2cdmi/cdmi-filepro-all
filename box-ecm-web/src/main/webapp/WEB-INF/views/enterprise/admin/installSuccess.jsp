<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="../../include/head.jsp"></jsp:include>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/style/login.css "/>
</head>
<body style="overflow: auto;position: absolute;height: 100%;width: 100%">
<jsp:include page="../../include/menu.jsp"></jsp:include>
<div id="layer-1" style="margin-top: 60px;height: 670px;">
    <div style="background: url(./assets/images/bg1_02.png);background-size:cover ;position: absolute;left: 0;top:60px;right: 0px;height: 340px">
        <div style="width: 1280px;margin: 0 auto">
            <div class="box messagebox-success">
                <div class="header"><h3>恭喜你，安装成功</h3></div>
                <i class="success"></i>
                <p>企业微信里面可以立即使用。移动端（Andorid,IOS,小程序)绑定登录账号的密码已发送到您的企业微信，登录绑定即可使用</p>
                <button id="home_button" style="cursor: pointer">返回首页</button>
            </div>
        </div>
    </div>

</div>
<div id="ad-3">
    <div>
        <p class="title">企业文件宝，做我能做的，给你我有的。</p>
        <span class="line"></span>
        <p></p>
        <a class="btn" href="/register/wxwork">立即体验</a>
    </div>
    <!-- <img src="./assets/images/index_10.png" /> -->
</div>
<jsp:include page="../../include/buttom.jsp"></jsp:include>
<script>
    $(document).ready(function() {
        $("#home_button").click(function(){
            window.open("https://www.filepro.cn", "_self");
        });
    });
</script>
</body>
<%--



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
    <script src="${ctx}/static/js/public/uaredirect.js" type="text/javascript"></script>
    <script src="${ctx}/static/js/public/JQbox-hw-switch.js" type="text/javascript"></script>
    <%
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.setHeader("Access-Control-Allow-Origin", "*");
    %>

    <script type="text/javascript">

    </script>
    <style type="text/css">
    		*{
				margin: 0;
				padding: 0;
			}
			html,body{
				font-family: "思源黑体";
			}
			a{
				text-decoration: none;
				color: #000;
			}
			a:hover{
				text-decoration: none;
				color: #fff;
			}
			.inst-success-head{
				min-width: 1100px;
				background-color: #191919;
				height: 60px;
				overflow: hidden;
			}
			.pub-width{
				width: 1100px;
				margin: auto;
			}
			.inst-logo a{
				font-size: 18px;
				color: #fff;
				display: inline-block;
				line-height: 60px;
			}
			.inst-logo a img{
				display: inline-block;
				vertical-align: middle;
				margin-right: 16px;
			}
			.inst-content{
				min-width: 1100px;
				min-height: 1016px;
				background-color: #ECF1F5;
				overflow: hidden;
			}
			.install-succ-con{
				width: 400px;
				height: 520px;
				margin: 135px auto 330px;
				background-color: #fff;
				text-align: center;
				overflow: hidden;
			}
			.installs-img{
				width: 100px;
				height: 100px;
				margin: 82px auto 113px;
			}
			.installs-img{
				width: 100px;
			}
			.install-info p:first-of-type{
				font-size: 18px;
				color: #333;
				line-height: 38px;
				font-weight: bold;
			}
			.install-info p:last-of-type{
				font-size: 14px;
				color: #666;
				line-height: 34px;
			}
			.buswx-bottom{
				text-align: center;
			}
			.buswx-bottom p{
				font-size: 14px;
				color: #333;
			}
    </style>
</head>
<body>
		<div class="inst-success-head">
					<div class="inst-logo pub-width">
						<a href="#">
							<img src="${ctx}/static/skins/default/img/logo.png" alt="" />
                            &lt;%&ndash;<spring:message code="main.title"/>&ndash;%&gt;
						</a>
					</div>
				</div>
				<div class="inst-content">
					<div class="install-succ-con">
						<div class="installs-img">
							<img src="${ctx}/static/skins/default/img/installSuccess_03.png" alt="" />
						</div>
						<div class="install-info">
							<p>安装成功</p>
							<p>恭喜您成功安装<spring:message code="main.product"/>，快去企业微信体验吧!</p>
						</div>
					</div>
					<div class="pub-width buswx-bottom">
						<p><spring:message code="corpright"/></p>
					</div>
				</div>
		</div>
</body>--%>
</html>