<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@ include file="../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
</head>
<body>
	<div class="pop-content">
		<form id="importUserForm" class="form-horizontal"
			enctype="multipart/form-data" method="post"
			action="${ctx}/enterprise/security/importNetRegionIp/<c:out value='${appId}'/>/">
			<div class="control-group">
				<div class="controls">
					<input type="file" id="fileName" name="versionFile">
					<button class="btn btn-small" type="button" onClick="submitImportUserCsvFileUpload()"/><spring:message code="user.manager.export"/></button>
					<button type="button" class="btn btn-link" onClick="downloadModelFile()" id="downloadUserModelFileBtn"><spring:message code="user.manager.exceldownload"/></button>
				</div>
			</div>
			<div class="alert"><i class="icon-lightbulb"></i><span id="importInfo"></span></div> 
		<div id="importExcelList"></div>
		
		<div id="page"></div>
		<input type="hidden" id="token" name="token" value="${token}"/>	
		</form>
	</div>

<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_top = null;
var opts_page = null;
var headDataStatistics = {
	"resultStr" : {
		"title" : "<spring:message code='common.import.result'/>",
		"width" : "30%"
	},
	"runtime" : {
		"title" : "<spring:message code='importUser.runtime'/>",
		"width" : "20%"
	},
	"completeTime" : {
		"title" : "<spring:message code='importUser.completeTime'/>",
		"width" : "20%"
	},
	"operate" : {
		"title" : "<spring:message code='common.operate'/>",
		"width" : "25%"
	}
};

var pageOpts = $("#page").comboPage({
	style : "page"
});	


var errMsg = "<c:out value='${errMsg}'/>";
var cycleGetImportResultTimer;
function cycleGetResults(){
	clearTimeout(cycleGetImportResultTimer);
	$.ajax({
        type: "POST", 
        url:"${ctx}/enterprise/security/getImportResult/<c:out value='${appId}'/>/",
        data : $('#importUserForm').serialize(),
        error: function(request) {
        	getResult();
        },
        success: function(data) {
        	if(errMsg==""){
	        	if(data=="importing"){
	        		$("#importInfo").text("<spring:message code='common.importing'/>");
	        		getResult();
	        	}
	        	else{   
	        		$("#importInfo").text("<spring:message code='common.importSuccess'/>");
	        		clearTimeout(cycleGetImportResultTimer);
	        		initDataList();
	        	}
        	}
        }
    });
}


function getResult(){    
	cycleGetImportResultTimer = setTimeout(cycleGetResults,"3000");
}

function getLocalState(status){
	if(status==3){
		return "<spring:message code="importUser.importing"/>";
	}
	if(status==2){
		return "<spring:message code="common.importFail"/>";
	}
	if(status==1){
		return "<spring:message code="common.importSuccess"/>";
	}
} 

$(document).ready(function() {
	
	if(errMsg!=null&&errMsg!=""){
		 if(errMsg=="excelFileSize"){
			$("#importInfo").text("<spring:message code='common.import.max.request'/>");
		}else
		{
			$("#importInfo").text("<spring:message code='common.import.invalid.request'/>");
		}
	}
	var saveState = "<c:out value='${saveState}'/>";
	if(saveState=="conflict"){
		handlePrompt("error",'<spring:message code="common.import.ExistConflictTask" />');
	}
	
	 setTimeout(cycleGetResults,"");
	 opts_viewGrid_top = $("#importExcelList").comboTableGrid({
			headData : headDataStatistics,
			dataId : "id"
		});
		
		$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
			switch (colIndex) {
				case "runtime":
				tdItem.find("p").text(getLocalTime(rowData.runtime));
				tdItem.attr("title",getLocalTime(rowData.runtime));
				break;
				
				case "completeTime":
					if(rowData.completeTime==null){
						tdItem.find("p").text("");
					}else{
						tdItem.find("p").text(getLocalTime(rowData.completeTime));
						tdItem.attr("title",getLocalTime(rowData.completeTime));
					}
					
					break;
					
				case "operate":
					if(rowData.status==1||rowData.status==2){
						var alink = '<a href="javascript:exportExcel('+rowData.id+')"><spring:message code="common.export"/></a>&nbsp;<a href="javascript:deleteImportResult('+rowData.id+')"><spring:message code='common.delete'/></a>';
						tdItem.find("p").html(alink);
					}
					break;
				default : 
					break;
			}
		}
		
		$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
			initDataList(curPage)
		}
		
		initDataList(currentPage);
});

function initDataList(curPage) {
	var url = "${ctx}/enterprise/security/getImportNetRegionIp/<c:out value='${appId}'/>/";
	var StatisticsParams = {
		"pageNumber" : curPage,
		"token" : "${token}"
	};
	$.ajax({
		type : "POST",
		url : url,
		data : StatisticsParams,
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#importExcelList").setTableGridData(data, opts_viewGrid_top);
		}
	});
}

function submitImportUserCsvFileUpload()
{
	var fileName = $("#fileName").val();
	if(fileName == '' || fileName == null)
	{
		handlePrompt("error",'<spring:message code="importUser.fileEmpty"/>');
	}
	var fileSuffix = fileName.substring(fileName.lastIndexOf(".")+1,fileName.length);
	if(fileSuffix != "xlsx"){
		handlePrompt("error","<spring:message code='importUser.format.excel.err'/>");
	}
	
	else
	{
		$("#importUserForm").submit();
	}
}

function deleteImportResult(id) {	
	ymPrompt.confirmInfo( {
		title :'<spring:message code="importUser.delete"/>',
		message : '<spring:message code="importUser.deleteConfirm"/>',
		handler : function(tp) {
			if(tp == "ok"){
				$.ajax({
			        type: "POST", 
			        url:"${ctx}/enterprise/security/deleteImportResult/<c:out value='${appId}'/>/?id="+id,
			        data:{id:id,"token" : "${token}"},
			        error: function(request) {
			        	handlePrompt("error",'<spring:message code="common.deleteFailed"/>');
			        },
			        success: function() {
			        	top.handlePrompt("success",'<spring:message code="importUser.deleteSucceed"/>');
			        	initDataList(1);
			        }
			    });
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}

function downloadModelFile()
{
	if(isIeBelow11()){
		ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.download.excel.file" />'});
		window.location="${ctx}/enterprise/security/netRegionIpTemplateFile?id="+"<c:out value='${id}'/>";
		return;
	}else{
		window.location="${ctx}/enterprise/security/netRegionIpTemplateFile?id="+"<c:out value='${id}'/>";
	}
} 

function  exportExcel(id)
{   
	if(isIeBelow11()){
		ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.download.excel.file" />'});
		window.location="${ctx}/enterprise/security/exportImportExcelResult/<c:out value='${appId}'/>/?id="+id;
		return;
	}else{
		window.location="${ctx}/enterprise/security/exportImportExcelResult/<c:out value='${appId}'/>/?id="+id;
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
</script>
</body>
</html>