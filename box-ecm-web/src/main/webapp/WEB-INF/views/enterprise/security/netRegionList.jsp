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
</head>
<body>
<div class="sys-content">
	<div  class="clearfix">
	    <div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code='common.new'/></button>
	    	<button type="button" class="btn btn-primary" onClick="importNetRegionIp()"><i class="icon-plus"></i><spring:message code='common.import'/></button>
	    	<button type="button" class="btn btn-primary" onClick="exportRegionIpList()"><i class="icon-plus"></i><spring:message code='common.export.ip'/></button>
	    </div>
	</div>

	<div class="table-con">
		<div id="netRegionList"></div>
		<div id="page"></div>
	</div>
</div>
</body> 

  
<script>

var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_topNetRegion = null;
var opts_page = null;
var headNetRegionDataStatistics = {
	"netRegionName" : {
		"title" : "<spring:message code='common.name'/>",
		"width" : "25%"
	},
	"netRegionDesc" : {
		"title" : "<spring:message code='common.description'/>",
		"width" : "25%"
	},
	"modifiedAt" : {
		"title" : "<spring:message code='common.updateTime'/>",
		"width" : "25%"
	},
	"operate" : {
		"title" : "<spring:message code='common.operation'/>",
		"width" : "25%"
	}
};

var pageOptsNetRegion = $("#pageNetRegion").comboPage({
	style : "page"
});

$(document).ready(
		function() {
			opts_viewGrid_topNetRegion = $("#netRegionList").comboTableGrid({
				headData : headNetRegionDataStatistics,
				dataId : "id"
			});
			
			$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex,_idMap){
				if(_idMap.pluginId=="netRegionList") {
					switch (colIndex) {
						case "modifiedAt":
						try {
							tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
							tdItem.attr("title",getLocalTime(rowData.modifiedAt));
							break;
						} catch (e) {}
						break;
						
						case "operate":
							try {
								var alink = '<a href="javascript:modifyNetRegion('+rowData.id+')"><spring:message code='common.modify'/></a>'+'&nbsp;';
								alink += '<a href="javascript:deleteNetRegion('+rowData.id+')"><spring:message code='common.delete'/></a>';
								tdItem.find("p").html(alink);
							} catch (e) {}
							break;
						default : 
							break;
					}
				}
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				if(_idMap.pluginId=="pageNetRegion") {
					initNetRegionDataList(curPage);
				};
			};
			
			initNetRegionDataList(currentPage);
		}
);


		
function initNetRegionDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listNetRegion/<c:out value='${appId}'/>/";
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
			$("#netRegionList").setTableGridData(data.content, opts_viewGrid_topNetRegion);
			$("#pageNetRegion").setPageData(pageOptsNetRegion, data.number, data.size, data.totalElements);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createNetRegion/<c:out value="${appId}"/>/',width:700,height:440,title:'<spring:message code="network.region.add"/>', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreateNetRegion});
	top.ymPrompt_addModalFocus("#btnCreate");
}
function modifyNetRegion(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifyNetRegion/<c:out value="${appId}"/>/?id='+id,width:700,height:440,title:'<spring:message code="network.region.update"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doModifyNetRegion});
	top.ymPrompt_addModalFocus("#btnModify");
}
function doModifyNetRegion(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModify();
	} else {
		top.ymPrompt.close();
	}
}

 function config(id){
	location.href="${ctx}/enterprise/security/listNetRegionIp/<c:out value='${appId}'/>/?id="+id
} 

function doCreateNetRegion(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
}
function importNetRegionIp() {
	var url = "${ctx}/enterprise/security/enterImportNetRegionIp/<c:out value='${appId}'/>/";
	top.ymPrompt.win({
		message : url,
		width : 900,
		height : 530,
		title : '<spring:message code="network.region.import"/>',
		iframe : true,
		btn : [
				[ '<spring:message code="common.close"/>', 'close', false,
						"btn-focus" ] ],
		handler : uploadImportUserCsvFile
	});
	top.ymPrompt_addModalFocus("#btn-focus");
}
function uploadImportUserCsvFile(tp) {
	if (tp == "ok") {
		top.ymPrompt.getPage().contentWindow
				.submitImportUserCsvFileUpload();
	} else {
		top.ymPrompt.close();
	}
}
function exportRegionIpList() {
	if(isIeBelow11()){
		top.ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.download.excel.file" />'});
		window.location = "${ctx}/enterprise/security/export/<c:out value='${appId}'/>/";
		return;
	}else{
		window.location = "${ctx}/enterprise/security/export/<c:out value='${appId}'/>/";
	}
}

function isIeBelow11(){
	if(navigator.userAgent.indexOf("MSIE") < 0) {
		return false;
	}else if(navigator.userAgent.indexOf("MSIE 10.0") >= 0) {
		return true;
	}else if(navigator.userAgent.indexOf("MSIE 9.0") >= 0) {
		return true;
	}else if(navigator.userAgent.indexOf("MSIE 8.0") >= 0) {
		return true;
	}else if(navigator.userAgent.indexOf("MSIE 7.0") >= 0) {
		return true;
	}else{
		return false;
	}
}

function deleteNetRegion(id){
	top.ymPrompt.confirmInfo( {
		title : '<spring:message code="network.region.delete.title"/>',
		message : '<spring:message code="network.region.delete.title"/>',
		width:450,
		closeTxt:'<spring:message code="common.close"/>',
		handler : function(tp) {
			if(tp == "ok"){
				var url="${ctx}/enterprise/security/deleteNetworkRegion/<c:out value='${appId}'/>/";
				$.ajax({
			        type: "POST",
			        url:url,
			        data:{
			        	id:id,
			        	token:"${token}"
			        	},
			        error: function(request) {
			        	top.handlePrompt("error",'<spring:message code="common.has.been.used"/>');
			        },
			        success: function() {
			        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
			        	window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
			        }
			    });	
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}

function search(){
	var statistics_url = "${ctx}/enterprise/security/listNetRegion/<c:out value='${appId}'/>/";
	var StatisticsParams = {
		"page" : 1
	};
	$.ajax({
		type : "POST",
		url : statistics_url,
		data : $('#searchForm').serialize(),
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#netRegionList").setTableGridData(data.content, opts_viewGrid_topNetRegion);
			$("#pageNetRegion").setPageData(pageOptsNetRegion, data.number, data.size, data.totalElements);
		}
	});
}
</script> 
</html>
