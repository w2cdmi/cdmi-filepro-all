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

<div class="sys-content">
	<div class="clearfix">
   		<ul class="nav nav-tabs">
                <li><a href="#none" id="enterpriseManageTabId" onClick="top.openInframe('', '${ctx}/enterprise/security/list/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='security.role.manage'/></a></li>
				<li class="active"><a href="#none" id="accessSpaceTabId" onClick="top.openInframe('', '${ctx}/enterprise/space/listAccessConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='space.access.config'/></a></li>
                <li><a href="#none" id="fileCopyTabId" onClick="top.openInframe('', '${ctx}/enterprise/fileCopy/listConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='fileCopy.access.config'/></a></li>
            </ul>
   	</div>
	<div class="alert"><i class="icon-lightbulb icon-orange"></i><spring:message code="space.title.total.description"/></div>
	<div class="form-con clearfix">
		<span id="switchButton" class="pull-right"></span>
		<div class="pull-left">
			<p><strong><spring:message code="space.title.switch" /></strong></p>
			<p class="help-block"><spring:message code="space.title.switch.description" /></p>
		</div>
<form id="form1" action="">

<input type="hidden" id="enableSpaceSec" name="enableSpaceSec" value="0"/>
<input type="hidden" id="token" name="token" value="${token}"/>
</form>
</div>
	<div class="sys-content">
	    	<div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="createSpace()"><i class="icon-plus"></i><spring:message code="space.button.create"/></button>
	    </div>
	<form id="searchForm" class="pull-right form-search">
               <select class="span3" id="safeRoleId" name="safeRoleId">
               <option value="-1"><spring:message code='security.role.any'/></option>
      		<c:forEach items="${safeRoleList}" var="oper">
      			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
      		</c:forEach>
		</select>
               <select class="span3" id="netRegionId" name="netRegionId">
               <option value="-1"><spring:message code='network.region.any'/></option>
      		<c:forEach items="${netRegionList}" var="oper">
      			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.netRegionName}'/></option>
      		</c:forEach>
		</select>
		<button type="button" class="btn" onClick="search()"><spring:message code="common.search"/></button>
		<input type="hidden" id="token" name="token" value="${token}"/>
    	</form>
		<div class="clearfix control-group">
			
		</div>
		<div id="accessConfigList"></div>
		
		<div id="page"></div>
		
		<div id="listaaa"></div>
	</div>
	</div>
</body>
<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid_statistics = null;
var opts_viewGrid_top = null;
var viewMode = "list";
var opts_page = null;
var headDataStatistics = {
		"safeRoleName" : {
			"title" : "<spring:message code='space.title.saferolename'/>",
			"width" : "90px"
		},
		"netRegionName" : {
			"title" : "<spring:message code='space.title.netregionname'/>",
			"width" : "160px"
		},
		"targetSafeRoleName" : {
			"title" : "<spring:message code='space.access.targetSafeRole'/>",
			"width" : "100px"
		},
		"operation" : {
			"title" : "<spring:message code='space.title.operationtypename'/>",
			"width" : "160px"
		},
		"downLoadResrouceTypeIds" : {
	            "title" : "<spring:message code='space.title.download'/>",
	            "width" : "250px"
        },
        "previewResourceTypeIds" : {
            "title" : "<spring:message code='space.title.scan'/>",
            "width" : "260px"
        },
		"operate" : {
			"title" : "<spring:message code='space.title.operate'/>",
			"width" : "100px"
		}
};

var pageOpts = $("#page").comboPage({
	style : "page"
});



$(document).ready(function() {
			opts_viewGrid_top = $("#accessConfigList").comboTableGrid({
				headData : headDataStatistics,
				dataId : "id",
				height : 660,
				colspanDrag : true,
				dataNullTip : "<spring:message code='space.data.desc'/>"
			});
			
			$.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
				switch (colIndex) {
					case "modifiedAt":
						tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
						tdItem.attr("title",getLocalTime(rowData.modifiedAt));
						break;
					case "operate":
						var alink = "<a href='javascript:modifySpace("+"\""+rowData.id+"\""+")'><spring:message code="space.button.modify"/></a>"+"&nbsp;";
						alink += "<a href='javascript:delConfig("+"\""+rowData.id+"\""+")'><spring:message code='space.button.delete'/></a>";
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
			initDataList();
			
		});

function getAccessConfigSwitch(){
	$.ajax({
		type : "POST",
		url : "${ctx}/enterprise/security/getSpaceSwitch/<c:out value='${appId}'/>/",
		data : $('#form1').serialize(),
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			var switchFlag = false;
			if( data=="1"){
				switchFlag = true;
			}
			
			var switchOpts = $("#switchButton").comboSwitchButton({
				onText : "<spring:message code='accessconfig.opened'/>",
				offText : "<spring:message code='accessconfig.closed'/>",
				defaultSwitchOn : switchFlag,
				onEvent: function(){
					$("#enableSpaceSec").val("1");
					var url = "${ctx}/enterprise/security/updateSpaceSwitch/<c:out value='${appId}'/>/";
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
					$("#enableSpaceSec").val("0");
					var url = "${ctx}/enterprise/security/updateSpaceSwitch/<c:out value='${appId}'/>/";
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
	viewMode = "list";
	var statistics_url = "${ctx}/enterprise/space/listAccessConfig/<c:out value='${appId}'/>";
	var params = {
		"pageNumber" : curPage,
		"token" : "${token}"
	};
	$.ajax({
		type : "POST",
		url : statistics_url,
		data : params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#accessConfigList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
			var pageH = $("body").outerHeight();
            top.iframeAdaptHeight(pageH);
		}
	});
}



function createSpace(){
	$("body").css("overflow","hidden");
	var url = '${ctx}/enterprise/space/createAccessConfig/<c:out value="${appId}"/>';
	top.ymPrompt.win({message:url,width:700,height:570,title:"<spring:message code='accessconfig.space.add'/>", iframe:true, handler: 
	function(tp){
		if(tp=="close"){
			$("body").css("overflow","scroll");
		}
	}});
}

function createHandle() {
	$("body").css("overflow","scroll");
	top.ymPrompt.close();
	if(viewMode == "list"){
		initDataList(currentPage);
	}else{
		search();
	}
}


function modifySpace(id){
	$("body").css("overflow","hidden");
	var url = '${ctx}/enterprise/space/modifyAccessConfig/<c:out value="${appId}"/>/?id='+id;
	top.ymPrompt.win({message:url,width:700,height:570,title:"<spring:message code='accessconfig.space.update'/>", iframe:true, handler: 
	function(tp){
		if(tp=="close"){
			$("body").css("overflow","scroll");
		}
	}});
}

function modifyHandle() {
	$("body").css("overflow","scroll");
	top.ymPrompt.close();
	if(viewMode == "list"){
		initDataList(currentPage);
	}else{
		search();
	}
}

function delConfig(id){
	var delUrl = "${ctx}/enterprise/space/delSpaceConfig/<c:out value='${appId}'/>";
	var params ={
			"id":id,
			"token" : "${token}"
	};
	$.ajax({
		type:"POST",
		url:delUrl,
		data:params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="space.operation.fail" />');
		},
		success : function(data) {
			handlePrompt("success",'<spring:message code="space.operation.success" />');
			initDataList(1);
		}
	});
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
	viewMode = "search";
	var statistics_url = "${ctx}/enterprise/space/listAccessConfig/<c:out value='${appId}'/>";
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
			$("#accessConfigList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}
	

</script>
</html>
