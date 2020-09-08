<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
</head>
<body>
<div class="sys-content">
	<div class="clearfix control-group">
		<a  class="return btn btn-small pull-right" onclick="backList()">
		<i class="icon-backward"></i>&nbsp;<spring:message  code="common.back"  /></a>
		<h5 class="pull-left" style="margin: 3px 0 0 4px;"><a href="${ctx}/enterprise/admin/authserver/enterList"><c:out value='${authServer.name}'/></a>&nbsp;>&nbsp;<a onclick="backList()"><spring:message code="enterpriseList.catch.app"/></a>&nbsp;>&nbsp;<spring:message code="authserver.network.config"/></h5>
	</div>
	<div class="clearfix table-con">
		<button type="button" class="btn btn-primary" onclick="createNetwork()" id="createNetwork"><i class="icon-plus"></i> <spring:message code="common.create" /></button>
    	<button type="button" class="btn" onClick="deletePrompt()"><spring:message code="space.button.delete"/></button>
	</div>
	<div class="table-con">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
    </div>
    <input type="hidden" id="authServerId" name="authServerId" value="<c:out value='${authServerId}'/>" class="span4" />
	<input type="hidden" id="accountId" name="accountId" value="<c:out value='${accountId}'/>" class="span4" />
</div>
</body>
<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid = null;
var opts_page = null;
var headData = {
		"ipStart" : {
			"title" : "<spring:message code='clusterManage.startIp'/>",
			"width" : "282px"
			},
		"ipEnd" : {
			"title" : "<spring:message code='clusterManage.endIp'/>",
			"width" : "282px"
			}
	};
$(document).ready(function() {
	
	opts_viewGrid = $("#rankList").comboTableGrid({
		headData : headData,
		dataId : "id",
		checkBox : true,
		checkAll : true
	});
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
	
	if (!placeholderSupport()) {
		placeholderCompatible();
	};
	
});

function initDataList(curPage) {
	var url = "${ctx}/enterprise/admin/accountauthservernetwork/list";
	var PerPageNum = 20;
	var params = {
			"page" : curPage,
			"token" : "${token}",
			"size" : PerPageNum,
			"authServerId" : "<c:out value='${authServerId}'/>",
			"accountId" : "<c:out value='${accountId}'/>"
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
function createNetwork()
{
	top.ymPrompt.win({
		message:'${ctx}/enterprise/admin/accountauthservernetwork/enterCreate/'+<c:out value="${accountId}"/>+'/'+<c:out value="${authServerId}"/>,
		width:700,
		height:430,
		title:'<spring:message  code="network.region.create.title"/>', 
		iframe:true,
		btn:[
		     ['<spring:message  code="common.create"/>','yes',false,"btn-focus"],
		     ['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],
		     handler:doCreateNetwork});
	top.ymPrompt_addModalFocus("#btn-focus");
}
function doCreateNetwork(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
	refreshWindow();
}
function deletePrompt()
{
	var idArray = $("#rankList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="user.tag.select"/>');
		return;
	}
	var ids=idArray.join(",");
	var params = {
		"ids":ids,
		"authServerId" : "<c:out value='${authServerId}'/>",
		"accountId" : "<c:out value='${accountId}'/>",
		"token" : "<c:out value='${token}'/>"
	};
	ymPrompt.confirmInfo({
				title : '<spring:message code="common.delete"/>',
				message : '<spring:message code="common.delete"/>'
						+ '<br/>'
						+ '<spring:message code="common.delete.message"/>',
				width : 450,
				closeTxt : '<spring:message code="common.close"/>',
				handler : function(tp) {
					if (tp == "ok") {
						deleteByIds(params);
					}
				},
				btn : [
						[ '<spring:message code="common.OK"/>', "ok" ],
						[ '<spring:message code="common.cancel"/>',
								"cancel" ] ]
			});
}
function deleteByIds(params) {
	$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/admin/accountauthservernetwork/deleteByIds",
				data : params,
				error : function(request) {
					top.handlePrompt("error",
									'<spring:message code="user.manager.deleteFailed"/>');
				},
				success : function() {
					top.handlePrompt("success",
									'<spring:message code="user.manager.deteteSuccessed"/>');
					refreshWindow();
				}
			});
}
function backList()
{
	window.location = '${ctx}/enterprise/admin/authserver/bindAppList/'+<c:out value='${authServerId}'/>;
}
function refreshWindow() {
	window.location.reload();
}
</script>
</html>
