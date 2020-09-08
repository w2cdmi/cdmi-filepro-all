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
	    	<div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code="common.create"/></button>
	    </div>
	    
	    	<form id="searchForm" class="pull-right form-search">
               <select class="span3" id="id" name="id">
               <option value="-1"><spring:message code='security.role.any'/></option>
      		<c:forEach items="${safeLevelList}" var="oper">
      			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.safeLevelName}'/></option>
      		</c:forEach>
		</select>
		<button type="button" class="btn" onClick="search()"><spring:message code="common.search"/></button>
		<input type="hidden" id="token" name="token" value="${token}"/>	
    		</form>
	    
		<div class="clearfix control-group">
			
		</div>
		<div id="safeLevelList"></div>
		
		<div id="page"></div>
		
	</div>
</body>
<script type="text/javascript">

var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_top = null;
var opts_page = null;
var headDataStatistics = {
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

var pageOpts = $("#page").comboPage({
	style : "page"
});



$(document).ready(
		function() {
			opts_viewGrid_top = $("#safeLevelList").comboTableGrid({
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
							alink += '<a href="javascript:deleteSafeLevel('+rowData.id+')"><spring:message code='common.delete'/></a>';
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
			$("#safeLevelList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/createSafeLevel/<c:out value="${appId}"/>/',width:700,height:440,
		title:'<spring:message code="security.level.create"/>', iframe:true, handler:
			function(tp){
				if(tp=="close"){
					$("body").css("overflow","scroll");
				}
			}
		});
}
function modify(id){
	top.ymPrompt.win({message:'${ctx}/enterprise/security/modifySafeLevel/<c:out value="${appId}"/>/?id='+id,width:700,height:440,title:'<spring:message code="security.level.modify"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doModify});
	top.ymPrompt_addModalFocus("#btnModify");
}
function doModify(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitModifyAdminUser();
	} else {
		top.ymPrompt.close();
	}
}

function deleteSafeLevel(id){
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
        	window.parent.document.getElementById('systemFrame').contentWindow.initDataList(1);
        }
    });	
}

function search(){
	var statistics_url = "${ctx}/enterprise/security/listSafeLevel/<c:out value='${appId}'/>/";
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
			$("#safeLevelList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}

</script>
</html>
