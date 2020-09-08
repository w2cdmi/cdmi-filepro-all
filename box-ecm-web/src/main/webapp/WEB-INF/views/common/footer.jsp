<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*,java.util.Locale" %>
<% 
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

Locale locale = request.getLocale();
String language = locale.getLanguage();
%>
<div class="footer" style="text-align: center;padding: 5px">
    <input type="hidden" id="lagauge" value="<% out.println( language);%>"/> 
	<div class="footer-con">
    	<p id="copyRightId"></p>
    </div>
</div>
<script type="text/javascript">

$.ajax({
		type : "POST",
		url : '${ctx}/enterprise/admin/basicconfig/defaultAppId',
		data : {"token": "${token}"},
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
		},
		success : function(data) {
		//	alert($("#lagauge").val());
			$.ajax({
				type : "POST",
				url : '${ctx}/enterprise/admin/individual/config/getCorpright',
				data : {"token" : "${token}",appId:data,lagauge: $("#lagauge").val()},
				success : function(copyRightId) {
					$("#copyRightId").text(copyRightId);
				}
			}) 
		}
	})
	


</script>