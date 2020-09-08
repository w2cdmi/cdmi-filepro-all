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
   <link href="${ctx}/static/skins/default/css/public.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/skins/default/css/mytree.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/skins/default/css/main.css" rel="stylesheet" type="text/css" />
    <link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css"/>
    <script src="${ctx}/static/zTree/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>
</head>
<body>
<div class="content">
	
    <div class="c_main">
             <div class="option-header">
                    <div class="option-item option-header-active" value="teamspase">团队空间</div>
             </div>
              <div class="option-content active" id="teamspase" style="display: block;">
	              <div class="clearfix">
		  <div class="pull-left form-search">
	      <div class="form-search">
            <input type="hidden" id="page" name="page" value="1"/>
           <div class="pull-left">
                <select class="span3 width-w180" id="type" name="type">
                  <option value="-1">全部</option>
                  <option value="0">员工文库</option>
                  <option value="1">部门文库</option>
<!--                   <option value="2">工作空间</option>
                  <option value="3">兴趣空间</option> -->
                  <option value="4">企业文库</option>
                  <option value="5">收件空间</option>
                </select>
            </div>
            <div class="pull-left input-append" style="margin-left: 20px;">
                <input type="text" id="keyword" name="keyword" class="span3 search-query" value="${keyword}" placeholder='名称' />
            </div>
           <%--  <div class="pull-left input-append">
                <input type="text" id="ownerByUserName" name="ownerByUserName" class="span3 search-query" value="${ownerByUserName}" placeholder='拥有人' />
            </div> --%>
            <div class="pull-left" >
                <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
            </div>
             <div class="pull-left" style="margin-left: 20px;">
                <button type="button" class="btn" id="updateSpace" onclick="showUpdateSpaceModal()" style="border-radius: 3px;">调整配额</button>
            </div>
            <input type="hidden" id="token" name="token" value="${token}"/>
        </div>
	         </div>
	         </div>
		<div class="clearfix table-con" style="margin-top: 10px;width:100%;height: 750px">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
		</div>
              </div>
      </div>
</div>
 <div class="modal fade" id="updateSpaceModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title" id="myModalLabel">调整空间配额</h4>
            </div>
            <div class="modal-body">
            <form class="form-horizontal" role="form">
  <div class="form-group">
    <label for="firstname" class="col-sm-4 control-label">最大成员数</label>
    <div class="col-sm-5">
      <input type="text" class="form-control" id="maxMembers" >
    </div>
  </div>
  <div class="form-group">
    <label for="lastname" class="col-sm-4 control-label">最大存储空间(GB)</label>
    <div class="col-sm-5">
      <input type="text" class="form-control" id="maxSpaces" >
    </div>
  </div>
  <div class="form-group">
    <label for="lastname" class="col-sm-4 control-label">最大版本数</label>
    <div class="col-sm-5">
      <input type="text" class="form-control" id="maxVersions" >
    </div>
  </div>
</form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" onclick="updateSpace()">提交更改</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal -->
</div>          

</body>
<script type="text/javascript">
    var appId= window.parent.defaltAppId;
	var curPage = 1;
	var opts_viewGrid = null;
	var opts_page = null;
	var regionData = null;
	var currentPage = 1;
	var opts_viewGrid = null;
	var opts_page = null;
	var regionData = null;
	
	var headData = {
		"name" : {
				"title" : "<spring:message code='clientManage.teamSpaceName'/>",
				"width" : "15%;"
			},
	    "type" : {
				"title" : "类型",
				"width" : "10%;"
			},
		"maxMembers" : {
			"title" : "成员数/成员总数",
			"width" : "15%;"
		},
		"spaceQuota" : {
			"title" : "容量/总容量",
			"width" : "15%;"
		},
		"maxVersions" : {
			"title" : "最大版本",
			"width" : "10%;"
		},
		"createdByUserName" : {
			"title" : "拥有人",
			"width" : "10%;"
		},
		"ownedByUserName" : {
			"title" : "创建人",
			"width" : "10%;"
		},
		"createdAt" : {
			"title" : "<spring:message code='clientManage.createDate'/>",
			"width" : "15%;" 
		},
		
	};
$(document).ready(function() {
 opts_viewGrid = $("#rankList").comboTableGrid({
		headData : headData,
		checkBox : true,
		checkAll : true,
		/* colspanDrag : true, */
	/* 	height : 750, */
		dataId : "id",
		string : {
			checkAllTxt : "<spring:message code='grid.checkbox.selectAll'/>",
			checkCurPageTxt : "<spring:message code='grid.checkbox.selectCurrent'/>"
		},
		/* definedColumn : true, */
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
				tdItem.find("p").html(typeName).parent().attr("title", typeName);
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
	$("#type").on("change",function(){
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
	var url = "${ctx}/enterprise/admin/teamspace/config/" + appId;
	var keyword = $("#keyword").val();
	var type = $("#type").val();
	var ownerByUserName = $("#ownerByUserName").val();
	var PerPageNum = 20;
	var params = {
		"page" : curPage,
		"keyword" : keyword,
		"type" : type,
		"ownerByUserName" : ownerByUserName,
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
			/* var pageH = $("body").outerHeight();
			top.iframeAdaptHeight(pageH); */
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
	var typeName="";
	switch (type) {
	
	case 0:
		typeName="个人空间";
		break;
    case 1:
    	typeName="部门文件";
		break;
    case 2:
    	typeName="工作内容";
		break;
    case 3:
    	typeName="兴趣爱好";
		break;
    case 4:
    	typeName="文档库";
		break;
    case 5:
    	typeName="收件箱";
		break;
	default:
		break;
	}
	return typeName;
}
function showUpdateSpaceModal(){

	
	$('#updateSpaceModal').modal('show');
}

function updateSpace(){
	var maxMembers=$("#maxMembers").val();
	var maxSpaces=$("#maxSpaces").val();
	var maxVersions=$("#maxVersions").val();
	var idArray = $("#rankList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="clientManage.selectTeamSpace"/>');
		return;
	}
	var teamIds="";
	for(var i=0;i<idArray.length;i++){
		teamIds=teamIds+idArray[i]+",";
	}
	var params={
			"maxMembers":maxMembers,
			"maxSpaces":maxSpaces,
			"maxVersions":maxVersions,
			"teamIds":teamIds,
			"token"    : "${token}"
			
	}
	var url = '${ctx}/enterprise/admin/teamspace/config/updateSpace/' + appId;
	$.ajax({
		type : "POST",
		url : url,
		data : params,
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
		},
		success : function(data) {
			 handlePrompt("success", '调整配额成功');
			 $('#updateSpaceModal').modal('hide');
			 $("#maxMembers").val("");
			 $("#maxSpaces").val("");
			 $("#maxVersions").val("");
			 refreshWindow();
		}
	});
	
}


function createSystemTeamSpace(type){
	var url = '${ctx}/enterprise/admin/teamspace/config/createSystemTeamSpace/' + appId;
	$.ajax({
		type : "POST",
		url : url,
		data : {"token": "${token}",'type':type},
		error : function(request) {
			handlePrompt("error",'<spring:message code="common.operationFailed" />');
		},
		success : function(data) {
			 handlePrompt("success", '创建成功');
		}
	});
	
}

</script>
</html>
