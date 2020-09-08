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
<%@ include file="../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"
	type="text/javascript"></script>
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
        <li class="active"><a class="return" href="${ctx}/enterprise/admin/statistics/list/<c:out value='${appId}'/>"><spring:message code="header.statistics"/> </a></li>
        <c:if test="${appType == 1}">
            <li><a class="return" href="${ctx}/enterprise/admin/individual/config/<c:out value='${appId}'/>"><spring:message code="individual.config"/> </a></li>
        </c:if>
        <li><a class="return" href="${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>"><spring:message code="systemRoleList.systemRoleManage"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
        </ul>
		<div class="clearfix control-group">
			<h5><c:out value='${appId}'/>&nbsp;<spring:message code="statistics.application"/></h5>
		</div>
		<div id="statisList"></div>
		<br />
		<div class="clearfix control-group">
			<h5><c:out value='${appId}'/>&nbsp;<spring:message code="user.manager.usedUserSpace"/>&nbsp;TOP 10</h5>
		</div>
		<div id="rankList"></div>
	</div>
</body>
</html>
<script type="text/javascript">
	var currentPage = 1;
	var opts_viewGrid_statistics = null;
	var opts_viewGrid_top = null;
	var opts_page = null;
	var headDataStatistics = {
		"statType" : {
			"title" : "<spring:message code='statistics.item'/>",
			"width" : "25%"
		},
		"spaceUsed" : {
			"title" : "<spring:message code='statistics.capacity'/>",
			"width" : "25%"
		},
		"fileCount" : {
			"title" : "<spring:message code='statistics.file'/>",
			"width" : "25%"
		},
		"spaceCount" : {
			"title" : "<spring:message code='statistics.quantity'/>",
			"width" : "auto"
		}
	};
	var headDataTopTen = {
			"num" : {
				"title" : "<spring:message code='user.manager.order'/>",
				"width" : "8%",
				"cls" : "ac"
			},
			"name" : {
				"title" : "<spring:message code='user.manager.name'/>",
				"width" : "auto"
			},
			"description" : {
				"title" : "<spring:message code='user.manager.userdescription'/>",
				"width" : "20%"
			},
			"status" : {
				"title" : "<spring:message code='common.status'/>",
				"width" : "10%"
			},
			"regionId" : {
				"title" : "<spring:message code='user.manager.region'/>",
				"width" : "15%"
			},
			"spaceUsed" : {
				"title" : "<spring:message code='user.manager.usedSpace'/>",
				"width" : "15%"
			},
			"spaceQuota" : {
				"title" : "<spring:message code='user.manager.spaceQuota'/>",
				"width" : "15%"
			}
		};
	$(document).ready(
			function() {
				opts_viewGrid_top = $("#statisList").comboTableGrid({
					headData : headDataStatistics,
					dataId : "id"
				});
				
				opts_viewGrid_statistics = $("#rankList").comboTableGrid({
					headData : headDataTopTen,
					defaultTaxis : "spaceUsed",
					height : 450,
					dataId : "id"
				});
					initDataList();
				});
				
				$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
					switch (colIndex) {
					case "num":
						try {
							var index = tdItem.parent().parent().find("tr").index(tdItem.parent());
							tdItem.find("p").html(index+1);
						} catch (e) {
						}
						break;
					case "statType":
						try {
							if (rowData.id == 0) {
								tdItem.find("p").html("<spring:message code='user.manager.userSpace'/>");
							}
							if (rowData.id == 1) {
								tdItem.find("p").html("<spring:message code='teamSpace.title.teamSpace'/>");
							}
							if (rowData.id == 2) {
								tdItem.find("p").html("<spring:message code='statistics.amount'/>");
							}
						} catch (e) {
						}
						break;
					case "fileCount":
						try {
							var _txt = tdItem.find("p").text();
							tdItem.find("p").html(_txt).parent().attr("title",_txt);
						} catch (e) {
						}
						break;
					case "spaceUsed":
						try {
							var size = tdItem.find("p").text();
							var _txt = formatFileSize(size);
							tdItem.find("p").html( _txt).parent().attr("title",_txt);
						} catch (e) {
						}
						break;
					case "spaceCount":
						try {
							var _txt = tdItem.find("p").text();
							tdItem.find("p").html(_txt).parent().attr("title",_txt);
						} catch (e) {
						}
						break;
					case "status":
						try {
							var status = tdItem.find("p").text();
							if (status == "0") {
								tdItem.find("p").html("<spring:message code='user.manager.enabled'/>").parent().attr("title","<spring:message code='user.manager.enabled'/>");
							}
							if (status == "1") {
								tdItem.find("p").html("<spring:message code='user.manager.disabled'/>").parent().attr("title","<spring:message code='user.manager.disabled'/>");
							}
						} catch (e) {
						}
						break;
					case "regionId":
						try {
							var size = tdItem.find("p").text();
							if (size == -1) {
								tdItem.find("p").html("<spring:message code='user.manager.regionParam'/>").parent().attr("title","<spring:message code='user.manager.regionParam'/>");
							}
							else{
								for ( var i = 0; i < regionData.length; i++) {
									if (size == regionData[i].id) {
										tdItem.find("p").html(regionData[i].name).parent().attr("title",regionData[i].name);
										break;
									}
								}
							}
						} catch (e) {
						}
						break;
					case "spaceQuota":
						try {
							var size = tdItem.find("p").text();
							var _txt = formatFileSize(size);
							tdItem.find("p").html(_txt).parent().attr(
									"title", _txt);
							if (size == "-1") {
								tdItem.find("p").html("<spring:message code='user.manager.unlimited'/>").parent().attr("title","<spring:message code='user.manager.unlimited'/>");
							}
						} catch (e) {
						}
						break;
					default:
						break;
					}
				}
			
	function initDataList(curPage) {
		var statistics_url = "${ctx}/enterprise/admin/statistics/list/<c:out value='${appId}'/>";
		var top_ten_url = "${ctx}/enterprise/admin/statistics/rank/<c:out value='${appId}'/>";
		var StatisticsParams = {
			"pageNumber" : 1,
			"token" : "<c:out value='${token}'/>"
		};
		var TopTenParams = {
				"page" : 1,
				"field": "spaceUsed",
				"limit":10,
				"direction":"DESC",
				"token" : "<c:out value='${token}'/>"
			};

		$.ajax({
			type : "POST",
			url : statistics_url,
			data : StatisticsParams,
			error : function(request) {
				handlePrompt("error",'<spring:message code="operation.failed" />');
			},
			success : function(data) {
				$("#statisList").setTableGridData(data, opts_viewGrid_top);
			}
		});
		
		$.ajax({
			type : "POST",
			url : top_ten_url,
			data : TopTenParams,
			error : function(request) {
				handlePrompt("error",'<spring:message code="operation.failed" />');
			},
			success : function(data) {
				catalogData = data.data;
				regionData = data.restRegionInfo;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid_statistics);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}
</script>