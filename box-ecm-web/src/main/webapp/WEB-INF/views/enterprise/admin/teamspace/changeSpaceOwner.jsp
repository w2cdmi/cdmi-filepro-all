<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<link href="${ctx}/static/autocomplete/themes/base/jquery.ui.all.css"
	rel="stylesheet" type="text/css">
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/autocomplete/ui/jquery.ui.core.js" type="text/javascript"></script>
<script src="${ctx}/static/autocomplete/ui/jquery.ui.widget.js" type="text/javascript"></script>
<script src="${ctx}/static/autocomplete/ui/jquery.ui.position.js" type="text/javascript"></script>
<script src="${ctx}/static/autocomplete/ui/jquery.ui.menu.js" type="text/javascript"></script>
<script src="${ctx}/static/autocomplete/ui/jquery.ui.autocomplete.js" type="text/javascript"></script>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="creatAdminForm">
        <input type="hidden" id="status" name="status" value="true" />
        <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
			<button class="close" data-dismiss="alert">×</button><spring:message code="common.createFail"/>
		</div>
        <div class="control-group">
            <spring:message code='teamSpace.changeOwer.content'/>
            <div class="controls">
                <input type="hidden" id="teamId" value="<c:out value='${teamId}'/>" name="teamId"/>
                <input type="hidden" id="loginName" value="" name="loginName"/>
                <input id="messageAddr" type="text" maxlength="500"  class="span4" autoComplete="off" /> 
            </div>
        </div>
	</form>
    </div>
</div>
<script type="text/javascript">

var appId = "<c:out value='${appId}'/>";

$(document).ready( function() {
	$("#messageAddr").keydown(
			function(event) {
				if (event.keyCode == 13) {
					searchMessageTo();
					return false;
				}
			})
});
function submitChangeOwner() {
	var selUser = $("#messageAddr").val();
	if(selUser.search(/.*\(([a-zA-Z]{1}[a-zA-Z0-9]{3,59})\)$/) != -1)
	{
		var tmpLoginName = RegExp.$1;
		$("#loginName").val(tmpLoginName);
	}else{
		handlePrompt("error",'<spring:message code="common.operationFailed"/>');
		return;
	}
	if($("#loginName").val() == ""){
		handlePrompt("error",'<spring:message code="common.operationFailed"/>');
		return;
	}
	
    var params= {
		    "teamId":  $("#teamId").val(), 
		    "loginName": $("#loginName").val(),
		    "token" : "<c:out value='${token}'/>"
	    };
    
	$.ajax({
        type: "POST",
        url:"${ctx}/app/teamspace/config/changeOwner/" + appId,
        data:params,
        error: function(request) {
        	handlePrompt("error",'<spring:message code="common.operationFailed"/>');
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
        }
    });
}
var allMessageTo;
var availableTags;
function searchMessageTo() {
	allMessageTo = new Array();
	availableTags = [];
	$("#divMessage").remove();
    var params= {
	    "userName": $("#messageAddr").val(),
	    "token" : "<c:out value='${token}'/>"
    };
    var list;
	$.ajax({
        type: "POST",
        data: params,
        url:"${ctx}/enterprise/admin/teamspace/config/listUser/" + appId,
        error: function(request) {
        	ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.searchUserFail"/>'});
        },
        success: function(data) {
        	list = data.content;
        	
        	var len = list.length;
        	if (len == 0) {
				handlePrompt("error",'<spring:message code="common.searchUserFail"/>');
				return;
			}
        	if(len>100){
        	    len = 100;
        	}
        	for ( var i = 0; i < len; i++) {
        		availableTags.push({label:list[i].name,loginName:list[i].loginName,department:list[i].department});
        	}
        
	        $( "#messageAddr" ).bind( "keydown", function( event ) {
				if ( event.keyCode === $.ui.keyCode.TAB &&
						$( this ).data( "ui-autocomplete" ).menu.active ) {
					event.preventDefault();
					$("#divMessage").remove();
				}
			}).autocomplete({
				disabled :true,
				minLength: 0,
				source: function( request, response ) {
					response( $.ui.autocomplete.filter(
						availableTags, extractLast( request.term ) ) );
				},
				focus: function() {
					return false;
				},
				select: function( event, ui ) {
					
					this.value = "";
					$("#messageAddr").val(ui.item.label + "(" + ui.item.loginName + ")");
					return false;
				}
	 		}).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
				return $( "<li>" )
				.append( "<a><strong>" + item.label + "</strong> (" + item.loginName + ") " + "<br>" + item.department + "</a>" )
				.appendTo( ul );
			};
        
			$("#messageAddr").autocomplete("enable");
			$("#messageAddr").autocomplete("search", $("#messageAddr").val());
        }
    });
}
function split( val ) {
	return val.split( /,\s*/ );
}
function extractLast( term ) {
	return split( term ).pop();
}
</script>
</body>
</html>
