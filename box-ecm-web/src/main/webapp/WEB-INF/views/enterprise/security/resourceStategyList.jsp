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
	<div class="form-con clearfix">
		<span id="switchButton" class="pull-right"></span>
		<div class="pull-left">
			<p><strong><spring:message code="accessconfig.switch.title" /></strong></p>
			<p class="help-block"><spring:message code="upload.security.level.rule.desc" /></p>
		</div>
	</div>
	
	<div class="sys-content">
	    	<div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code="common.create"/></button>
	    </div>
		<div class="clearfix control-group">
			
		</div>
		<div id="resourceStrategyList"></div>
		
		<div id="page"></div>
		
		<div id="listaaa"></div>
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
	"resourceTypeName" : {
		"title" : "<spring:message code='security.resource.safe.level'/>",
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



$(document).ready(
		function() {
			opts_viewGrid_top = $("#resourceStrategyList").comboTableGrid({
				headData : headDataStatistics,
				dataId : "id"
			});
			
			$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
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
							var alink = '<a href="javascript:modify('+rowData.id+')"><spring:message code='common.modify'/></a>'+'&nbsp;';
							alink += '<a href="javascript:deleteResourceStrategy('+rowData.id+')"><spring:message code='common.delete'/></a>';
							tdItem.find("p").html(alink);
						} catch (e) {}
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
	var statistics_url = "${ctx}/enterprise/security/listResourceStrategy/<c:out value='${appId}'/>/";
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
			$("#resourceStrategyList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createResourceStrategy/<c:out value="${appId}"/>/',width:700,height:440,title:'<spring:message code="upload.security.level.create"/>', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreate});
	top.ymPrompt_addModalFocus("#btnCreate");
}
function modify(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifyResourceStrategy/<c:out value="${appId}"/>/?id='+id,width:700,height:440,title:'<spring:message code="upload.security.level.modify"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doModify});
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

function deleteResourceStrategy(id){
		var url="${ctx}/enterprise/security/deleteResourceStrategy/<c:out value='${appId}'/>/";
		$.ajax({
	        type: "POST",
	        url:url,
	        data:{id:id,"token" : "${token}"},
	        error: function(request) {
	        	top.handlePrompt("error",'<spring:message code="common.has.been.used"/>');
	        },
	        success: function() {
	        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
	        	window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
	        }
	    });	
}

</script>
</html>
