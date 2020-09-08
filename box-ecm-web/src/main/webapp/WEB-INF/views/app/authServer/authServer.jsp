<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token",CSRFTokenManager.getTokenForSession(session));%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-switchButton.js" type="text/javascript"></script>
</head>
<body>
<div class="sys-content">
	<c:if test="${networkAuthStatusSwitch}">
	<div class="form-con clearfix">
		<span id="switchButton" class="pull-right"></span>
		<div class="pull-left">
			<p><strong><spring:message code="common.description"/></strong></p>
			<p class="help-block"><spring:message code="authserver.network.desc"/></p>
			<input type="hidden" id="networkAuthStatus" name="networkAuthStatus" value="<c:out value='${networkAuthStatus}'/>" class="span4" />
		</div>
	</div>
	</c:if>
	<div class="clearfix table-con">
		<button type="button" class="btn btn-primary" onclick="createAuthServer()" id="createAuthServerBtn">
		<i class="icon-plus"></i><spring:message code="common.create" />
	    </button>
	</div>
    <div class="table-con">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
    </div>
</div>
</body>
<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid = null;
var opts_page = null;
var headData = {
		"name" : {
			"title" : "<spring:message code='common.name'/>",
			"width" : "282px"
			},
		"type" : {
			"title" : "<spring:message code='clusterManage.authenticationTpye'/>",
			"width" : "200px"
		},
		"description" : {
			"title" : "<spring:message code='common.description'/>",
			"width" : "auto"
		},
		"operation" : {
			"title" : "<spring:message code='common.operation'/>",
			"width" : "284px"
		}
	};
$(document).ready(function() {
	opts_viewGrid = $("#rankList").comboTableGrid({
		headData : headData,
		dataId : "id"
	});
	
	$.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
		switch (colIndex) {
		case "name":
			try {
				var name = tdItem.find("p").text();
				if (name == "") {
					tdItem.find("p").html("-").parent().attr("title","-");
				}
				var type = rowData.type;
				if (type == "LocalAuth")
				{
					tdItem.find("p").html('<spring:message  code="authserver.type.local"  />').parent().attr("title",'<spring:message  code="authserver.type.local"  />');
				}
			} catch (e) {
			}
			break;
		case "description":
			try {
				var description = tdItem.find("p").text();
				if (description == "") {
					tdItem.find("p").html("-").parent().attr("title","-");
				}
				var type = rowData.type;
				if (type == "LocalAuth")
				{
					tdItem.find("p").html('<spring:message  code="authserver.description.local"  />').parent().attr("title",'<spring:message  code="authserver.description.local"  />');
				}
			} catch (e) {
			}
			break;
		case "type":
			try {
				var type = tdItem.find("p").text();
				switch(type){
				case "LocalAuth":
					tdItem.find("p").html('<spring:message  code="clusterManage.localauth"  />').parent().attr("title",'<spring:message  code="clusterManage.localauth"  />');
					break;
				case "AdAuth":
					tdItem.find("p").html('<spring:message  code="authorize.regionAD"  />').parent().attr("title",'<spring:message  code="authorize.regionAD"  />');
					break;
				default:
					tdItem.find("p").html('<spring:message  code="clusterManage.LdapAuth"  />').parent().attr("title",'<spring:message  code="clusterManage.LdapAuth"  />');
					break;
		}
				
				
			} catch (e) {
			}
			break;
		case "operation":
			try {
				var type = rowData.type;
				var btns;
				if (type == "LocalAuth"||type==undefined)
				{
					btns = '<input class="btn" type="button" value="<spring:message  code="enterpriseList.catch.app"  />" onClick="bindApp('+ rowData.id + ')"/>';
				}
				else
				{
					var textStatus = "";
					if(rowData.status == 1)
					{
						textStatus = '<spring:message code="common.enable"/>';
					}
					if(rowData.status == 0)
					{
						textStatus = '<spring:message code="common.stop"/>';
					}
					
					btns = '<input class="btn btn-small" type="button" value="'+textStatus+'" onClick="updateStatus('
					+ rowData.id +',' + rowData.status
					+ ')"/> <input class="btn btn-small" type="button" value="<spring:message  code="common.setter"  />" onClick="configAuthServer('
					+ rowData.id + ''
					+ ')"/> <input class="btn btn-small" type="button" value="<spring:message  code="enterpriseList.catch.app"  />" onClick="bindApp('
					+ rowData.id + ')"/>';
				}
				tdItem.find("p").html(btns);
			} catch (e) {
			}
			break;
		default:
			break;
		}
	};

	$.fn.comboTableGrid.taxisOp = function(headItem, flag) {
		initDataList(1, headItem, flag);
	};
	
	opts_page = $("#rankListPage").comboPage({
		style : "page table-page",
		lang : '<spring:message code="main.language"/>'
	});

	$.fn.comboPage.pageSkip = function(opts, _idMap, curPage) {
		initDataList(curPage);
	};
	
	initDataList(1);
	getAccessConfigSwitch();
	
	if (!placeholderSupport()) {
		placeholderCompatible();
	};
	
});

function getAccessConfigSwitch(){
	var switchFlag =false;
	if(1==${networkAuthStatus})
		{
			switchFlag=true;
		}
	var switchOpts = $("#switchButton").comboSwitchButton({
		onText : '<spring:message code="authserver.network.opened" />',
		offText : '<spring:message code="authserver.network.closed" />',
		defaultSwitchOn : switchFlag,
		onEvent: function(){
			$("#configSwitch").val("enable");
			var url = "${ctx}/enterprise/admin/authserver/updateNetworkAuthStatus/1";
			$.ajax({
				type : "POST",
				url : url,
				data:{token:'${token}'},
				error : function(request) {
					$("#switchButton").resetSwitchButton(switchOpts);
					top.handlePrompt("error",'<spring:message code="operation.failed" />');
				},
				success : function(data) {
					top.handlePrompt("success",'<spring:message code="common.openSuccess"/>');
				}
			});
			
		},
		offEvent: function(){
			$("#configSwitch").val("disable");
			var url = "${ctx}/enterprise/admin/authserver/updateNetworkAuthStatus/2";
			$.ajax({
				type : "POST",
				url : url,
				data:{token:'${token}'},
				error : function(request) {
					$("#switchButton").resetSwitchButton(switchOpts);
					top.handlePrompt("error",'<spring:message code="operation.failed" />');
				},
				success : function(data) {
					top.handlePrompt("success",'<spring:message code="common.closeSuccess"/>');
				}
			});
			
		}
	})
}

function initDataList(curPage) {
	var url = "${ctx}/enterprise/admin/authserver/list";
	var params = {
			"page" : curPage,
			"token" : "${token}"
		};
	$("#rankList").showTableGridLoading();
	
	$.ajax({
		type : "POST",
		url : url,
		data : params,
		error : function(request) {
			doError(request);
		},
		success : function(data) {
			catalogData = data.content;
			$("#rankList").setTableGridData(catalogData, opts_viewGrid);
			$("#rankListPage").setPageData(opts_page, data.number,data.size, data.totalElements);
			var pageH = $("body").outerHeight();
			top.iframeAdaptHeight(pageH);
		}
	});
}

function doError(request)
{
	switch(request.statusText){
			case "forbidden":
				handlePrompt("error",'<spring:message  code="authServer.forbidden"/>');
				break;
			case "InvalidParameter":
				handlePrompt("error",'<spring:message  code="authServer.list.fail"/>');
				break;
			default:
				handlePrompt("error",'<spring:message  code="authServer.list.fail"/>');
				break;
	}
}

function refreshWindow() {
	window.location.reload();
}

function updateStatus(id,status){
	var tilteTip,messageTip;
	if(status == 1){
		tilteTip = '<spring:message code="authServer.enable"/>';
		messageTip = '<spring:message code="authServer.enable"/>';
	}else{
		tilteTip = '<spring:message code="authServer.disable"/>';
		messageTip = '<spring:message code="authServer.disable"/>';
	}
	top.ymPrompt.confirmInfo( {
		title :tilteTip,
		message :messageTip,
		width:450,
		closeTxt:'<spring:message code="common.close"/>',
		handler : function(tp) {
			if(tp == "ok"){
				changeStatus(id,status);
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}

function changeStatus(id,status)
{
	var url="${ctx}/enterprise/admin/authserver/changeStatus";
	if(status==0)
	{
		status=1;	
	}
	else
	{
		status=0;
	}
	$.ajax({
        type: "POST",
        url:url,
        data:{id:id,status:status,token:'${token}'},
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="common.modifyStatusFailed"/>');
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="common.modifyStatusSucessed"/>');
        	refreshWindow();
        }
    });	
}

function deleteAuthServer(authServerId)
{
	var url = "${ctx}/enterprise/admin/authserver/delete/"+authServerId;
	
	top.ymPrompt.confirmInfo( {
		title :'<spring:message  code="authServer.delete.authserver.titile"/>',
		message : '<spring:message  code="common.delete.message"/>',
		closeTxt:'<spring:message code="common.close"/>',
		handler : function(tp) {
			if(tp == "ok"){
					$.ajax({
			        type: "DELETE",
			        url:url,
			        data:{token:'${token}'},
			        error: function(request) {
			        	top.handlePrompt("error",'<spring:message code="user.manager.deleteFailed"/>');
			        },
			        success: function() {
			        	top.handlePrompt("success",'<spring:message code="user.manager.deteteSuccessed"/>');
			        	refreshWindow();
			        }
			    });
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});

}

function configAuthServer(authServerId)
{
	var url = "${ctx}/enterprise/admin/configauthserver/checkAuthServer/"+authServerId;
	$.ajax({
        type: "GET",
        url:url,
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="authServer.disable.hit"/>');
        },
        success: function(request) {
        	window.location = "${ctx}/enterprise/admin/configauthserver/config/"+authServerId;
        }
    });	
}

function bindApp(authServerId)
{
	var url = "${ctx}/enterprise/admin/configauthserver/checkAuthServer/"+authServerId;
	$.ajax({
        type: "GET",
        url:url,
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="authServer.disable.hit"/>');
        },
        success: function(request) {
        	window.location = "${ctx}/enterprise/admin/authserver/bindAppList/" + authServerId;
        }
    });	
}

function doBindApp(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitBindApp();
	} else {
		top.ymPrompt.close();
	}
}

function createAuthServer() {
	var url = "${ctx}/enterprise/admin/authserver/create";
	top.ymPrompt.win({
		message : url,
		width : 750,
		height : 380,
		title : '<spring:message  code="authServer.add.authserver"/>',
		iframe : true,
		btn : [
				[ '<spring:message code="common.create"/>', 'yes', false,
						"btn-focus" ],
				[ '<spring:message code="common.cancel"/>', 'no', true,
						"btn-cancel" ] ],
		handler : saveAuthServer
	});
	top.ymPrompt_addModalFocus("#btn-focus");
}

function saveAuthServer(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitAuthServer();
	} else {
		top.ymPrompt.close();
	}
}

</script>
</html>
