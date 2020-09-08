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
    	<div class="clearfix">
    		<ul class="nav nav-tabs">
                 <li class="active"><a href="#none" id="enterpriseManageTabId" onClick="top.openInframe('', '${ctx}/enterprise/security/list/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='security.role.manage'/></a></li>
				<li><a href="#none" id="accessSpaceTabId" onClick="top.openInframe('', '${ctx}/enterprise/space/listAccessConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='space.access.config'/></a></li>
                 <li><a href="#none" id="fileCopyTabId" onClick="top.openInframe('', '${ctx}/enterprise/fileCopy/listConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='fileCopy.access.config'/></a></li>
             </ul>
    	</div>
        <div class="clearfix control-group">
            <h4 class="pull-left"><spring:message code='user.type'/></h4>
        </div>
        <div class="pull-left">
            <button type="button" class="btn btn-primary" onClick="createEnterprise()" ><i class="icon-plus"></i><spring:message code='common.new'/></button>
        </div>
        <div class="clearfix control-group">
        </div>
        <div id="securityRoleList"></div>
        <div id="page"></div>
    </div>
    
    <div class="sys-content">
        <div class="clearfix control-group">
            <h4 class="pull-left" ><spring:message code='net.type'/></h4>
        </div>
        <div  class="clearfix">
            <div class="pull-left">
                <button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code='common.new'/></button>
                <button type="button" class="btn" onClick="importNetRegionIp()"><spring:message code='common.import'/></button>
                <button type="button" class="btn" onClick="exportRegionIpList()"><spring:message code='common.export.ip'/></button>
            </div>
        </div>

        <div class="table-con">
            <div id="netRegionList"></div>
            <div id="pageNetRegion"></div>
        </div>
	</div>

    <div class="sys-content">
        <div class="clearfix control-group">
            <h4><spring:message code='file.type'/></h4>
            <p class="help-block"><spring:message code='file.type.help'/></p>
        </div>
        <div class="pull-left">
            <button type="button" class="btn btn-primary" onClick="createFileType()"><i class="icon-plus"></i><spring:message code='common.new'/></button>
        </div>
        <div class="clearfix control-group">
        </div>
        <div id="securityDocumentList"></div>
        <div id="page3"></div>
    </div> 
</body>
<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_top = null;
var opts_page = null;
var headDataStatistics = {
	"roleName" : {
		"title" : "<spring:message code='common.name'/>",
		"width" : "25%"
	},
	"roleDesc" : {
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

var pageOpts = $("#page").comboPage({
	style : "page"
});

var opts_viewGrid_top2=null;
var fileTypeCurrentPage = 1;
var pageOpts3 = $("#page3").comboPage({
	style : "page"
});

var headDataStatisticsFileType = {
		"safeLevelName" : {
			"title" : "<spring:message code='common.name'/>",
			"width" : ""
		},
		"safeLevelDesc" : {
			"title" : "<spring:message code='common.description'/>",
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

var opts_viewGrid_topNetRegion = null;
var pageOptsNetRegion = $("#pageNetRegion").comboPage({
	style : "page"
});
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


$(document).ready(
        function() {
            opts_viewGrid_top = $("#securityRoleList").comboTableGrid({
                headData : headDataStatistics,
                dataId : "id"
         	});
            
           opts_viewGrid_top2 = $("#securityDocumentList").comboTableGrid({
               headData : headDataStatisticsFileType,
               dataId : "id"
           });
           
           opts_viewGrid_topNetRegion = $("#netRegionList").comboTableGrid({
				headData : headNetRegionDataStatistics,
				dataId : "id"
			});
           
         $.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex,_idMap){
        	 if(_idMap.pluginId=="securityRoleList") {
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
							var alink = '<a href="javascript:modify('+rowData.id+')"><spring:message code='common.update'/></a>'+'&nbsp;';
							alink += '<a href="javascript:deleteSecurityRole('+rowData.id+')"><spring:message code='common.delete'/></a>';
							tdItem.find("p").html(alink);
						} catch (e) {}
						break;
					default : 
						break;
				}
        	 }else if(_idMap.pluginId=="netRegionList") {
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
			}else if(_idMap.pluginId=="securityDocumentList") {
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
							var alink = '<a href="javascript:modifyFileType('+rowData.id+')"><spring:message code='common.modify'/></a>'+'&nbsp;';
							alink += '<a href="javascript:deleteSafeLevel('+rowData.id+')"><spring:message code='common.delete'/></a>';
							tdItem.find("p").html(alink);
						} catch (e) {}
						break;
					default : 
						break;
				}
        	 }
				
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				if(_idMap.pluginId=="page") {
					initDataList(curPage)
				}else if(_idMap.pluginId=="page3") {
					initFileTypeDataList(curPage)
				}else if(_idMap.pluginId=="pageNetRegion") {
					initNetRegionDataList(curPage)
				}
			}
			
			initDataList(currentPage);
			initFileTypeDataList(fileTypeCurrentPage);
			initNetRegionDataList(currentPage);
});

function initDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/list/<c:out value='${appId}'/>/";
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
			$("#securityRoleList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
			var pageH = $("body").outerHeight();
            top.iframeAdaptHeight(pageH);
		}
	});
}


function createEnterprise(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createSecurityRole/<c:out value="${appId}"/>/',width:700,height:440,title:'<spring:message code="security.role.create"/>', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreateEnterprise});
	top.ymPrompt_addModalFocus("#btnCreate");
}

function modify(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifySecurityRole/<c:out value="${appId}"/>/?id='+id,width:700,height:440,title:'<spring:message code='security.role.modify'/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doModify});
	top.ymPrompt_addModalFocus("#btnModify");
}
function doModify(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModifyAdminUser();
	} else {
		top.ymPrompt.close();
	}
}

function doCreateEnterprise(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
}

function back(){
	top.window.location.href="${ctx}/enterprise/admin/appManage";
}

function deleteSecurityRole(id){
	var postParams = {
			"id" : id,
			"token" : "${token}"
		};
	top.ymPrompt.confirmInfo( {
		title : '<spring:message code="security.role.delete.title"/>',
		message : '<spring:message code="security.role.delete.desc"/>',
		width:450,
		closeTxt:'<spring:message code="common.close"/>',
		handler : function(tp) {
			if(tp == "ok"){
				var url="${ctx}/enterprise/security/deleteSecurityRole/<c:out value='${appId}'/>/";
				$.ajax({
			        type: "POST",
			        url:url,
			        data:postParams,
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
	var statistics_url = "${ctx}/enterprise/security/list/<c:out value='${appId}'/>/";
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
			$("#securityRoleList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}

function initFileTypeDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listSafeLevel/<c:out value='${appId}'/>/";
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
			$("#securityDocumentList").setTableGridData(data.content, opts_viewGrid_top2);
			$("#page3").setPageData(pageOpts3, data.number, data.size, data.totalElements);
			var pageH = $("body").outerHeight();
            top.iframeAdaptHeight(pageH);
		}
	});
}


function createFileType(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createSafeLevel/<c:out value="${appId}"/>/',width:700,height:440,
		title:'<spring:message code="security.level.create"/>', iframe:true, handler:
			function(tp){
				if(tp=="close"){
					$("body").css("overflow","scroll");
					top.ymPrompt.getPage().contentWindow.deleteCloseNewFileType();
				}
			}
		});
}
 function modifyFileType(id){
	 top.ymPrompt.win({message:'${ctx}/enterprise/security/modifySafeLevel/<c:out value="${appId}"/>/?id='+id,width:700,height:440,
			 title:'<spring:message code="security.level.modify"/>', iframe:true,handler:
				 function(tp){
					if(tp=="close"){
						$("body").css("overflow","scroll");
					}
				}});
	
}
function doModifyFileType(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModifyFileType();
	} else {
		top.ymPrompt.close();
	}
} 

function deleteSafeLevel(id){
	top.ymPrompt.confirmInfo( {
	title : '<spring:message code="security.fileType.delete.title"/>',
	message : '<spring:message code="security.fileType.delete.desc"/>',
	width:450,
	closeTxt:'<spring:message code="common.close"/>',
	handler : function(tp) {
		if(tp == "ok"){
			var url="${ctx}/enterprise/security/deleteSafeLevel/<c:out value='${appId}'/>/";
			$.ajax({
		        type: "POST",
		        url:url,
		        data:{id:id,"token" : "${token}"},
		        error: function(request, textStatus, errorThrown) {
		        	if(request.status==403){
		        		top.handlePrompt("error",'<spring:message code="common.has.been.used"/>');
		        	}else{
		        		top.handlePrompt("error",'<spring:message code="operation.failed"/>');
		        	}
		        },
		        success: function() {
		        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
		        	window.parent.document.getElementById('systemFrame').contentWindow.initFileTypeDataList(1);
		        }
		    });
		}
	},
	btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}

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
			var pageH = $("body").outerHeight();
            top.iframeAdaptHeight(pageH);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createNetRegion/<c:out value="${appId}"/>/',
		width:700,height:500,title:'<spring:message code="network.region.add"/>', iframe:true,handler:
			function(tp){
				if(tp=="close"){
					$("body").css("overflow","scroll");
					top.ymPrompt.getPage().contentWindow.deleteCloseNetRegionIp();
				}
			}
		});
}
function modifyNetRegion(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifyNetRegion/<c:out value="${appId}"/>/?id='+id,width:700,height:500,
			title:'<spring:message code="network.region.update"/>', iframe:true,handler:
				function(tp){
					if(tp=="close"){
						$("body").css("overflow","scroll");
					}
				}
			});
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
	initNetRegionDataList(1);
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
			        	window.parent.document.getElementById('systemFrame').contentWindow.initNetRegionDataList(1);
			        }
			    });	
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}
</script>
</html>
