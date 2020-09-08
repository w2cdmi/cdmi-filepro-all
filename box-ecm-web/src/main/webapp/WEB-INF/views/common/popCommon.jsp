<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link href="${ctx}/static/skins/default/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/ymPrompt/ymPrompt.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/public.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/pop.css" rel="stylesheet" type="text/css" />
<%--
<link href="${ctx}/static/skins/default/css/base.css" type="text/css" rel="stylesheet">
--%>
<link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/main.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css"/>

<script src="${ctx}/static/js/public/jquery-1.10.2.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/validate/jquery.validate.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/bootstrap.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/ymPrompt.source.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/common.js" type="text/javascript"></script> 
<script src="${ctx}/static/js/public/JQbox-hw-grid.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
<script src="${ctx}/static/zTree/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>

<%--
<script src="${ctx}/static/js/public/common_stor.js"></script>
--%>

<%@ include file="./messages.jsp"%>
<%
    response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires",0);
    request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>