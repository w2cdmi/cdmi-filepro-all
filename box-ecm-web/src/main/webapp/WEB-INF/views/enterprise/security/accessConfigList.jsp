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
<form id="form1" action="">
<input type="hidden" id="configSwitch" name="configSwitch" />
<input type="hidden" id="token" name="token" value="${token}"/>
</form>
<div class="sys-content">
	<div class="form-con clearfix">
		<span id="switchButton" class="pull-right"></span>
		<div class="pull-left">
			<p><strong><spring:message code="accessconfig.switch.title" /></strong></p>
			<p class="help-block"><spring:message code="accessconfig.switch.description" /></p>
		</div>
	</div>
		<div class="clearfix">
		    	<div class="pull-left">
		    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code="common.create"/></button>
		    </div>
		    <form id="searchForm" class="pull-right form-search">
	                <select class="span3" id="safeRoleId" name="safeRoleId">
	                <option value="-1"><spring:message code="security.role.any"/></option>
	       		<c:forEach items="${safeRoleList}" var="oper">
	       			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
	       		</c:forEach>
				</select>
	                <select class="span3" id="netRegionId" name="netRegionId">
	                <option value="-1"><spring:message code="network.region.any"/></option>
	       		<c:forEach items="${netRegionList}" var="oper">
	       			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.netRegionName}'/></option>
	       		</c:forEach>
				</select>
				<button type="button" class="btn" onClick="search()"><spring:message code="common.search"/></button>
				<input type="hidden" id="token" name="token" value="${token}"/>
		    </form>
		</div>
		<div class="table-con">
			<div id="accessConfigList"></div>
			<div id="page"></div>
		</div>
</div>
</body>
<script type="text/javascript">

var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_top = null;
var opts_page = null;
var headDataStatistics = {
		"safeRoleName" : {
			"title" : "<spring:message code='accessconfig.saferolename'/>",
			"width" : ""
		},
		"netRegionName" : {
			"title" : "<spring:message code='accessconfig.netregionname'/>",
			"width" : ""
		},
		"downLoadResrouceTypeIds" : {
			"title" : "<spring:message code='accessconfig.download.resource.type'/>",
			"width" : ""
		},
		"previewResourceTypeIds" : {
			"title" : "<spring:message code='accessconfig.preview.resource.type'/>",
			"width" : ""
		},
		"modifiedAt" : {
			"title" : "<spring:message code='common.updateTime'/>",
			"width" : ""
		},
		"operate" : {
			"title" : "<spring:message code='common.operation'/>",
			"width" : ""
		}
};

var pageOpts = $("#page").comboPage({
	style : "page"
});



$(document).ready(function() {
			opts_viewGrid_top = $("#accessConfigList").comboTableGrid({
				headData : headDataStatistics,
				dataId : "id"
			});
			
			$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
				switch (colIndex) {
					case "createdAt":
					tdItem.find("p").text(getLocalTime(rowData.createdAt));
					break;
					case "modifiedAt":
						tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
						tdItem.attr("title",getLocalTime(rowData.modifiedAt));
						break;
					case "operate":
						var alink = '<a href="javascript:modify('+rowData.id+')"><spring:message code="space.button.modify"/></a>'+"&nbsp;"+'<a href="javascript:delConfig('+rowData.id+')"><spring:message code='space.button.delete'/></a>';
						tdItem.find("p").html(alink);
						break;
					default : 
						break;
				}
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				initDataList(curPage)
			}
			getAccessConfigSwitch();
			initDataList(currentPage);
			
		});


function getAccessConfigSwitch(){
	$.ajax({
		type : "POST",
		url : "${ctx}/enterprise/security/listAccessConfigSwitch/<c:out value='${appId}'/>/",
		data : $('#form1').serialize(),
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			var switchFlag = false;
			if(data.enableFileSec=="1"){
				switchFlag = true;
			}else{
				switchFlag = false;
			}
			
			var switchOpts = $("#switchButton").comboSwitchButton({
				onText : "<spring:message code='accessconfig.opened' />",
				offText : "<spring:message code='accessconfig.closed' />",
				defaultSwitchOn : switchFlag,
				onEvent: function(){
					$("#configSwitch").val("enable");
					var url = "${ctx}/enterprise/security/changeAccessConfigSwitch/<c:out value='${appId}'/>/";
					$.ajax({
						type : "POST",
						url : url,
						data : $('#form1').serialize(),
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
					var url = "${ctx}/enterprise/security/changeAccessConfigSwitch/<c:out value='${appId}'/>/";
					$.ajax({
						type : "POST",
						url : url,
						data : $('#form1').serialize(),
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
	});
	
}		
		
function initDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listAccessConfig/<c:out value='${appId}'/>/";
	var StatisticsParams = {
		"pageNumber" : curPage,
		"token" : "${token}"
	};
	$.ajax({
		type : "POST",
		url : statistics_url,
		data : StatisticsParams,
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#accessConfigList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createAccessConfig/<c:out value="${appId}"/>/',width:700,height:440,title:'<spring:message code="accessconfig.create.title"/>', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreate});
	top.ymPrompt_addModalFocus("#btnCreate");
}
function modify(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifyAccessConfig/<c:out value="${appId}"/>/?id='+id,width:700,height:440,title:'<spring:message code="accessconfig.modify.title"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doModify});
	top.ymPrompt_addModalFocus("#btnModify");
}
function doModify(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModify();
	} else {
		top.ymPrompt.close();
	}
}

function doCreate(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
}

function search(){
	var statistics_url = "${ctx}/enterprise/security/listAccessConfig/<c:out value='${appId}'/>/";
	var StatisticsParams = {
		"pageNumber" : 1,
		"token" : "${token}"
	};
	$.ajax({
		type : "POST",
		url : statistics_url,
		data : $('#searchForm').serialize(),
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#accessConfigList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}


function delConfig(id){
	var delUrl = "${ctx}/enterprise/security/deleteAccessConfig/<c:out value='${appId}'/>";
	var params ={
			"id":id,
			"token" : "${token}"
	};
	$.ajax({
		type:"POST",
		url:delUrl,
		data:params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.delete.failed" />');
		},
		success : function(data) {
			handlePrompt("success",'<spring:message code="common.delete.success" />');
			initDataList(1);
		}
	});
}
	

</script>
</html>
