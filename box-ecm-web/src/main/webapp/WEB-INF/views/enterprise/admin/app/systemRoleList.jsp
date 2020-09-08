<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js"type="text/javascript"></script>
<script src="${ctx}/static/zTree/jquery.ztree.core-3.5.js" type="text/javascript"></script>

<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<div class="sys-content">
		<div class="clearfix control-group">
			<a class="return btn btn-small pull-right"
				href="${ctx}/enterprise/admin/listAppByAuthentication"><i
				class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
			<h5 class="pull-left" style="margin: 3px 0 0 4px;">
				<a href="${ctx}/enterprise/admin/listAppByAuthentication"><c:out value='${appId}'/></a>&nbsp;&gt;&nbsp;
				<spring:message code="manage.title.basic" />
			</h5>
		</div>
		<ul class="nav nav-tabs clearfix">
        <li><a class="return" href="${ctx}/enterprise/admin/teamspace/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.teamspace"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/statistics/list/<c:out value='${appId}'/>"><spring:message code="header.statistics"/> </a></li>
        <c:if test="${appType == 1}">
        	<li><a class="return" href="${ctx}/enterprise/admin/individual/config/<c:out value='${appId}'/>"><spring:message code="individual.config"/> </a></li>
        </c:if>
        <li class="active"><a class="return" href="${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>"><spring:message code="systemRoleList.systemRoleManage"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
       	<li><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
        </ul>
		<div class="clearfix table-con">
			<div class="pull-left">
		        <button type="button" class="btn" onClick="setAccountRoles()"><spring:message code="systemRoleList.setAccountRole"/></button>
			</div>
			
		</div>
		<div class="table-con">
			<div id="systemRoleList"></div>
		</div>
		<h5>
			<spring:message code="systemRoleList.selectedSystemRole"/>
		</h5>
		<div class="table-con">
			<div id="accountRoleList"></div>
		</div>
	</div>

</body>
<script type="text/javascript">
	var appId = "<c:out value='${appId}'/>";
	var opts_viewGrid_system = null;
	var opts_viewGrid_account = null;
    var dropSlct = {
    	"auther":"<spring:message code='systemRole.title.auther'/>",
    	"editor":"<spring:message code='systemRole.title.editor'/>",
    	"uploadAndView":"<spring:message code='systemRole.title.uploadAndView'/>",
    	"viewer":"<spring:message code='systemRole.title.viewer'/>",
    	"uploader":"<spring:message code='systemRole.title.uploader'/>",
    	"downLoader":"<spring:message code='systemRole.title.downloader'/>",
    	"previewer":"<spring:message code='systemRole.title.previewer'/>",
    	"lister":"<spring:message code='systemRole.title.lister'/>",
    	"prohibitVisitors":"<spring:message code='systemRole.title.prohibitVisitors'/>"
   	 };
				            
	var headData_system = {
		"name" : {
				"title" : "<spring:message code='systemRoleList.title.name'/>",
				"width" : "100px"
			},
		"permission" : {
			"title" : "<spring:message code='systemRoleList.title.permision'/>",
			"width" : "300px"
		},
		"description" : {
			"title" : "<spring:message code='systemRoleList.title.description'/>",
			"width" : "300px"
		}
	};

	var headData_account = {
		"name" : {
				"title" : "<spring:message code='systemRoleList.title.name'/>",
				"width" : "100px"
			},
		"permission" : {
			"title" : "<spring:message code='systemRoleList.title.permision'/>",
			"width" : "300px"
		},
		"description" : {
			"title" : "<spring:message code='systemRoleList.title.description'/>",
			"width" : "300px"
		},
		"operation" : {
			"title" : "<spring:message code='systemRoleList.title.operation'/>",
			"width" : "100px"
		}
	};
	$(document).ready(function() {
		opts_viewGrid_system = $("#systemRoleList").comboTableGrid({
			headData : headData_system,
			checkBox : true,
			checkAll : false,
			height : 300,
			dataId : "name",
			definedColumn : true,
			taxisFlag : false
		});
		opts_viewGrid_account = $("#accountRoleList").comboTableGrid({
			headData : headData_account,
			checkBox : false,
			checkAll : false,
			height : 300,
			dataId : "name",
			definedColumn : true,
			taxisFlag : false
		});
		$.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
			var btn;
			switch (colIndex) {
			case "name":
				try {
					var text = rowData.name;
					if(text == "")
					{
						tdItem.find("p").html("_");
					}
					else{
						tdItem.find("p").html(dropSlct[text]);
					}
				} catch (e) {
				}
				break;
			case "description":
				try {
					var text = tdItem.find("p").text();
					if(text == "")
					{
						tdItem.find("p").html("_");
					}
				} catch (e) {
				}
				break;
			case "permission":
				try {
				    var _txt = setAuthorityHint(rowData);
				    tdItem.find("p").html(_txt);
					
				} catch (e) {
				}
				break;				
			case "createdAt":
				try {
					var text = tdItem.find("p").text();
					if(text == "")
					{
						tdItem.find("p").html("_");
					}
					else{
					var date = getLocalTime(rowData.createdAt)
					tdItem.find("p").html(date).parent().attr("title", date);
					}

				} catch (e) {
				}
				break;
			case "operation":
				try {
					btn ='<button onclick="deleteAccountRole(\''+rowData.name+'\')" class="btn btn-small" type="button"><spring:message code="common.delete" /></button>';
					tdItem.find("p").addClass("ac").append(btn);
				} catch (e) {
				}
				break; 
			default:
				break;
			}
		};

		initSystemList();
		initAccountList();
	});

	function initSystemList() {
		var url = "${ctx}/enterprise/admin/systemrole/" + "<c:out value='${appId}'/>" + "/system";
		$("#systemRoleList").showTableGridLoading();
		$.ajax({
			type : "GET",
			url : url,
			error : function(request) {
				handlePrompt("error",'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				$("#systemRoleList").setTableGridData(data, opts_viewGrid_system);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}
	
	function initAccountList() {
		var url = "${ctx}/enterprise/admin/systemrole/" + "<c:out value='${appId}'/>" + "/account?" + Math.random();
		$("#accountRoleList").showTableGridLoading();
		$.ajax({
			type : "GET",
			url : url,
			error : function(request) {
				handlePrompt("error",'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				if(data == ""){
					handlePrompt("error",'<spring:message code="common.add.role" />');
				}
				$("#accountRoleList").setTableGridData(data, opts_viewGrid_account);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}
	
	function setAccountRoles() {
		var idArray = $("#systemRoleList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="systemRoleList.selectSystemRole"/>');
			return;
		}
		var ids;
		if(idArray=="all")
		{
			ids="all";
		}
		else
		{
			ids = idArray.join(",");
		}

	    var params= {
			    "roleIds": ids,
			    token:'<c:out value="${token}"/>'
		    };
        $.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/admin/systemrole/add/" + appId,
	        data:params,
	        error: function(request) {
	        	handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        },
	        success: function(data) {
	        	if(data !="")
	        	{
	        		handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        	}
	        	else
	        	{
	            	handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
	        	}
	        	initAccountList();
	        }
	    });
	}
	
	function deleteAccountRole(roleName) {
	    var params= {
			    "roleId": roleName,
			    token:'<c:out value="${token}"/>'
		    };
        $.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/admin/systemrole/delete/" + appId,
	        data:params,
	        error: function(request) {
	        	handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        },
	        success: function(data) {
	        	if(data !="")
	        	{
	        		handlePrompt("error",'<spring:message code="common.operationFailed"/>');
	        	}
	        	else
	        	{
	            	handlePrompt("success",'<spring:message code="common.operationSuccess"/>');
	        	}
	        	initAccountList();
	        }
	    });
		
	}
	function refreshWindow() {
		window.location = "${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>";
	}
	
	function setAuthorityHint(data){
		var str = "";
		if (data != null) {
			if (data["browse"] == 1) {
    			str += "<spring:message code='systemRoleList.label.browse'/>,&nbsp;";
    		}
    		if (data["preview"] == 1) {
    			str += "<spring:message code='systemRoleList.label.preview'/>,&nbsp;";
    		}
    		if (data["upload"] == 1) {
    			str += "<spring:message code='systemRoleList.label.upload'/>,&nbsp;";
    		}
    		if (data["download"] == 1) {
    			str += "<spring:message code='systemRoleList.label.download'/>,&nbsp;";
    		}
    		if (data["edit"] == 1) {
    			str += "<spring:message code='systemRoleList.label.edit'/>,&nbsp;";
    		}
    		if (data["publishLink"] == 1) {
    			str += "<spring:message code='systemRoleList.label.publishLink'/>,&nbsp;";
    		}
    		if (data["authorize"] == 1) {
    			str += "<spring:message code='systemRoleList.label.authorize'/>,&nbsp;";
    		}
    		if (str != "") {
    			str = str.substring(0,str.length - ",&nbsp;".length);
    		}
		}
		return str;
	}

</script>
</html>
