<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-switchButton.js" type="text/javascript"></script>
</head>
<body>

	<div class="sys-content">
			<div class="clearfix control-group">
				<a class="return btn btn-small pull-right"
					href="${ctx}/enterprise/admin/listAppByAuthentication"><i
					class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
				<h5 class="pull-left" style="margin: 3px 0 0 4px;">
					<a href="${ctx}/enterprise/admin/listAppByAuthentication"><c:out value='${appId}'/></a>&nbsp;&gt;&nbsp;
					<spring:message code="watermask.title" />
				</h5>
			</div>
				<div class="alert clearfix">
					<div class="pull-left">
					<p><strong><spring:message code="common.title.info"/></strong></p> 
					<p> <spring:message code="watermask.message"/></p>
			</div>
	</div>

	<div class="sys-content">
	    </div>
            <div class="controls">
            <form id="uploadWaterMarkForm" name="uploadWaterMarkForm"class="form-horizontal" enctype="multipart/form-data" 
     					  method="post" action="${ctx}/watermark/upload">
     		  <fieldset>
  				  <legend><spring:message code="watermask.message.label"/></legend>
			<input type="file" name="fileName" id="fileName"> 
			<input type="submit" class="btn btn-primary btn-small" value="<spring:message code="watermask.upload" />"/> 
            <input type="hidden" hidden="hidden" name ="appId" value="<c:out value='${appId}'/>"> 
             </fieldset>
             <input type="hidden" name="token" value="${token}"/>
            </form> 

          </div>
		<div class="clearfix control-group">
			 <div>
             	 <fieldset>
  				  <legend><spring:message code="watermask.message.image"/></legend>
            	 	<label id='no_image' style="display:none"><spring:message code="watermark.no.image"/></label>
            	 	<label id='Error_image' style="display:none"><spring:message code="watermark.image.error"/></label>
            	 	<img id="image_water"  style="display:none" alt="<spring:message code="watermark.image.error"/>" class="img-polaroid" title="<spring:message code='watermark.image.title'/>"/>
            	 </fieldset>
         	</div> 
		</div>

	</div>
	</div>
</body>
<script type="text/javascript">
$(document).ready(function() {
	$.ajax({
		type : "GET",
		url : "${ctx}/watermark/<c:out value='${appId}'/>/image?"+ Math.random(),
		error : function(request) {
			$("#Error_image").attr("style","display:bock");
		},
		success : function(data) {
			if(data=="")
			{
				$("#image_water").attr("style","display:none");
				$("#no_image").attr("style","display:bock");
			}else
			{
				$("#no_image").attr("style","display:none");
				$("#image_water").attr("style","display:block");
				$("#image_water").attr("src","${ctx}/watermark/<c:out value='${appId}'/>/image?"+ Math.random());
			}
		}
	});
	var message ="<c:out value='${message}'/>";
	if(message!=null&&message!="")
	{
		handlePrompt("error",message);
	
	}
})
function uploaImage(){
	$("#uploadLicenseForm").submit();
}

</script>
</html>
