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
		<div class="clearfix control-group">
		<a  class="return btn btn-small pull-right" href="${ctx}/enterprise/security/listNetRegion/<c:out value='${appId}'/>/"><i class="icon-backward"></i>&nbsp;<spring:message code='common.back'/></a>
		<h5 class="pull-left" style="margin: 3px 0 0 4px;"><a href="${ctx}/enterprise/security/listNetRegion/<c:out value='${appId}'/>/"><spring:message code='security.net.region.manage'/></a>&nbsp;>&nbsp;IP</h5>	
	</div>
	    	<div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code='common.create'/></button>
	    	<button type="button" class="btn btn-primary" onClick="deleteNetRegionIp()"><i class="icon-plus"></i><spring:message code='common.delete'/></button>
	    </div>

		<div class="clearfix control-group">
			
		</div>
		<div id="netRegionIpList"></div>
		
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
	"ipStart" : {
		"title" : "<spring:message code='network.region.start.ip'/>",
		"width" : "50%"
	},
	"ipEnd" : {
		"title" : "<spring:message code='network.region.end.ip'/>",
		"width" : "50%"
	}
};

var pageOpts = $("#page").comboPage({
	style : "page"
});



$(document).ready(
		function() {
			opts_viewGrid_top = $("#netRegionIpList").comboTableGrid({
				headData : headDataStatistics,
				dataId : "id",
				checkBox : true
			});
			
			$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
				switch (colIndex) {
					case "modifiedAt":
					try {
						tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
						break;
					} catch (e) {}
					break;
				}
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				initDataList(curPage)
			}
			
			initDataList(1);
			});


		
function initDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listNetRegionIp/<c:out value='${appId}'/>/?id=<c:out value='${id}'/>";
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
			$("#netRegionIpList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createNetRegionIp/<c:out value="${appId}"/>/?id=<c:out value="${id}"/>',width:700,height:440,title:'<spring:message code="network.region.create.title"/>', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreate});
	top.ymPrompt_addModalFocus("#btnCreate");
}

function doCreate(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
}

function deleteNetRegionIp(){
	var idArray = $("#netRegionIpList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="common.select.none.notice"/>');
		return;
	}

	var ids = idArray.join(",");
	top.ymPrompt.confirmInfo( {
		title : '<spring:message code="network.region.ip.delete.title"/>',
		message : '<spring:message code="network.region.ip.delete.title"/>',
		width:450,
		closeTxt:'<spring:message code="common.close"/>',
		handler : function(tp) {
			if(tp == "ok"){
				var url="${ctx}/enterprise/security/deleteNetRegionIp/<c:out value='${appId}'/>/";
				$.ajax({
			        type: "POST",
			        url:url,
			        data:{ids:ids,token:"${token}"},
			        error: function(request) {
			        	top.handlePrompt("error",'<spring:message code="common.modifyFail"/>');
			        },
			        success: function() {
			        	top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
			        	window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
			        }
			    });	
			}
		},
		btn: [['<spring:message code="common.OK"/>', "ok"],['<spring:message code="common.cancel"/>', "cancel"]]
	});
}

</script>
</html>
