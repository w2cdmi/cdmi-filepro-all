<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"
	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-grid.js"type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js"type="text/javascript"></script>
<script src="${ctx}/static/zTree/jquery.ztree.core-3.5.js" type="text/javascript"></script>

<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />

</head>
<body>
	<div class="sys-content">
		<div class="clearfix control-group">
			<a class="return btn btn-small pull-right"
				href="${ctx}/enterprise/admin/listAppByAuthentication"><i
				class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
			<h5 class="pull-left" style="margin: 3px 0 0 4px;">
				<a href="${ctx}/enterprise/admin/listAppByAuthentication"><c:out value='${appId}'/></a>&nbsp;&gt;&nbsp;
				<spring:message code="manage.title.basic" />
			</h5>
		</div>
		
		<ul class="nav nav-tabs clearfix">
        <li class="active"><a class="return" href="${ctx}/enterprise/admin/teamspace/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.teamspace"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/statistics/list/<c:out value='${appId}'/>"><spring:message code="header.statistics"/> </a></li>
        <c:if test="${appType == 1}">
        	<li><a class="return" href="${ctx}/enterprise/admin/individual/config/<c:out value='${appId}'/>"><spring:message code="individual.config"/> </a></li>
        </c:if>
        <li><a class="return" href="${ctx}/enterprise/admin/systemrole/<c:out value='${appId}'/>"><spring:message code="systemRoleList.systemRoleManage"/> </a></li>
        <li><a class="return" href="${ctx}/enterprise/admin/accountEmail/<c:out value='${appId}'/>"><spring:message code="manage.title.email"/> </a></li>
       	<li><a class="return" href="${ctx}/enterprise/admin/basicconfig/config/<c:out value='${appId}'/>"><spring:message code="appSysConfig.basicconfig"/> </a></li>
        </ul>
		
		<div class="clearfix">
		  <div class="pull-left form-search">
	            <input type="hidden" id="appId" name="appId" value="<c:out value='${appId}'/>"/>
	            <input type="hidden" id="pageSize" name="pageSize" value="20">
	            <input type="hidden" id="page" name="page" value="1">            

	            <div class="input-append">                   
	              <input type="text" id="keyword" name="keyword" class="span3 search-query" value="<c:out value='${keyword}'/>" placeholder='<spring:message code="clientManage.teamSpaceName"/>' />
	              <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
	            </div>
	         </div>
		</div>
		<div class="clearfix table-con">
			<div class="pull-left">
		        <button type="button" class="btn" onClick="setMaxMember()"><spring:message code="clientManage.updateMember"/></button>
		        <button type="button" class="btn" onClick="setSpaceQuota()"><spring:message code="clientManage.updateSpaceQuote"/></button>
		        <button type="button" class="btn" onClick="setMaxVersion()"><spring:message code="clientManage.updateMaxVersionNumber"/></button>
			</div>
			
		</div>
		<div class="table-con">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
		</div>
	</div>

</body>
<script type="text/javascript">
	var appId = "<c:out value='${appId}'/>";
	var currentPage = 1;
	var opts_viewGrid = null;
	var opts_page = null;
	var regionData = null;
	
	var headData = {
		"name" : {
				"title" : "<spring:message code='clientManage.teamSpaceName'/>",
				"width" : "130px"
			},
		"description" : {
			"title" : "<spring:message code='teamSpace.label.description'/>",
			"width" : "80px"
		},
		"maxMembers" : {
			"title" : "<spring:message code='clientManage.Member'/>",
			"width" : "250px"
		},
		"spaceQuota" : {
			"title" : "<spring:message code='clientManage.quote'/>",
			"width" : "150px"
		},
		"maxVersions" : {
			"title" : "<spring:message code='clientManage.maxVersion'/>",
			"width" : "270px"
		},
		"createdAt" : {
			"title" : "<spring:message code='clientManage.createDate'/>",
			"width" : "150px"
		},
		"ownedByUserName" : {
			"title" : "<spring:message code='teamSpace.label.owner'/>",
			"width" : "165px"
		}
	};
	$(document).ready(function() {
		opts_viewGrid = $("#rankList").comboTableGrid({
			headData : headData,
			checkBox : true,
			checkAll : true,
			colspanDrag : true,
			height : 860,
			dataId : "id",
			string : {
				checkAllTxt : "<spring:message code='grid.checkbox.selectAll'/>",
				checkCurPageTxt : "<spring:message code='grid.checkbox.selectCurrent'/>"
			},
			definedColumn : true,
			taxisFlag : true
		});
		$.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
			switch (colIndex) {
			case "description":
				try {
					var text = tdItem.find("p").text();
					if(text == "")
					{
						tdItem.find("p").html("_");
					}
				} catch (e) {
				}
				break;
			case "maxMembers":
				try {
					var size = tdItem.find("p").text();
					if (size == "-1") {
						tdItem.find("p").html(rowData.curNumbers + "/" + "<spring:message code='teamSpace.tip.noLimit'/>").parent().attr("title","(rowData.curNumbers + "/" + <spring:message code='teamSpace.tip.noLimit'/>");
					}else{
						tdItem.find("p").html(rowData.curNumbers + "/" + rowData.maxMembers).parent().attr("title",rowData.curNumbers + "/" + rowData.maxMembers);
					}
					
				} catch (e) {
				}
				break;				
			case "spaceQuota":
				try {
					var _txt = formatFileSize(rowData.spaceUsed);
					var size = tdItem.find("p").text();
					if (size == "-1") {
						tdItem.find("p").html(_txt + "/" + "<spring:message code='teamSpace.tip.noLimit'/>").parent().attr("title",_txt + "/" + "<spring:message code='teamSpace.tip.noLimit'/>");
					}else{
						var _txt_quota = formatFileSize(rowData.spaceQuota);
						tdItem.find("p").html(_txt + "/" + _txt_quota).parent().attr("title",rowData.curNumbers + "/" + _txt_quota);
					}
					
				} catch (e) {
				}
				break;	
			case "maxVersions":
				try {
					var size = tdItem.find("p").text();
					if (size == "-1") {
						tdItem.find("p").html("<spring:message code='teamSpace.tip.noLimit'/>").parent().attr("title","<spring:message code='teamSpace.tip.noLimit'/>");
					}
					
				} catch (e) {
				}
				break;
			case "createdAt":
				try {
					var date = getLocalTime(rowData.createdAt)
					tdItem.find("p").html(date).parent().attr("title", date);
				} catch (e) {
				}
				break;
			case "type":
				try {
					var typeName = getTypeName(rowData.type);
					tdItem.find("p").html(typeName).parent("title").attr("", typeName);
				} catch (e) {
				}
				break;
			default:
				break;
			}
		};

		$.fn.comboTableGrid.taxisOp = function(headItem, flag) {
			initDataList(1, headItem, flag);
		};

		opts_page = $("#rankListPage").comboPage({
			style : "page table-page",
			lang : '<spring:message code="main.language"/>'
		});

		$.fn.comboPage.pageSkip = function(opts, _idMap, curPage) {
			initDataList(curPage);
		};
		
		if (!placeholderSupport()) {
			placeholderCompatible();
		};
		
		$("#searchButton").on("click",function(){
			initDataList(1);
		});	
		initSearchEvent();
		initDataList(1);
	});

	function initSearchEvent() {
		$("#keyword").keydown(function(){
			var evt = arguments[0] || window.event;
			if(evt.keyCode == 13){
				initDataList(1);
				if(window.event){
					window.event.cancelBubble = true;
					window.event.returnValue = false;
				}else{
					evt.stopPropagation();
					evt.preventDefault();
				}
			}
		});
	}
	
	function initDataList(curPage) {
		var url = "${ctx}/enterprise/admin/teamspace/config/" + "<c:out value='${appId}'/>";
		var keyword = $("#keyword").val();
		var PerPageNum = 20;
		var params = {
			"page" : curPage,
			"keyword" : keyword,
			"pageSize" : PerPageNum,
			"token"    : "${token}"
		};
		$("#rankList").showTableGridLoading();
		$.ajax({
			type : "POST",
			url : url,
			data : params,
			error : function(request) {
				handlePrompt("error",'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
			    currentPage=curPage;
				catalogData = data.content;
				regionData = data.restRegionInfo;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid);
				$("#rankListPage").setPageData(opts_page, data.number,data.size, data.totalElements);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}

	function setMaxMember(){
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		var url = '${ctx}/enterprise/admin/teamspace/config/setmaxmember/' + appId;
		top.ymPrompt.win({message:url,width:620,height:230,title:'<spring:message code="clientManage.updateTeamSpaceMember"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btn-focus"],['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],handler:doSetMaxMember});
		top.ymPrompt_addModalFocus("#btn-focus");
	}
	
	function doSetMaxMember(tp) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		var ids;
		if(idArray=="all")
		{
			ids="all";
		}
		else
		{
			ids = idArray.join(",");
		}
		var keyword = $("#keyword").val();
		
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.setMaxMember(appId,ids,keyword);
		} else {
			top.ymPrompt.close();
			refreshWindow();
		}
		
	}
	
	
	function setSpaceQuota(){
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		
		var url = '${ctx}/enterprise/admin/teamspace/config/setquota/' + appId;
		top.ymPrompt.win({message:url,width:580,height:230,title:'<spring:message code="clientManage.updateTeamSpaceQuote"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btn-focus"],['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],handler:doSetSpaceQuota});
		top.ymPrompt_addModalFocus("#btn-focus");
	}
	
	function doSetSpaceQuota(tp) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		var ids;
		if(idArray=="all")
		{
			ids="all";
		}
		else
		{
			ids = idArray.join(",");
		}
		
		var keyword = $("#keyword").val();
		
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.setSpaceQuota(appId,ids, keyword);
		} else {
			top.ymPrompt.close();
			refreshWindow();
		}
	}
	
	function setMaxVersion(){
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		
		var url = '${ctx}/enterprise/admin/teamspace/config/setmaxversion/' + appId;
		top.ymPrompt.win({message:url,width:680,height:240,title:'<spring:message code="clientManage.updateMaxVersionNumber"/>', iframe:true,btn:[['<spring:message code="common.modify"/>','yes',false,"btn-focus"],['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],handler:doSetMaxVersion});
		top.ymPrompt_addModalFocus("#btn-focus");
	}
	
	function doSetMaxVersion(tp) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
			return;
		}
		var ids;
		if(idArray=="all")
		{
			ids="all";
		}
		else
		{
			ids = idArray.join(",");
		}
		var keyword = $("#keyword").val();
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.setMaxVersion(appId,ids, keyword);
		} else {
			top.ymPrompt.close();
			refreshWindow();
		}
	}
	
	function refreshWindow() {
		initDataList(currentPage);
	}
	
	function openChangeOwner(teamId) {
		var url = '${ctx}/enterprise/admin/teamspace/config/changeOwner/' + appId + '?teamId='+teamId;
		top.ymPrompt.win({message:url,width:670,height:320,title:'<spring:message code="teamSpace.title.changeowner"/>',iframe:true,btn:[['<spring:message code="common.OK"/>','ok',false,"btn-focus"],['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],handler:questionChangeOwner});
	    top.ymPrompt_addModalFocus("#btn-focus");
	}	
	
	function questionChangeOwner(tp)
	{
	   if(tp=='ok'){
	       top.ymPrompt.getPage().contentWindow.submitChangeOwner();
	    } 
	}	

function getTypeName(type){
	switch (key) {
	case 0:
		return "个人空间";
		break;
    case 1:
    	return " 空间";
		break;
	default:
		break;
	}
}

</script>
</html>
