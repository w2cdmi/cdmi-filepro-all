<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
</head>
<body>
<div class="sys-content">

    <div class="clearfix control-group">
			<a class="return btn btn-small pull-right"
				href="${ctx}/enterprise/admin/user/employeeManage/<c:out value='${authServerId}'/>"><i
				class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
			<h5 class="pull-left" style="margin: 3px 0 0 4px;">
				<a href="${ctx}/enterprise/admin/user/employeeManage/<c:out value='${authServerId}'/>"><c:out value='${authServrName}'/></a>&nbsp;&gt;&nbsp;
				<spring:message code="employeeManage.clear.user" />
			</h5>
	</div>

   <div class="alert">
	  <i class="icon-lightbulb"></i>
	  <spring:message code="user.manager.ldapCheckDesc" />
   </div>

   <div class="clearfix check-AD-user">
    	<button type="button" class="btn btn-primary btn-middle pull-left" onClick="syncDeleteUsers()">&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code="user.manager.ldapCheck"/>&nbsp;&nbsp;&nbsp;&nbsp;</button>
    	<span><spring:message code="user.manager.ldapCheckTime"/><fmt:formatDate value="${ldapCheck.lastCheckTime}" pattern="yyyy-MM-dd HH:mm:ss"/><spring:message code="user.manager.ldapCheckComma"/><spring:message code="user.manager.ldapCheckCount"/> <strong><c:out value='${ldapCheck.userCount}'/></strong> <spring:message code="user.manager.ldapCheckDelete"/></span>
    </div>
    <div class="table-con">
	    	<button type="button" class="btn" onClick="deleteUsersPrompt()"><spring:message code="space.button.delete"/></button>
	    	<button type="button" class="btn" onClick="deleteAllUsersPrompt()"><spring:message code="user.manager.ldapCheckDeleteAll"/></button>
    </div>
    <div id="myPage"></div>
    <div class="table-con">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
	</div>
</div>
</body>
<script type="text/javascript">
var opts_viewGrid = null;
var opts_page = null;
var headData = {
	"name" : {
			"title" : '<spring:message code="user.manager.username"/>',
			"width" : "520px"
		},
	"alias" : {
		"title" : '<spring:message code="user.manager.username.alias"/>',
		"width" : "auto"
	}
};
$(document).ready(function() {
	opts_viewGrid = $("#rankList").comboTableGrid({
		headData : headData,
		checkBox : true,
		height : 775,
		dataId : "id"
	});
	$.fn.comboTableGrid.taxisOp = function(headItem, flag) {
		initDataList(1);
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
	var params = {
			"page" : curPage,
			"token" : "<c:out value='${token}'/>"
		};
	var url = "${ctx}/enterprise/admin/ldapuser/getDeleteUsers";
	$("#rankList").showTableGridLoading();
	$.ajax({
		type : "POST",
		url : url,
		data : params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
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

function syncDeleteUsers()
{
	var params = {
			"token" : "<c:out value='${token}'/>"
		};
	var url="${ctx}/enterprise/admin/ldapuser/syncDeleteUsers";
	$.ajax({
        type: "POST",
        url:url,
        data : params,
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="user.manager.ldapCheckFailed"/>');
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="user.manager.ldapCheckSuccess"/>');
        	refreshWindow();
        }
    });	
}
function deleteUsersPrompt()
{
	var idArray = $("#rankList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
		return;
	}
	var ids=idArray.join(",");
	var params = {
		"ids":ids,
		"token":"${token}"
	};
	ymPrompt.confirmInfo({
				title : '<spring:message code="user.manager.deleteUser"/>',
				message : '<spring:message code="user.manager.deleteUser"/>'
						+ '<br/>'
						+ '<spring:message code="user.manager.deleteDescription"/>',
				width : 450,
				closeTxt : '<spring:message code="common.close"/>',
				handler : function(tp) {
					if (tp == "ok") {
						deleteUsers(params);
					}
				},
				btn : [
						[ '<spring:message code="common.OK"/>', "ok" ],
						[ '<spring:message code="common.cancel"/>',
								"cancel" ] ]
			});
}
function deleteUsers(params) {
	$.ajax({
				type : "POST",
				url : "${ctx}/enterprise/admin/ldapuser/delete",
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
function deleteAllUsersPrompt()
{
	ymPrompt.confirmInfo({
				title : '<spring:message code="user.manager.deleteUser"/>',
				message : '<spring:message code="user.manager.deleteUser"/>'
						+ '<br/>'
						+ '<spring:message code="user.manager.deleteDescription"/>',
				width : 450,
				closeTxt : '<spring:message code="common.close"/>',
				handler : function(tp) {
					if (tp == "ok") {
						deleteAllUsers();
					}
				},
				btn : [
						[ '<spring:message code="common.OK"/>', "ok" ],
						[ '<spring:message code="common.cancel"/>',
								"cancel" ] ]
			});
}
function deleteAllUsers()
{
	var params = {
		"token":"${token}"
	};
	var url="${ctx}/enterprise/admin/ldapuser/deleteAll";
	$.ajax({
        type: "POST",
        data : params,
        url:url,
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="user.manager.deleteFailed"/>');
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="user.manager.deteteSuccessed"/>');
        	refreshWindow();
        }
    });
}
</script>
</html>
