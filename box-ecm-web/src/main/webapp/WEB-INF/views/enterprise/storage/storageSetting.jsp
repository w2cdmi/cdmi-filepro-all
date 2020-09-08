<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token",CSRFTokenManager.getTokenForSession(session));%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
<meta charset="UTF-8">
<title>Title</title>

<link href="${ctx}/static/enterprise/storage/storage_info.css" type="text/css" rel="stylesheet">
<script src="${ctx}/static/enterprise/storage/storage_info.js"></script>
 <script type="text/javascript">
 
  
    function logoFileSelect() {
        document.getElementById("webLogoFile").click(); 
    }
    function iconFileSelect() {
        document.getElementById("iconFile").click(); 
    }
    
    function pcFileSelect() {
        document.getElementById("pcLogoFile").click(); 
    }
    
    function fileSelected(th) {
     var objUrl = getObjectURL(th.files[0]) ;
    	 if (objUrl) {
    	  $("#logoFileDiv").attr("src", objUrl) ;
    	 }
      
    }
    
    function iconFileSelected(th) {
        var objUrl = getObjectURL(th.files[0]) ;
       	 if (objUrl) {
       	  $("#iconFileDiv").attr("src", objUrl) ;
       	 }
         
       }
    
    function pcFileSelected(th) {
        var objUrl = getObjectURL(th.files[0]) ;
       	 if (objUrl) {
       	  $("#pcFileDiv").attr("src", objUrl) ;
       	 }
         
       }
    
   //建立一個可存取到該file的url
   function getObjectURL(file) {
    	 var url = null ; 
    	 if (window.createObjectURL!=undefined) { // basic
    	  url = window.createObjectURL(file) ;
    	 } else if (window.URL!=undefined) { // mozilla(firefox)
    	  url = window.URL.createObjectURL(file) ;
    	 } else if (window.webkitURL!=undefined) { // webkit or chrome
    	  url = window.webkitURL.createObjectURL(file) ;
    	 }
    	 return url ;
    	}
    
    
    function checkPic() {
    	var picPath = document.getElementById("picPath").value;
    	var type = picPath.substring(picPath.lastIndexOf(".") + 1, picPath.length)
    	.toLowerCase();
    	if (type != "jpg" && type != "bmp" && type != "gif" && type != "png") {
    	alert("***请上传正确的图片格式");
    	return false;
    	}
    	return true;
    }
    
    function saveLogoCustom(){
    	var appId=$("#appId").val();
    	if(!$("#customizeForm").valid()) {
            return false;
        }  
    	var webPicTypes = ["png"];
    	var iconPicTypes = ["ico","icon"];
    	var pcPicTypes = ["jpg","jpeg","png"];
     	var webLogoFileName = $("#webLogoFile").val();
    	if(webLogoFileName != ""){
    		var formatValid = false;
    		var curType = webLogoFileName.substring(webLogoFileName.lastIndexOf(".")+1);
    		curType = curType.toLowerCase();
    		for(idx in webPicTypes){
    			if(curType == webPicTypes[idx]){
    				formatValid = true;
    				break;
    			}
    		}
    		if(formatValid == false){
    			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmWebLogoInvalid"/>');
    			return;
    		}
    	}
    	
    	var pcLogoFileName = $("#pcLogoFile").val();
    	if(pcLogoFileName != ""){
    		var formatValid = false;
    		var curType = pcLogoFileName.substring(pcLogoFileName.lastIndexOf(".")+1);
    		curType = curType.toLowerCase();
    		for(idx in pcPicTypes){
    			if(curType == pcPicTypes[idx]){
    				formatValid = true;
    				break;
    			}
    		}
    		if(formatValid == false){
    			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmPcLogoInvalid"/>');
    			return;
    		}
    	}
    	
    	var iconFileName = $("#iconFile").val();
    	if(iconFileName != ""){
    		var formatValid = false;
    		var curType = iconFileName.substring(iconFileName.lastIndexOf(".")+1);
    		curType = curType.toLowerCase();
    		for(idx in iconPicTypes){
    			if(curType == iconPicTypes[idx]){
    				formatValid = true;
    				break;
    			}
    		}
    		if(formatValid == false){
    			top.handlePrompt("error",'<spring:message code="webIconPcLogo.warmIconInvalid"/>');
    			return;
    		}
    	} 
    	$("#customizeForm").attr("action", "${ctx}/enterprise/admin/individual/config");
    	$("#customizeForm").submit();
    }
    
    
   $("#appId").val(window.parent.defaltAppId);
   $("#CappId").val(window.parent.defaltAppId);
		
		
   function saveCorpright(){
    	if(!$("#corprightForm").valid()) {
            return false;
        }  
    	
    	
    	$("#corprightForm").attr("action", "${ctx}/enterprise/admin/individual/config/saveCorpright?appId="+appId);
    	$("#corprightForm").submit();
    }
   $(function(){
	   $("#personal").css("display", "block");
   })
 
</script>
</head>

<div class="content">
	
	<!--面包屑导航-->
	<div class="curr-location">
		<div class="location-icon icon icon-location"></div>
		<div class="curr-location-detail">
			<span>当前位置:</span> <a href="">控制台</a> <span>&gt;</span> <a href="">基础配置</a>
			<span>&gt;</span> <a class="curr-location-now">功能参数</a>
		</div>
	</div>
    <div class="c_main">
          	
                <div class="option-header">
                    <div class="option-item option-header-active" value="personal">个性化</div>
                    <div class="option-item" value="corpright">版权声明</div>
                </div>
              
                <div class="option-content" id="personal">
                  <!--个性化-->
                <form action=""  enctype="multipart/form-data" id="customizeForm" method="post">
                 <input type="hidden" id="token" name="token"value="<c:out value='${token}'/>" />
                 <input type="hidden" id="appId" name="appId" />
                    <div class="ui-row">
                        <div class="personal-title pull-left">系统名称</div>
                        <div class="pull-left">
                            <div class="ui-row-p10">
                                <div class="pull-left personal-label">中文</div>
                                <input type="text" style="width: 280px;" id="titleCh" name="titleCh" value="${cse:htmlEscape(customize.titleCh)}">
                            </div>
                            <div class="ui-row-p10">
                                <div class="pull-left personal-label">English</div>
                                <input type="text" style="width: 280px;" class="pull-left" id="titleEn" name="titleEn" value="${cse:htmlEscape(customize.titleEn)}">
                                <!-- <div class="personal-add">
                                    <div class="icon icon-add"></div>
                                </div> -->
                            </div>
                        </div>
                    </div>
                    <div class="ui-row">
                        <div class="personal-title pull-left">系统logo</div>
                        <div class="pull-left">
                            <div class="sys-logo">
                                <div class="icon icon-sys-logo" >
                                   <c:if test="${customize.existWebLogo}">
                                     <img id="logoFileDiv"  style="width: 100%;height: 100%"  src="${ctx}/syscommon/weblogo/<c:out value='${appId}'/>"/>
                                   </c:if>
                                </div>
                            </div>
                            <div style="margin-top: 5px;">
                                <div class="select-file ui-btn" onclick="logoFileSelect();">
                                                                                                      选择文件
                                </div>
                                
                                <span class="personal-explain">未选择任何文件</span>
                            </div>
                        </div>
                        <div class="personal-explain pull-left" style="padding-top: 5px;">显示在系统的标志区，建议最大宽度300像素，最大高度60像素<br>最大上传文件为5MB，图片格式png</div>
                    </div>
                    <div class="ui-row">
                        <div class="personal-title pull-left">浏览器标志</div>
                        <div class="pull-left" style="padding-top: 5px;">
                           <div class="sys-logo">
                                <div class="icon icon-sys-logo" style="width: 60px">
                                  <c:if test="${customize.existWebLogo}">
                                   <img id="iconFileDiv"  style="width: 100%;height: 100%" src="${ctx}/syscommon/webicon/<c:out value='${appId}'/>"/>
                                   </c:if>
                                </div>
                            </div>
                            <div style="margin-top: 5px;">
                                <div class="select-file ui-btn" onclick="iconFileSelect();">选择文件</div>
                                <span class="personal-explain">未选择任何文件</span>
                            </div>
                        </div>
                         <div class="personal-explain" style="padding-top: 5px">显示在浏览器的标志区，像素16*16，最大128KB，图片格式icon</div>
                     </div>
                      <div class="ui-row">
                        <div class="personal-title pull-left">客户端LOGO</div>
                        <div class="pull-left" style="padding-top: 5px;">
                           <div class="sys-logo">
                                <div class="icon icon-sys-logo" style="width: 60px">
                                  <c:if test="${customize.existWebLogo}">
                                   <img id="pcFileDiv"  style="width: 100%;height: 100%" src="${ctx}/syscommon/webicon/<c:out value='${appId}'/>"/>
                                   </c:if>
                                </div>
                            </div>
                            <div style="margin-top: 5px;">
                                <div class="select-file ui-btn" onclick="pcFileSelect(this);">选择文件</div>
                                <span class="personal-explain">未选择任何文件</span>
                            </div>
                        </div>
                         <div class="personal-explain" style="padding-top: 5px">客户端LOGO的标志区，像素16*16，最大128KB，图片格式icon</div>
                    </div>
                    <div class="ui-row" style="text-align: center;">
                    <div class="ui-btn save-personal" onclick="saveLogoCustom()">保存</div>
                    </div>
               
                 <input type="file" name="webLogoFile" id="webLogoFile" onchange="fileSelected(this);" style="display:none;"/>
                 <input type="file" name="iconFile" id="iconFile" onchange="iconFileSelected(this);" style="display:none;"/>
                 <input type="file" name="pcLogoFile" id="pcLogoFile" onchange="pcFileSelected(this);" style="display:none;"/>
               
                </form>
              </div>
                <!--版权声明-->
              <div class="option-content" id="corpright">
                <form action=""  enctype="multipart/form-data" id="corprightForm" method="post">
                 <input type="hidden" id="token" name="token"value="<c:out value='${token}'/>" />
                 <input type="hidden" id="CappId" name="CappId" />
                    <div class="ui-row">
                        <div class="personal-title pull-left">版权信息</div>
                        <div class="pull-left">
                            <div class="ui-row-p10">
                                <div class="pull-left personal-label">中文</div>
                                <input type="text" style="width: 280px;" id="corprightCN" name="corprightCN" value="${cse:htmlEscape(customize.corprightCN)}">
                            </div>
                            <div class="ui-row-p10">
                                <div class="pull-left personal-label">English</div>
                                <input type="text" style="width: 280px;" class="pull-left" id="corprightEN" name="corprightEN" value="${cse:htmlEscape(customize.corprightEN)}">
                               <!--  <div class="personal-add">
                                    <div class="icon icon-add"></div>
                                </div> -->
                            </div>
                        </div>
                    </div>
                    <div class="ui-row" style="text-align: center;">
                      <div class="ui-btn save-personal" onclick="saveCorpright()">保存</div>
                    </div>
                </form>
              </div>
      </div>
</div>
</body>
</html>