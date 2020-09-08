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
			<h5 class="pull-left" style="margin: 3px 0 0 4px;">
				<a href="${ctx}/enterprise/admin/listAppByAuthentication">${appId}</a>&nbsp;&gt;&nbsp;
				<spring:message code="manage.title.usermanage" />
			</h5>
		</div>
		<div class="alert">
			<i class="icon-lightbulb"></i>
			<spring:message code="user.manager.description" />
		</div>
		<div class="clearfix">
		  <div class="pull-left form-search">
	            <input type="hidden" id="appId" name="appId" value="<c:out value='${appId}'/>"/>
	            <input type="hidden" id="page" name="page" value="1"/>
	            <div class="pull-left">
	             <spring:message  code="clusterManage.authenticationTpye"  />:             
	           <select  class="span3 width-w180" id="authenticationMethod" name="authenticationMethod" onchange="changeAuthType()">
	             	<c:if test="${currentTypeId == 0}">
	                  <c:forEach items="${authServerList}" var="authServer">
	           	  		<option value="<c:out value='${authServer.id}'/>" <c:if test="${localTypeId == authServer.id}">selected</c:if>>
	            			 <c:if test="${authServer.type != 'LocalAuth'}"><c:out value='${authServer.name}'/></c:if>
		                     <c:if test="${authServer.type == 'LocalAuth'}"><spring:message  code="authserver.type.local"  /></c:if>
	             		</option>
	                  </c:forEach>
	            	</c:if>
	            	
	              	<c:if test="${currentTypeId != 0}">
	              	 <c:forEach items="${authServerList}" var="authServer">
	            	    <option value="<c:out value='${authServer.id}'/>" <c:if test="${currentTypeId == authServer.id}">selected</c:if>>
	             			<c:out value='${authServer.name}'/>
	             		</option>
	             	 </c:forEach>
	                </c:if>
				</select>
				 </div>
				 <div class="pull-left">
				 <label>&nbsp;</label>
				 </div>
	            <div class="pull-left folderTreeCon">
	                <input type="hidden" id="dn" name="dn" value="<c:out value='${dn}'/>"/>
	                <input type="hidden" id="dnName" name="dnName" value="<c:out value='${dnName}'/>"/>
	                <button type="button" class="btn" onClick="initTreeName()" id="buttonDnName">
	                    <span class="selectTreeName"><c:if test="${empty dnName}">
	                    <spring:message code="user.manager.ldap.node"/>
	                    </c:if>
	                     <c:if test="${not empty dnName}">
	                          <c:out value='${dnName}'/>
	                    </c:if>
	                    </span>
	                    <i class="icon-caret-down"></i>
	                </button>
	                <ul id="treeArea" class="ztree"></ul>
	             </div>
	              <select  class="span3 width-w100" id="userStatus" name="userStatus">
	                        <option value="" selected="selected"><spring:message code="userLisp.userStatus"/></option>
	            		    <option value="0"><spring:message code="common.enable"/></option>
							<option value="1"><spring:message code="common.disable"/></option>
				</select>
	            <div class="input-append">                   
	              <input type="text" id="filter" name="filter" class="span3 search-query" value="<c:out value='${filter}'/>" placeholder='<spring:message code="user.manager.searchDescription"/>' />
	              <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
	            </div>
	            <input type="hidden" id="token" name="token" value="<c:out value='${token}'/>"/>
	         </div>
		</div>
		<div class="clearfix table-con">
			<div class="pull-left">
				<button type="button" class="btn" onclick="updateUserList()">
					<spring:message code="common.modify" />
				</button>
				<button type="button" class="btn" onClick="enableUser(0)">
					<spring:message code="common.enable" />
				</button>
				<button type="button" class="btn" onClick="disableUser(1)">
					<spring:message code="common.disable" />
				</button>
				<button type="button" class="btn" onClick="exportUser()">
					<spring:message code="user.manager.exportOut" />
				</button>
				<button type="button" class="btn" onClick="setRole()" id="setRole">
					<spring:message code="employeeManage.setter.role"/>
				</button>
			</div>
			
		</div>
		<div class="table-con">
			<div id="rankList"></div>
			<div id="rankListPage"></div>
		</div>
		<input type="hidden" id="storField" value="id" /> 
		<input type="hidden" id="storDirection" value="true" />
	</div>

</body>
<script type="text/javascript">
	var currentPage = 1;
	var opts_viewGrid = null;
	var opts_page = null;
	var regionData = null;
	var headData = {
		"name" : {
				"title" : "<spring:message code='user.manager.loginName'/>",
				"width" : "71px"
			},
		"alias" : {
			"title" : "<spring:message code='user.manager.name'/>",
			"width" : "50px"
		},
		"email" : {
			"title" : "<spring:message code='user.manager.email'/>",
			"width" : "40px"
		},
		"roleName" : {
			"title" : "<spring:message code='common.role'/>",
			"width" : "60px"
		},
		"status" : {
			"title" : "<spring:message code='common.status'/>",
			"width" : "50px"
		},
		"regionId" : {
			"title" : "<spring:message code='user.manager.region'/>",
			"width" : "120px"
		},
		"spaceUsed" : {
			"title" : "<spring:message code='user.manager.usedSpace'/>",
			"width" : "79px"
		},
		"spaceQuota" : {
			"title" : "<spring:message code='user.manager.spaceQuota'/>",
			"width" : "90px"
		},
		"fileCount" : {
			"title" : "<spring:message code='user.manager.fileCount'/>",
			"width" : "153px"
		},
		"maxVersions" : {
			"title" : "<spring:message code='createUser.maxVersionNumber'/>",
			"width" : "190px"
		},
		"uploadBandWidth" : {
			"title" : "<spring:message code='basicConfig.uploadBandWidth'/>",
			"width" : "130px"
		},
		"downloadBandWidth" : {
			"title" : "<spring:message code='basicConfig.downloadBandWidth'/>",
			"width" : "154px"
		},
		"teamSpaceFlag" : {
			"title" : "<spring:message code='user.manager.labelIsTeam'/>",
			"width" : "205px"
		},
		"teamSpaceMaxNum" : {
			"title" : "<spring:message code='createUser.teamspaceMaxNUm'/>",
			"width" : "205px"
		},
		"lastLoginAt" : {
			"title" : "<spring:message code='user.manager.lastLogin'/>",
			"width" : "85px"
		}
	};
	$(document).ready(function() {
		opts_viewGrid = $("#rankList").comboTableGrid({
			headData : headData,
			checkBox : true,
			checkAll : true,
			colspanDrag : true,
			height : 500,
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
			case "status":
				try {
					var status = tdItem.find("p").text();
					if (status == 0) {
						tdItem.find("p").html("<spring:message code='common.enable'/>").parent().attr("title","<spring:message code='common.enable'/>");
					}
					if (status == 1) {
						tdItem.find("p").html("<spring:message code='common.disable'/>").parent().attr("title","<spring:message code='common.disable'/>");
					}
				} catch (e) {
				}
				break;
			case "regionId":
				try {
					var size = tdItem.find("p").text();
					if (size == -1) {
						tdItem.find("p").html("<spring:message code='user.manager.regionParam'/>").parent().attr("title","<spring:message code='user.manager.regionParam'/>");
					}
					else{
						for ( var i = 0; i < regionData.length; i++) {
							if (size == regionData[i].id) {
								tdItem.find("p").html(regionData[i].name).parent().attr("title",regionData[i].name);
								break;
							}
						}
					}
				} catch (e) {
				}
				break;
			case "spaceUsed":
				try {
					var size = tdItem.find("p").text();
					var _txt = formatFileSize(size);
					tdItem.find("p").html(_txt).parent().attr("title", _txt);
				} catch (e) {
				}
				break;
			case "fileCount":
				try {
					var text = tdItem.find("p").text();
					if(text == "" || text < 0)
					{
						tdItem.find("p").html("<spring:message code='user.manager.regionParam'/>").parent().attr("title","<spring:message code='user.manager.regionParam'/>");
					}
				} catch (e) {
				}
				break;
			case "maxVersions":
				try {
					var text = tdItem.find("p").text();
					if(text == -1)
					{
						tdItem.find("p").html('<spring:message code="basicConfig.limit"/>').parent().attr("title", '<spring:message code="basicConfig.limit"/>');
					}
				} catch (e) {
				}
				break;
			case "teamSpaceMaxNum":
				try {
					var text = tdItem.find("p").text();
					if(text == -1)
					{
						tdItem.find("p").html('<spring:message code="basicConfig.limit"/>').parent().attr("title", '<spring:message code="basicConfig.limit"/>');
					}
				} catch (e) {
				}
				break;
			case "uploadBandWidth":
				try {
					var text = tdItem.find("p").text();
					if(text == -1)
					{
						tdItem.find("p").html('<spring:message code="basicConfig.limit"/>').parent().attr("title", '<spring:message code="basicConfig.limit"/>');
					}
					if(text == -2)
				    {
						tdItem.find("p").html("<spring:message code='user.manager.regionParam'/>").parent().attr("title","<spring:message code='user.manager.regionParam'/>");
					}
				} catch (e) {
				}
				break;
			case "downloadBandWidth":
				try {
					var text = tdItem.find("p").text();
					if(text == -1)
					{
						tdItem.find("p").html('<spring:message code="basicConfig.limit"/>').parent().attr("title", '<spring:message code="basicConfig.limit"/>');
					}
					if(text == -2)
				    {
						tdItem.find("p").html("<spring:message code='user.manager.regionParam'/>").parent().attr("title","<spring:message code='user.manager.regionParam'/>");
					}
				} catch (e) {
				}
				break;
			case "teamSpaceFlag":
				try {
					var text = tdItem.find("p").text();
					if(text == 0)
					{
						tdItem.find("p").html('<spring:message code="user.manager.isCreateTeam"/>').parent().attr("title", '<spring:message code="user.manager.isCreateTeam"/>');
					}
					else
					{
						tdItem.find("p").html('<spring:message code="logSecurity.visibleFalse"/>').parent().attr("title", '<spring:message code="logSecurity.visibleFalse"/>');
					}
				} catch (e) {
				}
				break;
			case "roleName":
				try {
					var text = tdItem.find("p").text();
					if(text == "0")
					{
						tdItem.find("p").html('<spring:message code="employeeManage.select.role"/>').parent().attr("title","<spring:message code='user.manager.regionParam'/>");
					}
				} catch (e) {
				}
				break;
			case "lastLoginAt":
				try {
					var size = tdItem.find("p").text();
					for ( var i = 0; i <catalogData.length; i++) {
						if(size == catalogData[i].lastLoginAt){
							_txt = catalogData[i].lastLoginAt;
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
							var date = _year+"-"+_month+"-"+_day+" "+_hours+":"+_min+":"+_sec
							tdItem.find("p").html(date).parent().attr("title", date);
						}
					}
				} catch (e) {
				}
				break;
			case "spaceQuota":
				try {
					var size = tdItem.find("p").text();
					var _txt = formatFileSize(size);
					tdItem.find("p").html(_txt).parent().attr(
							"title", _txt);
					if (size == "-1") {
						tdItem.find("p").html("<spring:message code='basicConfig.limit'/>").parent().attr("title","<spring:message code='basicConfig.limit'/>");
					}
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
		
		changeAuthType();
		
		if (!placeholderSupport()) {
			placeholderCompatible();
		};
		
		$("#searchButton").on("click",function(){
			initDataList(1);
		});	
		
		$("#filter").keydown(function(){
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
		
	});

	function initDataList(curPage) {
		var url = "${ctx}/enterprise/admin/accountuser/list";
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var userStatus = $("#userStatus").find("option:selected").val();
		if(userStatus == "" || (userStatus != 0 && userStatus != 1))
		{
			userStatus = null;
		}
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var PerPageNum = 20;
		var params = {
			"page" : curPage,
			"authServerId" : authServerId,
			"filter" : filter,
			"userStatus" : userStatus,
			"token" : "<c:out value='${token}'/>",
			"size" : PerPageNum,
			"appId" : "<c:out value='${appId}'/>",
			"dn" : dn
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
				catalogData = data.content;
				regionData = data.restRegionInfo;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid);
				$("#rankListPage").setPageData(opts_page, data.number,data.size, data.totalElements);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}

	function updateUserList() {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",
					'<spring:message code="user.manager.selectUser"/>');
			return;
		}
		var url = "${ctx}/enterprise/admin/accountuser/updateUserList/"+"<c:out value='${appId}'/>";
		top.ymPrompt.win({
			message : url,
			width : 660,
			height : 450,
			title : '<spring:message code="user.manager.modifyUser"/>',
			iframe : true,
			btn : [[ '<spring:message code="common.modify"/>', 'yes', false,
							"btn-focus" ],
					[ '<spring:message code="common.cancel"/>', 'no', true,
							"btn-cancel" ] ],
			handler : saveUserList
		});
		top.ymPrompt_addModalFocus("#btn-focus");
	}

	function saveUserList(tp) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
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
		var selStatus = $("#userStatus").find("option:selected").val();
		var selTag = $("#userTagId").find("option:selected").val();
		var selFilter= $("#filter").val();
		var selLdapDn= $("#dn").val();
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.submitUser(ids,selTag,selStatus,selFilter,selLdapDn,authServerId,"<c:out value='${appId}'/>");
		} else {
			top.ymPrompt.close();
		}
	}
	
	
	

	function saveUser(tp) {
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.submitUser();
		} else {
			top.ymPrompt.close();
		}
	}

	
	function disableUser(status) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
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
		top.ymPrompt.confirmInfo({
					title : '<spring:message code="user.manager.disableUser"/>',
					message : '<spring:message code="common.disableConfirm"/>'
							+ '<br/>'
							+ '<spring:message code="user.manager.disableDescription"/>',
					width : 450,
					closeTxt : '<spring:message code="common.close"/>',
					handler : function(tp) {
						if (tp == "ok") {
							changeStatus(status, ids);
						}
					},
					btn : [
							[ '<spring:message code="common.OK"/>', "ok" ],
							[ '<spring:message code="common.cancel"/>',
									"cancel" ] ]
				});
	}

	function enableUser(status) {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",
					'<spring:message code="user.manager.selectUser"/>');
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
		
		
		top.ymPrompt.confirmInfo({
			title : '<spring:message code="user.manager.enableUser"/>',
			message : '<spring:message code="user.manager.enableDescription"/>',
			width : 450,
			closeTxt : '<spring:message code="common.close"/>',
			handler : function(tp) {
				if (tp == "ok") {
					changeStatus(status, ids);
				}
			},
			btn : [
					[ '<spring:message code="common.OK"/>', "ok" ],
					[ '<spring:message code="common.cancel"/>',
							"cancel" ] ]
		});
	}

	function changeStatus(status, ids) {
		var userStatus = $("#userStatus").find("option:selected").val();
		if(userStatus == "" || (userStatus != 0 && userStatus != 1))
		{
			userStatus = null;
		}
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var params = {
			"filter" : filter,
			"dn" : dn,
			"selStatus" : userStatus,
			"authServerId" : authServerId,
			"status" : status,
			"appId" : "<c:out value='${appId}'/>",
			"ids":ids,
			"token" : "${token}"
		};
		var url = "${ctx}/enterprise/admin/accountuser/changeStatus";
		$.ajax({
					type : "POST",
					url : url,
					data : params,
					error : function(request) {
						top.handlePrompt("error", '<spring:message code="common.modifyStatusFailed"/>');
					},
					success : function() {
						top.handlePrompt("success", '<spring:message code="common.modifyStatusSucessed"/>');
						refreshWindow();
					}
				});
	}
	
	function refreshWindow() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		window.location = "${ctx}/enterprise/admin/accountuser/list/" + "<c:out value='${appId}'/>" + "/" + authServerId;
	}

	

	function modifyUserRegion(tp) {
		if (tp == 'ok') {
			top.ymPrompt.getPage().contentWindow.submitModifyUserRegion();
		}
	}
	function exportUser() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var userStatus = $("#userStatus").find("option:selected").val();
		if(userStatus == "" || (userStatus != 0 && userStatus != 1))
		{
			userStatus = 2;
		}
		var filter = $("#filter").val();
		if(filter=="" || filter == null)
		{
		  filter=null;	
		}
		var dn = $("#dn").val();
		if(dn=="" || dn == null)
		{
			dn=null;	
		}
		if(isIeBelow11()){
			top.ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="common.download.excel.file" />'});
			var url = "${ctx}/enterprise/admin/accountuser/exportUser/" + authServerId + "/<c:out value='${appId}'/>"+"/"+userStatus+"/"+filter+"/"+dn;
			window.location = url;
			return;
		}else{
			var url = "${ctx}/enterprise/admin/accountuser/exportUser/" + authServerId + "/<c:out value='${appId}'/>"+"/"+userStatus+"/"+filter+"/"+dn;
			window.location = url;
		}
		
	}

	function uploadImportUserCsvFile(tp) {
		if (tp == "ok") {
			top.ymPrompt.getPage().contentWindow
					.submitImportUserCsvFileUpload();
		} else {
			top.ymPrompt.close();
		}
	}
 
//ldap
function initTree(name){
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	var setting = {
			async : {
				enable : true,
				url : "${ctx}/enterprise/admin/ldapuser/listTreeNode/"+authServerId,
				autoParam : ["baseDn", "page"],
				otherParam : ["token","${cse:htmlEscape(token)}" ]
			},
			data : {
				simpleData : {
					enable : true
				}
			},
			view : {
				expandSpeed : "",
				showIcon : false
			},
			callback : {
				onAsyncSuccess: onAsyncSuccess,
				onAsyncError : onAsyncError,
				onClick: zTreeOnClick
			}
		};

		var zNodes = [ {name : name, isParent : true, page: 0, baseDn : name},
		               {name : '<spring:message code="user.manager.ldap.node"/>', baseDn : ""}];
		$.fn.zTree.init($("#treeArea"), setting, zNodes);
		$("#treeArea > li > span").click();
		$("#treeArea").toggle();
		
		$("body").mousedown(function(){
			var ev = arguments[0] || window.event;
			var srcElement = ev.srcElement || ev.target;
			if(srcElement != $("#treeArea").get(0) && srcElement != $("#buttonDnName").get(0) && $(srcElement).parents("button").attr("id") !=  "buttonDnName" && $(srcElement).parents(".ztree").attr("id") !=  "treeArea"){
				$("#treeArea").hide();
			};
		})
		
		stopDefaultScroll("treeArea");
}

function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus,
		errorThrown) {
	top.handlePrompt("error", '<spring:message  code="clusterManage.date.exception"/>');
}

function zTreeOnClick(event, treeId, treeNode) {
	if(treeNode.id != "-1"){
		$("#buttonDnName").find(">span").html(treeNode.name);
		$("#dnName").val(treeNode.name);
		$("#dn").val(treeNode.baseDn);
	}
	$("#treeArea").hide();
};

function stopDefaultScroll(id){
	var _this = document.getElementById(id);
	if(navigator.userAgent.indexOf("Firefox")>0){
		_this.addEventListener('DOMMouseScroll',function(e){
			_this.scrollTop += e.detail > 0 ? 60 : -60;   
			e.preventDefault();
		},false); 
	}else{
		_this.onmousewheel = function(e){   
			e = e || window.event;   
			_this.scrollTop += e.wheelDelta > 0 ? -60 : 60;   
			return false;
		};
	}
	return this;
};

var pageCount = 0;

function initTreeName(){
	var params = {
		"token":"${token}"
	};
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	$.ajax({
        type: "POST",
        data : params,
        url:"${ctx}/enterprise/admin/ldapuser/initTreeName/"+authServerId,
        error: function(request) {
        	top.handlePrompt("error", '<spring:message  code="clusterManage.date.exception"/>');
        },
        success: function(data) {
        	if(data.baseDn != null && data.baseDn != "")
			{
        		pageCount = data.page;
        		initTree(data.baseDn);
			}
        }
    });
}

function onAsyncSuccess(event, treeId, treeNode, msg) {
	var childrenNode = treeNode.children;
	if(childrenNode)
	{
	  var nodesLength = treeNode.children.length;
	  if(pageCount >0 && nodesLength >= pageCount)
	  {
			addDiyDom(treeId, treeNode);
	  }
   }
}

function addDiyDom(treeId, treeNode) {
	var prevFlag = $("#prevBtn_"+treeNode.tId);
	if(!prevFlag.get(0))
	{
		var aObj = $("#" + treeNode.tId+"_switch");
		var addStr = "<span class='button prevPage' id='prevBtn_" + treeNode.tId
		+ "' title='<spring:message code="common.prev.page"/>' onfocus='this.blur();'></span><span class='button nextPage' id='nextBtn_" + treeNode.tId
		+ "' title='<spring:message code="common.next.page"/>' onfocus='this.blur();'></span>";
		aObj.after(addStr);
		var prev = $("#prevBtn_"+treeNode.tId);
		var next = $("#nextBtn_"+treeNode.tId);
		
		prev.bind("click", function(){
			if (!treeNode.isAjaxing) {
				goPage(treeNode, treeNode.page-1);
			}
		});
		next.bind("click", function(){
			if (!treeNode.isAjaxing) {
				goPage(treeNode, treeNode.page+1);
			}
		});
	}
};

function goPage(treeNode, page) {
	if (page < 0)
	{
		return;
	}
	
	var childrenNode = treeNode.children;
	if(childrenNode)
	{
	  var nodesLength = treeNode.children.length;
	  if(nodesLength != 0 || (page+1) == treeNode.page)
	  { 
		  treeNode.page = page;
	      var zTree = $.fn.zTree.getZTreeObj("treeArea");
	      zTree.reAsyncChildNodes(treeNode, "refresh");
	  }
   }	
}


	function changeAuthType()
	{
		$("#buttonDnName").find(">span").html('<spring:message code="user.manager.ldap.node"/>');
		$("#dn").val("");
		$("#dnName").val(null);

		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var localTypeId = "<c:out value='${localTypeId}'/>";
		if(authServerId== localTypeId)
		{
		    $("#buttonDnName").hide();
		}
		else
		{
			$("#buttonDnName").show();
		}
		initDataList(1);
	}

	function setRole() {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
			return;
		}
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/enterprise/admin/accountuser/setRole/"+authServerId+"/<c:out value='${appId}'/>";
		top.ymPrompt.win({
			message : url,
			width : 660,
			height : 400,
			title : '<spring:message code="employeeManage.setter.role"/>',
			iframe : true,
			btn : [
					[ '<spring:message code="common.OK"/>', 'yes', false,
							"btn-focus" ],
					[ '<spring:message code="common.cancel"/>', 'no', true,
							"btn-cancel" ] ],
			handler : setterRole
		});
		top.ymPrompt_addModalFocus("#btn-focus");
	}
	
	function setterRole(tp) {
		if (tp == 'yes') {
			var idArray = $("#rankList").getTableGridSelected();
			if (idArray == "") {
				handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
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
			var userStatus = $("#userStatus").find("option:selected").val();
			if(userStatus == "" || (userStatus != 0 && userStatus != 1))
			{
				userStatus = null;
			}
			
			var filter = $("#filter").val();
			var dn = $("#dn").val();
			var authServerId = $("#authenticationMethod").find("option:selected").val();
			top.ymPrompt.getPage().contentWindow.submitSetter(ids, "<c:out value='${appId}'/>", authServerId,userStatus, filter, dn);
		} else {
			top.ymPrompt.close();
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
</html>
