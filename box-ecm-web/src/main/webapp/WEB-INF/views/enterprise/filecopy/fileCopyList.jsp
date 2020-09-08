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
			<li><a href="#none" id="accessSpaceTabId" onClick="top.openInframe('', '${ctx}/enterprise/space/listAccessConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='space.access.config'/></a></li>
                <li class="active"><a href="#none" id="fileCopyTabId" onClick="top.openInframe('', '${ctx}/enterprise/fileCopy/listConfig/<c:out value="${appId}"/>/','systemFrame')"><spring:message code='fileCopy.access.config'/></a></li>
            </ul>
   	</div>
	<div class="alert"><i class="icon-lightbulb icon-orange"></i><spring:message code="fileCopy.title.total.description"/></div>
	<div class="form-con clearfix">
		<span id="switchButton" class="pull-right"></span>
		<div class="pull-left">
			<p><strong><spring:message code="fileCopy.title.switch" /></strong></p>
			<p class="help-block"><spring:message code="fileCopy.title.switch.description" /></p>
		</div>
<form id="form1" action="">

<input type="hidden" id="enableFileCopySec" name="enableFileCopySec" value="0"/>
<input type="hidden" id="token" name="token" value="${token}"/>
</form>
</div>
	<div class="sys-content">
	    	<div class="pull-left">
	    	<button type="button" class="btn btn-primary" onClick="create()"><i class="icon-plus"></i><spring:message code="space.button.create"/></button>
	    </div>
		<div class="clearfix control-group">
			
		</div>
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
	 	"fileCopyPolicy" : {
			"title" : "<spring:message code='file.type.policy'/>",
			"width" : "60%"
		},
		"createdAt" : {
			"title" : "<spring:message code='fileCopy.title.createAt'/>",
			"width" : "25%"
		},
		"operate" : {
			"title" : "<spring:message code='fileCopy.title.operate'/>",
			"width" : "15%"
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
					case "fileCopyPolicy":
						try {
							tdItem.find("p").html("<spring:message code='fileCopy.message.allow' arguments='"+rowData.srcSafeRoleName+","+rowData.targetSafeRoleName+"' />");							
							tdItem.attr("title",tdItem.find("p").text());
							break;
						} catch (e) {}
					break;
					
					case "createdAt":
						try {
							tdItem.find("p").text(getLocalTime(rowData.createdAt));
							tdItem.attr("title",getLocalTime(rowData.createdAt));
							break;
						} catch (e) {}
					break;
					
					case "operate":
						var alink = "<a href='javascript:delConfig("+rowData.srcSafeRoleId+","+rowData.targetSafeRoleId+",\""+rowData.appId+"\")'><spring:message code='fileCopy.button.delete'/></a>";
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
		url : "${ctx}/enterprise/fileCopy/getSpaceSwitch/<c:out value='${appId}'/>/",
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
				onText : "<spring:message code='fileCopy.switch.open'/>",
				offText : "<spring:message code='fileCopy.switch.close'/>",
				defaultSwitchOn : switchFlag,
				onEvent: function(){
					$("#enableFileCopySec").val("1");
					var url = "${ctx}/enterprise/fileCopy/updateSpaceSwitch/<c:out value='${appId}'/>/";
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
					$("#enableFileCopySec").val("0");
					var url = "${ctx}/enterprise/fileCopy/updateSpaceSwitch/<c:out value='${appId}'/>/";
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
	var statistics_url = "${ctx}/enterprise/fileCopy/list/<c:out value='${appId}'/>";
	var params = {
		"pageNumber" : curPage,
		"token":"${token}"
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


function create(){
	top.ymPrompt.win({message:'${ctx}/enterprise/fileCopy/<c:out value="${appId}"/>',width:650,height:440,title:'<spring:message code="fileCopy.title.add" />', iframe:true,btn:[['<spring:message code="common.create"/>','yes',false,"btnCreate"],['<spring:message code="common.cancel"/>','no',true,"btnCancel"]],handler:doCreate});
	top.ymPrompt_addModalFocus("#btnCreate");
}

function delConfig(srcSafeRoleId,targetSafeRoleId,appId){
	var delUrl = "${ctx}/enterprise/fileCopy/delConfig/<c:out value='${appId}'/>";
	var params ={
			"srcSafeRoleId":srcSafeRoleId,
			"targetSafeRoleId":targetSafeRoleId,
			"appId":appId,
			"token":"${token}"
	};
	$.ajax({
		type:"POST",
		url:delUrl,
		data:params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="fileCopy.operation.fail" />');
		},
		success : function(data) {
			handlePrompt("success",'<spring:message code="fileCopy.operation.success" />');
			initDataList(1);
		}
	});
}

function doCreate(tp) {
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitCreate();
	} else {
		top.ymPrompt.close();
	}
}

</script>
</html>
