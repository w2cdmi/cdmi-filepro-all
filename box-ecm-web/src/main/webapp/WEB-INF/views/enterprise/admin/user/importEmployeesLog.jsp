<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%
    request.setAttribute("token",CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/popCommon.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
</head>
<body>
	<div class="sys-content">
	<div class="clearfix">
		<form id="importUserForm" class="form-horizontal" enctype="multipart/form-data" method="post" action="${ctx}/import/enterprise/admin/user/importEmployee/${authServerId}">
			 <input type="hidden" name="token" value="${token}"/>
				<div class="control-group">
					<input type="file" id="fileName" width="50px;" name="versionFile">
		   	        <button type="button" class="btn btn-primary" onClick="submitImportUserCsvFileUpload()"><spring:message code="common.import"/></button>
					<button type="button" class="btn btn-link" onClick="downloadEmployeeModelFile()" id="downloadEmployeeModelFileBtn"><spring:message code="user.manager.exceldownload"/></button>
				</div>   
			<div class="clearfix">
			    <div class="pull-right form-search">
			            <input type="hidden" id="page" name="page" value="1">
			            
			            <div class="input-append">                   
			              <input type="text" id="filter" name="filter" class="span3 search-query" placeholder='<spring:message code="import.log.content"/>' />
			              <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
			            </div>
			    </div>
   			</div>
		   </form>
		</div>
	    <div class="table-con">
				<div id="logList"></div>
				<div id="logListPage"></div>
		</div>
	</div>

<script type="text/javascript">
var newHeadItem = "";
var newFlag = false;
var currentPage = 1;
var opts_viewGrid = null;
var opts_page = null;
var headData = {
	"createTime" : {
		"title" : '<spring:message code="import.date"/>',
		"width" : "200px",
		"taxis":true
	},
	"operatDesc" : {
			"title" : '<spring:message code="import.log.details"/>',
			"width" : "auto"
		},
	"level" : {
		"title" : '<spring:message code="common.import.result"/>',
		"width" : "100px"
	}
};
$(document).ready(function() {
	opts_viewGrid = $("#logList").comboTableGrid({
		headData : headData,
//		height : 210,
		dataId : "id"
	});

	$.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
		switch (colIndex) {
		case "createTime":
			try {
				var size = tdItem.find("p").text();
				for ( var i = 0; i <catalogData.length; i++) {
					if(size == catalogData[i].createTime){
						_txt = catalogData[i].createTime;
						var date = new Date(_txt);
						var _year = date.getFullYear();
						var  _month = date.getMonth()+1;
						if(_month<10){
							_month = "0"+_month;
						}
						var _day = date.getDate();
						if(_day<10){
							_day = "0"+_day;
						}
						var _hours = date.getHours();
						if(_hours<10){
							_hours = "0"+_hours;
						}
						var _min = date.getMinutes();
						if(_min<10){
							_min = "0"+_min;
						}
						var _sec = date.getSeconds();  
						if(_sec<10){
							_sec = "0"+_sec;
						}
						var date = _year+"-"+_month+"-"+_day+" "+_hours+":"+_min+":"+_sec;
						tdItem.find("p").html(date).parent().attr("title", date);
					}
				}
			} catch (e) {
			}
			break;
		case "description":
			try {
				var status = tdItem.find("p").text();
			} catch (e) {
			}
			break;
		case "level":
			try {
				var status = tdItem.find("p").text();
				if (status == 0) {
					tdItem.find("p").html("<spring:message code='common.success'/>").parent().attr("title","<spring:message code='common.success'/>");
				}
				if (status == 1) {
					tdItem.find("p").html("<label class='public_red_font'><spring:message code='common.failed'/></label>").parent().attr("title","<spring:message code='common.failed'/>");
				}
			} catch (e) {
			}
			break;
		default:
			break;
		}
	};

	$.fn.comboTableGrid.taxisOp = function(headItem, flag) {
		initDataList(currentPage, headItem, flag);
	};

	opts_page = $("#logListPage").comboPage({
		style : "page table-page",
		lang : '<spring:message code="main.language"/>'
	});

	$.fn.comboPage.pageSkip = function(opts, _idMap, curPage) {
		initDataList(curPage, newHeadItem, newFlag);
	};
	
	initDataList(currentPage, newHeadItem, newFlag);
	
	if (!placeholderSupport()) {
		placeholderCompatible();
	}
	
	$("#searchButton").on("click",function(){
		initDataList(currentPage, newHeadItem, newFlag);
	});	
	
	$("#filter").keydown(function(){
		var evt = arguments[0] || window.event;
		if(evt.keyCode == 13){
			initDataList(currentPage, newHeadItem, newFlag);
			if(window.event){
				window.event.cancelBubble = true;
				window.event.returnValue = false;
			}else{
				evt.stopPropagation();
				evt.preventDefault();
			}
		}
	});
});


function initDataList(curPage, headItem, flag) {
	currentPage = curPage;
	newHeadItem = headItem;
	newFlag = flag;
	var url = "${ctx}/import/enterprise/admin/user/logList";
	var filter = $("#filter").val();
	
	var params = {
		"page" : curPage,
		"filter" : filter,
		"token" : "${token}",
		"newHeadItem":newHeadItem,
		"newFlag":newFlag
	};
	$("#logList").showTableGridLoading();
	$.ajax({
		type : "POST",
		url : url,
		data : params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
		},
		success : function(data) {
			catalogData = data.content;
			$("#logList").setTableGridData(catalogData, opts_viewGrid);
			$("#logListPage").setPageData(opts_page, data.number,data.size, data.totalElements);
			var pageH = $("body").outerHeight();
			iframeAdaptHeight(pageH);
		}
	});
}


function submitImportUserCsvFileUpload()
{
	var fileFullName = $("#fileName").val();
	if(fileFullName == '' || fileFullName == null)
	{
		handlePrompt("error",'<spring:message code="importUser.fileEmpty"/>');
		return false;
	}
	var fileName = fileFullName.substring(fileFullName.lastIndexOf("\\")+1,fileFullName.length);
	if(fileName.indexOf(".") == -1){
		handlePrompt("error","<spring:message code='importUser.format.excel.err'/>");
		return false;
	}
	var fileSuffix = fileName.substring(fileName.lastIndexOf(".")+1,fileName.length);
	if(fileSuffix != "xls" && fileSuffix != "xlsx"){
		handlePrompt("error","<spring:message code='importUser.format.excel.err'/>");
		return false;
	}
	else
	{
		ymPrompt_disableModalbtn("#btn-focus");
		var $form = $("#importUserForm");
//		$("#importUserForm").submit();
		$.ajax({
			type: "POST",
			url: $form.attr("action"),
			cache: false,
			data: new FormData($form[0]),
			processData: false,
			contentType: false,
			error: function (request, textStatus) {
				var status = request.status;
				if (status == 409) {
					handlePrompt("error", '<spring:message code="createEnterprise.conflict.name.email"/>');
				} else {
					if(request.responseText != "") {
						handlePrompt("error", request.responseText);
					} else {
						handlePrompt("error", '<spring:message code="importUser.dateFailed"/>');
					}
				}
			},
			success: function (html) {
				handlePrompt("success", '<spring:message code="importUser.dateSucceed"/>');
				initDataList(currentPage, newHeadItem, newFlag);
			}
		});
	}
}

function downloadEmployeeModelFile()
{
	if(isIeBelow11()){
		ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.download.excel.file" />'});
		window.location="${ctx}/enterprise/admin/user/employeeInfoTemplateFile";
	}else{
		window.location="${ctx}/enterprise/admin/user/employeeInfoTemplateFile";
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