<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="common/common.jsp"%>
</head>
<body>
	<%@ include file="common/header.jsp"%>
	<div class="body">
		<!--侧栏导航-->
	   <div id="navMenu" class="side side-whole">
			<div class="side-item" onClick="openInframe(this, '${ctx}/enterprise/admin/enterpriseInfo','systemFrame')">
				<div class="item-icon icon icon-enterprise-info"></div>
				<div class="item-text"><spring:message code="enterpriseAdmin.header.info" /></div>
			</div>
			<%-- <iframe id="systemFrame" src="" scrolling="no" frameborder="0" style=" width: 100%; height: 95%;"></iframe>
		    <%@ include file="common/footer.jsp"%> --%>
			<div class="side-item" onClick="openInframe(this, '${ctx}/enterprise/admin/organize/enterList','systemFrame')">
				<div class="item-icon icon icon-user-manage"></div>
				<div class="item-text"><spring:message code="enterpriseAdmin.employee.manage" /></div>
			</div>
			<div class="side-item" onClick="openInframe(this, '${ctx}/enterprise/admin/teamspace/config','systemFrame')">
				<div class="item-icon icon icon-team-space"></div>
				<div class="item-text">团队空间</div>
			</div>
			<div class="side-item" onClick="openInframe(this, '${ctx}/enterprise/admin/sercurity','systemFrame')">
					<div class="item-icon icon icon-safe-control"></div>
					<div class="item-text">安全控制</div>
				</div>
			<div class="side-item" onClick="openInframe(this, '${ctx}/enterprise/admin/individual/config/versionInfo','systemFrame')">
				<div class="item-icon icon icon-copyright-info"></div>
				<div class="item-text">版权信息</div>
			</div>
			<div class="side-item side-item-active" onClick="openInframe(this, '${ctx}/enterprise/admin/listAppByAuthentication','systemFrame')">
				<div class="item-icon icon icon-base-config"></div>
				<div class="item-text" >基础配置</div>
			</div>
		<%-- 	<div class="side-item side-item-active" onClick="openInframe(this, '${ctx}/enterprise/admin/storageSetting','systemFrame')">
				<div class="item-icon icon icon-base-config"></div>
				<div class="item-text" >存储设置</div>
		</div> --%>
			<div class="side-toggle">
				<div class="toggle-icon icon icon-pack-up"></div>
			</div>
		</div> 
		<div class="" style="overflow: hidden; padding-left: 20px;height: 100%">
			<iframe id="systemFrame" src="" scrolling="no" frameborder="0" style=" width: 100%; height: 100%;"></iframe>
		    
		</div>
		 <%@ include file="common/footer.jsp"%>
       </div>
	
</body>
<script type="text/javascript">



$(function(){	
	$("#loginInfo").css({width:"400px",height:"200px",top: "74%",left: "90%"});
	var flag = ${tag}; 
	var ip = "<%=org.springframework.web.util.HtmlUtils.htmlEscape(admin.getLastLoginIP()) %>";
	var time = "<%=admin.getLastLoginTime() %>";	
	if(flag) {	
		if(ip != "null" && ip != null && time != "null" && time != null) {
			time = <%=admin.getLastLoginTime() instanceof java.util.Date ? admin.getLastLoginTime().getTime() : null %>;
			$("#showTimeZone").text(getLocalTime(time));
			$("#loginInfo").show();
			setTimeout(function(){
	        		$("#loginInfo").hide();    
	        		<%
	        			sesion.setAttribute("tag", false);
	        		%>  
	        	},5000);
		}		
	} 
  
	if('<spring:message code="main.language"/>' == "en"){
		$("#langEN").remove();
	}else{
		$("#langZH").remove();
	}
	siteitemInit();
})


function siteitemInit(){
	$(".side-item").each(function(e,v){
		$(v).bind("click",function(t,h){
			$(".side-item").each(function(k1,v1){
				$(v1).removeClass("side-item-active");
			});
			$(this).addClass("side-item-active");
		})
		
	 });
}



function closeInfo() {
	$("#loginInfo").hide();
}

function disableBack(){
	window.history.forward();
} 
disableBack(); 
window.onload=disableBack; 
window.onpageshow=function(evt){
	if(evt.persisted){
		disableBack();
	}
} 
window.onunload=function(){
	void(0);
}
function doLogout(){
	$.ajax({
        type: "POST",
        url:"${ctx}/logout",
        data : {token : "<c:out value='${token}'/>"},
        error: function(request) {
        	window.location = "${ctx}/login";
        },
        success: function(data) {
        	window.location = "${ctx}/login";
        }
    });
}
function enterModifyEmail(){
	top.ymPrompt.win({message:'${ctx}/account/enteremail',width:600,height:235,title:'<spring:message code="header.updateMail"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnModifyEmail"],['<spring:message code="common.cancel"/>','no',true,"btnModifyCancel"]],handler:doSubmitModifyEmail});
	top.ymPrompt_addModalFocus("#btnModifyEmail");
}
function doSubmitModifyEmail(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModify();
	} else {
		top.ymPrompt.close();
	}
}
function enterModifyAccountPage(){
	top.ymPrompt.win({message:'${ctx}/sys/authorize/user',width:700,height:220,title:'<spring:message code="header.updateUserName"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnModifyAccount"],['<spring:message code="common.cancel"/>','no',true,"btnModifyCancel"]],handler:doSubmitModifyAccount});
	top.ymPrompt_addModalFocus("#btnModifyAccount");
}
function doSubmitModifyAccount(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModify();
	} else {
		top.ymPrompt.close();
	}
}
var defaltAppId="";
$(document).ready(function() {
		var params = {"token" : "${token}"};
		$.ajax({
				type : "POST",
				url : '${ctx}/enterprise/admin/basicconfig/defaultAppId',
				data : params,
				error : function(request) {
					handlePrompt("error",
							'<spring:message code="common.operationFailed" />');
				},
				success : function(data) {
					defaltAppId=data;
					$("#navMenu").find("div")[0].click()
				}
		})

});


function iframCallback(childDocument) {
   console.log(childDocument);

};


</script>
</html>

