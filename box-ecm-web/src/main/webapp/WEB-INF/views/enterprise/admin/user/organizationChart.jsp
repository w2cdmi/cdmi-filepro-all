<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="cse"	uri="http://cse.huawei.com/custom-function-taglib"%>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css" />
<script src="${ctx}/static/zTree/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/common.js" type="text/javascript"></script>
</head>
<body>
	<div class="sys-content">
		<div class="alert">
			<i class="icon-lightbulb"></i>
			<spring:message code="organizationChart.decription" />
		</div>
		<div class="clearfix">
			<div class="pull-left form-search">
				<input type="hidden" id="page" name="page" value="1" />

				<div class="pull-left">
					<select class="span3 width-w180" id="authenticationMethod"
						name="authenticationMethod" onchange="changeAuthType()">
						<c:if test="${currentTypeId == 0}">
							<c:forEach items="${authServerList}" var="authServer">
								<option value="<c:out value='${authServer.id}'/>"
									<c:if test="${localTypeId == authServer.id}">selected</c:if>>
									<c:if test="${authServer.type != 'LocalAuth'}">
										<c:out value='${authServer.name}' />
									</c:if>
									<c:if test="${authServer.type == 'LocalAuth'}">
										<spring:message code="authserver.type.local" />
									</c:if>
								</option>
							</c:forEach>
						</c:if>

						<c:if test="${currentTypeId != 0}">
							<c:forEach items="${authServerList}" var="authServer">
								<option value="<c:out value='${authServer.id}'/>"
									<c:if test="${currentTypeId == authServer.id}">selected</c:if>>
									<c:out value='${authServer.name}' />
								</option>
							</c:forEach>
						</c:if>
					</select>
				</div>

				<div class="pull-left">
					<label>&nbsp;</label>
				</div>

				<div class="pull-left folderTreeCon">
					<input type="hidden" id="dn" name="dn"
						value="<c:out value='${dn}'/>" /> <input type="hidden" id="dnName"
						name="dnName" value="<c:out value='${dnName}'/>" />
					<ul id="treeArea" class="ztree"></ul>
				</div>

				<!-- <div class="input-append">
					<button type="button" class="btn" id="searchButton">
						<i class="icon-search"></i>
					</button>
				</div> -->
				<input type="hidden" id="token" name="token" value="${token}" />
			</div>
		</div>

		<div class="table-con">
			<div id="treeContent2" class="ztreeUl"
				style="width: 98%; height: 80%; position: absolute">
				<table style="width: 100%; align: left">
					<tr>
						<td valign="top" style="width: 30%; border: 1px #CCC solid">
							<ul id="treeDemo" class="ztree"
								style="padding: 0px; width: 99%; background-color: white;" />
						</td>
						<td style="width: 80%;">
							<div class="clearfix table-con">
								<div class="controls" id=deptSectionDiv>
									<input type="text" id="filter" name="filter" class="span3"
										value="<c:out value='${filter}'/>"
										placeholder='<spring:message code="user.manager.searchDescription"/>' />
										<div class=""
											style="position: absolute;float:left; width: 20%; height: 18%;
											margin-left:233px;margin-top:-41px">
											<button type="button" class="btn btn-primary"
												onclick="deptAddEnterpriseUser()" id="createUserBtn">
												<i class="icon-plus"></i>
												<spring:message code="common.create" />
											</button>
											<button type="button" class="btn" onClick="deleteUser()"
												id="deleteUserBtn">
												<spring:message code="common.delete" />
											</button>
										</div>
									<span class="validate-con bottom inline-span3"><div></div></span>
									<input id="storeIds" name="departmentIds" type="hidden"
										class="selectDevTypeid" />
									<div id="treeContent" class="selectDevTypeid"
										style="display: none; z-index: 2; position: absolute;overflow-y:scroll; border: 1px #CCC solid; background-color: white;">
										<ul id="menuTree" class="ztree" style="margin-top: 0;"></ul>
									</div>
									
								</div>
							</div>
							<div id="rankList"></div>
							<div id="rankListPage"></div>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<input type="hidden" id="storField" value="id" /> <input
			type="hidden" id="storDirection" value="true" />
	</div>
</body>
<script language="JavaScript">

	function zTreeOnAsyncSuccess(event, treeId, treeNode, msg) {
	    alert(msg);
	};

	var firstzNodes =[];
	var log, className = "dark";
	function beforeDrag(treeId, treeNodes) {
		return false;
	}
	function zTreeBeforeAsync(treeId, treeNode){
		return true;
	}
	function getTreeId(){
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var sNodes = treeObj.getSelectedNodes();
		var tId = -1;
		if (sNodes.length > 0) {
			tId = sNodes[0].id;
		}
		return tId;
	}
	function getTreeNode(){
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var sNodes = treeObj.getSelectedNodes();
		return sNodes[0];
	}
	
	function onClick() {
		currentPage = 1;
		newHeadItem = "";
		newFlag = false;
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var sNodes = treeObj.getSelectedNodes();
		var tId = -1;
		if (sNodes.length > 0) {
			tId = sNodes[0].id;
		}
		if(tId == undefined){     //快速创建多个部门，出现部门下有员工异常
			return;
		}
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/enterprise/admin/user/employeeManage";
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var params = {
			"page" : 1,
			"deptId":tId,
			"authServerId" :authServerId,
			"filter" : dn,
			"token" : "${token}",
			"dn" : dn,
			"newHeadItem":newHeadItem,
			"newFlag":newFlag
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
				appIds = data[0];
				catalogData = data[1].content;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid);
				$("#rankListPage").setPageData(opts_page, data[1].number,data[1].size, data[1].totalElements);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}
	
	function beforeEditName(treeId, treeNode) {
		className = (className === "dark" ? "":"dark");
		showLog("[ "+getTime()+" beforeEditName ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
		zTree.selectNode(treeNode);
		var nodes = zTree.getNodesByParam("name", "department", treeNode.pId);
		zTree.editName(treeNode);
		return false;
	}
	function beforeRemove(treeId, treeNode) {
		className = (className === "dark" ? "":"dark");
		showLog("[ "+getTime()+" beforeRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
		zTree.selectNode(treeNode);
		/*
			The root directory cannot be deleted
		*/
		if(treeNode.id == -1){
			top.handlePrompt("error",'<spring:message code="organizationChart.ztree.removeRoot.failed"/>');
			return false;
		}
		var vildateDept = false;
		top.ymPrompt.confirmInfo({
			title : '<spring:message code="organizationChart.ztree.deteteDept"/>',
			message : '<spring:message code="organizationChart.ztree.removeDept1"/>'
					+ treeNode.name
					+ '<spring:message code="organizationChart.ztree.removeDept2"/>',
			width : 450,
			closeTxt : '<spring:message code="common.close"/>',
			handler : function(tp) {
				if (tp == "ok") {
					vildateDept = deleteDept(treeNode.id);
					if(vildateDept){
						var nodes = zTree.getSelectedNodes();
						for (var i=0, l=nodes.length; i < l; i++) {
							zTree.removeNode(nodes[i]);
						}
					}
				}
			},
			btn : [
					[ '<spring:message code="common.OK"/>', "ok" ],
					[ '<spring:message code="common.cancel"/>',
							"cancel" ] ]
		});
		return vildateDept;
	}
	function onRemove(e, treeId, treeNode) {
		showLog("[ "+getTime()+" onRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
	}
	function deleteDept(tId){
		if(tId == undefined || tId == "undefiend"){
			handlePrompt("error",'<spring:message code="organizationChart.deleteDept.nonentity" />');
			return;
		}
		var vildateDept = true;
		var url="${ctx}/enterprise/admin/organize/deleteDepartment";
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var params = {
				"departmentId" : tId,
				"authServerId" : authServerId,
				"token" : "${token}"
			};
		$.ajax({
			type : "POST",
			url : url,
			data : params,
			async: false, 
			error : function(request) {
				vildateDept = false;
				handlePrompt("error",'<spring:message code="user.manager.deteteFailed" />');
				var data = eval("("+request.responseText+")");
				appIds = data[0];
				catalogData = data[1].content;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid);
				$("#rankListPage").setPageData(opts_page, data[1].number,data[1].size, data[1].totalElements);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
				
			},
			success : function(data) {
				top.handlePrompt("success",'<spring:message code="user.manager.deteteSuccessed"/>');
			}
		});
		return vildateDept;
	}
	
	function renameDept(pId,id,name,rename){
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
		if(!validateInput(name)){
			top.handlePrompt("error","<spring:message code='organizationChart.rename.character.abnormal'/>");
			zTree.editName(getTreeNode());
			return;
		}else if(name.length == 0 || name.length>15) {
			top.handlePrompt("error","<spring:message code='organizationChart.ztree.rename.failed'/>");
			zTree.editName(getTreeNode());
			return;
		} 
		if(checkSameName(id,name)) {
			top.handlePrompt("error","<spring:message code='employee.dept.insamelevel.error'/>");
			var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
			name = treeObj.getSelectedNodes()[0].name;
	    	zTree.editName(getTreeNode());
			return;
		}
		//操作过快，未获取Pid
		if(pId == undefined || pId == "undefined" || pId == ""){
			top.handlePrompt("error",
			'<spring:message code="organizationChart.addDept.tooFast.error"/>');
			return;
		}
		if(id == undefined || id == "undefined"){
			createDept(pId,name);
		}else{
				$.ajax({
					type : "POST",
					url : "${ctx}/enterprise/admin/organize/modifyDeptName/"+id,
					data : {"parentid":pId,"name":name,"token":"${token}","rename":rename},
					error : function(request) {
							top.handlePrompt("error",
							'<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
							var zTree = $.fn.zTree.getZTreeObj("treeDemo");
							zTree.cancelEditName();
					},
					success : function() {
						top.handlePrompt("success",
										'<spring:message code="organizationChart.deptRename.successed"/>');
				}
			}); 
	}
}
	/**********名称长度小于16个字节且不为空***************/
	function checkNameLength(name){
		if(name.length > 0 && name.length < 16){
			return true;
		}else{
			handlePrompt("error",'<spring:message code="organizationChart.ztree.rename.failed" />');
			return false;
		}
	}
	function beforeRename(treeId, treeNode, newName) {
		return checkNameLength(newName);
	}
	function onRename(e, treeId, treeNode, isCancel) {
		showLog((isCancel ? "<span style='color:red'>":"") + "[ "+getTime()+" onRename ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name + (isCancel ? "</span>":""));
		renameDept(treeNode.pId,treeNode.id,treeNode.name);
	}
	/**********公司名称不能修改和删除，屏蔽rename和remove，button***************/
	function showRemoveBtn(treeId, treeNode) {
		if(treeNode.id<0){
			return false;
		}else{
			return true;
		}
	}
	function showRenameBtn(treeId, treeNode) {
		if(treeNode.id<0){
			return false;
		}else{
			return true;
		}
	}
	function showLog(str) {
		if (!log) log = $("#log");
		log.append("<li class='"+className+"'>"+str+"</li>");
		if(log.children("li").length > 8) {
			log.get(0).removeChild(log.children("li")[0]);
		}
	}
	function getTime() {
		var now= new Date(),
		h=now.getHours(),
		m=now.getMinutes(),
		s=now.getSeconds(),
		ms=now.getMilliseconds();
		return (h+":"+m+":"+s+ " " +ms);
	}

	var newCount = 1;
	function addHoverDom(treeId, treeNode) {
		var sObj = $("#" + treeNode.tId + "_span");
		if (treeNode.editNameFlag || $("#addBtn_"+treeNode.tId).length>0) return;
		var addStr = "<span class='button add' id='addBtn_" + treeNode.tId
			+ "' title=<spring:message code='organizationChart.add' /> onfocus='this.blur();'></span>";
		sObj.after(addStr);
		var btn = $("#addBtn_"+treeNode.tId);
		if (btn) btn.bind("click", function(){
			beforeCreateDept(treeNode.id,"department"+(newCount++),treeNode);
			return false;
		});
	};
	function removeHoverDom(treeId, treeNode) {
		$("#addBtn_"+treeNode.tId).unbind().remove();
	};
	function selectAll() {
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
		zTree.setting.edit.editNameSelectAll =  $("#selectAll").attr("checked");
	}
	/** 
	 * Transform data into treeNode Data
	 */  
	function getFirstTreeObj(dataObj,treeNodes){
	    for (var i = 0; i < dataObj.length; i++) {  
	        treeNodes.push({id:dataObj[i].id,pId:dataObj[i].pId,name:dataObj[i].name});  
	        loadChildObj(dataObj[i],treeNodes);  
	    }  
	} 
	$(document).ready(function(){
		/* set defaultNode for company--start*/
		var enpName = '${enterpriseName}',
		defRootNode = {id:"-1",pId:"-2",name:enpName,isParent:"true"},
		/* set defaultNode for company--end*/
		firstTreeNodes = eval(${deptTree});
		if(typeof firstTreeNodes==="undefined"){
			firstTreeNodes = [];
		}
		firstTreeNodes.push(defRootNode);
	/* 	for(var i in firstTreeNodes){
			if(firstTreeNodes[i].name.length>15){
				firstTreeNodes[i].name=firstTreeNodes[i].name.substr(0, 15)+"..."
			}
		} */
		var setting = {
				view: {
					addHoverDom: addHoverDom,
					removeHoverDom: removeHoverDom,
					selectedMulti: false
				},
				edit: {
					enable: true,
					editNameSelectAll: true,
					showRemoveBtn: showRemoveBtn,
					showRenameBtn: showRenameBtn,
					removeTitle :'<spring:message code="organizationChart.remove" />',
					renameTitle :'<spring:message code="organizationChart.rename" />'
				},
				data: {
					simpleData: {
						enable: true
					}
				},
				callback: {
					beforeDrag: beforeDrag,
					beforeEditName: beforeEditName,
					beforeRemove: beforeRemove,
					beforeRename: beforeRename,
					onRemove: onRemove,
					onRename: onRename,
					onClick: onClick
				}
			};
		
		$.fn.zTree.init($("#treeDemo"), setting, firstTreeNodes); 
	
		$("#treeContent2").css({height:"300px"});
		$("#selectAll").bind("click", selectAll);
	});
</SCRIPT>

<script type="text/javascript">
    var appIds = "";   
	var currentPage = 1;
	var newHeadItem = "";
	var newFlag = false;
	var opts_viewGrid = null;
	var opts_page = null;
	
	function isContainsAppId(arrBindAppIds, appId)
	{
		for(var i = 0; i < arrBindAppIds.length; i++)
		{
			if(appId == arrBindAppIds[i])
			{
				return true;
			}
		}
		return false;
	}
	
	function bindx(data){
	  $("#searchEnterUser").empty();
	  var objs = data[1].content;
	  for (var o in objs) { 
	      var jsonObj  =  objs[o]; 
	      var optionstring = "<option value=\"" + jsonObj.enterpriseId + "\" >" + jsonObj.name + "</option>"; 
	      $("#searchEnterUser").append(optionstring);          
      } 
	}

	function searchEnterUser(evt){
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/enterprise/admin/user/employeeManage";
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var params = {
			"page" : 1,
			"authServerId" : authServerId,
			"filter" : filter,
			"token" : "${token}",
			"dn" : dn,
			"newHeadItem":"",
			"newFlag":true
		};

		$.ajax({
			type : "POST",
			url : url,
			data : params,
			error : function(request) {
				handlePrompt("error",'<spring:message code="common.operationFailed" />');
			},
			success : function(data) {
				if(data[1].content.length>0){
					var obj = data[1].content;
		            var treeNodes = [];  
		            getTreeObj(obj,treeNodes); 
		            //set tree data
		            loadTreeData(treeNodes);
				}
				
			}
		});
		
	}
	
	function beforeCreateDept(id,name,treeNode) {
		
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
    	var array = zTree.addNodes(treeNode, { pId:id, name:name});
    	zTree.editName(array[array.length - 1]);
	
	}
	function createDept(id,name){
		var url="${ctx}/enterprise/admin/organize/addDepartment";
		var tt='${token}';
		$.ajax({
	        type: "POST",
	        url:url,
	        data:{parentid:id,name:name,token:tt},
	        error: function(request) {
	        	if(request.responseText === "ConflictException"){
					top.handlePrompt("error",
					'<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
				}else {
	        		handlePrompt("error",'<spring:message code="user.manager.createUserFailed"/>');
	        	}
	        },
	        success: function(data) {
	        	/*  给新增节点设置ID   */
	        	var curentnode=getTreeNode();
	    		curentnode["id"]=data;
	        	top.handlePrompt("success",
				'<spring:message code="createDept.createDeptSuccessed"/>');
	        }
	    });
	}
	
	function saveUser(tp) {
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.submitUser();
		} else {
			top.ymPrompt.close();
		}
	}

	function deleteUser() {
		var idArray = $("#rankList").getTableGridSelected();
		if (idArray == "") {
			handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
			return;
		}
		var ids;
		ids = idArray.join(",");
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var sNodes = treeObj.getSelectedNodes();
		var tId = -1;
		var isFirstNode=false;
		if (sNodes.length > 0) {
			isFirstNode = sNodes[0].isFirstNode;
			tId = sNodes[0].id;
		}
		var params;
		if(isFirstNode){
			params = {
					"filter" : filter,
					"dn" : dn,
					"authServerId" : authServerId,
					"ids":ids,
					"departmentId":tId,
					"token" : "${token}"
				};
		}else{
			params = {
				"filter" : filter,
				"dn" : dn,
				"authServerId" : authServerId,
				"ids":ids,
				"departmentId":null,
				"token" : "${token}"
			};
		}
		top.ymPrompt.confirmInfo({
					title : '<spring:message code="user.manager.deleteUser"/>',
					message : '<spring:message code="user.manager.deleteUser"/>'
							+ '<br/>'
							+ '<spring:message code="user.manager.deleteDescription"/>',
					width : 450,
					closeTxt : '<spring:message code="common.close"/>',
					handler : function(tp) {
						if (tp == "ok") {
							deleteUsers(params);
						}
					},
					btn : [
							[ '<spring:message code="common.OK"/>', "ok" ],
							[ '<spring:message code="common.cancel"/>',
									"cancel" ] ]
				});
	}

	function deleteUsers(params) {
		$.ajax({
					type : "POST",
					url : "${ctx}/enterprise/admin/organize/delete",
					data : params,
					error : function(request) {
						top.handlePrompt("error",
										'<spring:message code="user.manager.deleteFailed"/>');
					},
					success : function() {
						top.handlePrompt("success",
										'<spring:message code="user.manager.deteteSuccessed"/>');
						refreshWindow();
					}
				});
	}

	function createSync() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var params = {
			"token" : "${token}"
		};
		$.ajax({
					type : "POST",
					url : "${ctx}/enterprise/admin/ldapuser/syncUsers/" + authServerId,
					data : params,
					error : function(request) {
						top.handlePrompt("error",
										'<spring:message code="user.manager.syncUserFailed"/>');
					},
					success : function() {
						top.handlePrompt("success",
										'<spring:message code="user.manager.syncUserSuccessed"/>');
						refreshWindow();
					}
				});
	}

	
	function refreshWindow() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		window.location = "${ctx}/enterprise/admin/organize/enterDeptTreeManage/0";
	}

	function exportUser() {
		
		var authServerId = $("#authenticationMethod").find("option:selected").val();
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
			var url = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId+"/0"+"/"+dn+"/"+filter;
			window.location = url;
			return;
		}else{
			var url = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId+"/0"+"/"+dn+"/"+filter;
			window.location = url;
		}
	}

	function importUser() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/import/enterprise/admin/user/enterImportEmployees/" + authServerId;
		top.ymPrompt.win({
			message : url,
			width : 900,
			height : 500,
			title : '<spring:message code="user.manager.exportUser"/>',
			iframe : true,
			handler : uploadImportUserCsvFile
		});
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
		});
		
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
        url:"${ctx}/enterprise/admin/ldapuser/initTreeName/"+authServerId,
        data : params,
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

function openAccount(){
	var idArray = $("#rankList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
		return;
	}
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	top.ymPrompt.win({
		message:'${ctx}/enterprise/admin/user/listEnterpriseAccount/' + authServerId,
		width:700,
		height:430,
		title:'<spring:message code="employeeManage.open.account"/>', 
		iframe:true,
		btn:[
		     ['<spring:message code="employeeManage.open.account"/>','yes',false,"btn-focus"],
		     ['<spring:message code="common.cancel"/>','no',true,"btn-cancel"]],
		     handler:doOpenAccount});
	top.ymPrompt_addModalFocus("#btn-focus");
}

function doOpenAccount(tp) {
	var idArray = $("#rankList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
		return;
	}
	var ids = idArray.join(",");
	
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	var filter = $("#filter").val();
	var dn = $("#dn").val();
	if (tp == 'yes') {
		top.ymPrompt.getPage().contentWindow.submitOpenAccount(ids, authServerId, filter, dn);
	} else {
		top.ymPrompt.close();
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
		$("#createDeptBtn").show();
	    $("#buttonDnName").hide();
		$("#createSyncBtn").hide();
		$("#syncLogBtn").hide();
		$("#deleteUserBtn").show();
		$("#importUserBtn").show();
		$("#exportUserBtn").show();
		$("#clearUserBtn").hide();
	}
	else
	{
		$("#createDeptBtn").hide();
		$("#buttonDnName").show();
		$("#createSyncBtn").show();
		$("#syncLogBtn").show();
		$("#deleteUserBtn").hide();
		$("#importUserBtn").hide();
		$("#exportUserBtn").show();
		$("#clearUserBtn").show();
	}
	initDataList(1, "", false);
}

function getDeleteUserManager(){
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	window.location = "${ctx}/enterprise/admin/ldapuser/enterDeleteUsers/" + authServerId;
}

function enterSyncUserLog(){
    var authServerId = $("#authenticationMethod").find("option:selected").val();
    window.location = "${ctx}/enterprise/admin/ldapuser/enterSyncUserLog/" + authServerId;
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


<script type="text/javascript">
    var appIds = "";   
	var currentPage = 1;
	var newHeadItem = "";
	var newFlag = false;
	var opts_viewGrid = null;
	var opts_page = null;
	var headData = {
		"name" : {
			"title" : "<spring:message code='user.manager.loginName'/>",
			"width" : "30%",
			"taxis":true
		},
		"alias" : {
		"title" : "<spring:message code='user.manager.name'/>",
		"width" : "30%",
		"taxis":true
		},
		
		"departmentName" : {
		"title" : "<spring:message code='enterprise.employee.dept.lable'/>",
		"width" : "30%"
		}
	};
	$(document).ready(function() {
		opts_viewGrid = $("#rankList").comboTableGrid({
			headData : headData,
			checkBox : true,
			checkAll : true,
			height : 550,
			dataId : "id",
			string : {
				checkAllTxt : "<spring:message code='grid.checkbox.selectAll'/>",
				checkCurPageTxt : "<spring:message code='grid.checkbox.selectCurrent'/>"
			},
			taxisFlag : true
		});
		$.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
			switch (colIndex) {
			case "alias":
				try {
					var alisa = tdItem.find("p").text();
					if (alisa == "") {
						tdItem.find("p").html("-").parent().attr("title","-");
					}
				} catch (e) {
				}
				break;
			
			case "departmentName":
				try {
					var departmentName = tdItem.find("p").text();
					if (departmentName == "") {
						tdItem.find("p").html("<spring:message code='enterprise.employee.dept.unspecified'/>").parent().attr("title","-");
					}
				} catch (e) {
				}
				break;
			case "option":
				try {
					var departmentName = tdItem.find("p").text();
					if (departmentName == "") {
						tdItem.find("p").html("<spring:message code='enterprise.employee.dept.unspecified'/>").parent().attr("title","-");
					}
				} catch (e) {
				}
				break;
			case "description":
				try {
					var description = tdItem.find("p").text();
					if (description == "") {
						tdItem.find("p").html("-").parent().attr("title","-");
					}
				} catch (e) {
				}
				break;
			case "authAppIdList":
				try {
					var allBindAppIds="";
					var bindAppIds = tdItem.find("p").text();
					var arrAppIds  = "";
					if("" !=  appIds)
					{
						arrAppIds  = appIds.split(',');
					}
					var arrBindAppIds = bindAppIds.split(',');
					for(var i=0; i<arrAppIds.length; i++)
					{
						if(isContainsAppId(arrBindAppIds, arrAppIds[i]))
						{
							if(i == 0)
							{
								allBindAppIds+=arrAppIds[i];	
							}
							else
							{
								allBindAppIds+=", "+arrAppIds[i];
							}
							
						}else{
							if(i == 0)
							{
								allBindAppIds+=arrAppIds[i]+"<span class=\"font_gray\">(<spring:message  code='employeeManage.not.open.account'  />)</span>";							
							}
							else
							{
								allBindAppIds+=", "+arrAppIds[i]+"<span class=\"font_gray\">(<spring:message  code='employeeManage.not.open.account'  />)</span>";	
							}
						}
					}
					if (allBindAppIds == "") {
						tdItem.find("p").html("-").parent().attr("title","-");
					}
					else
					{
						var obj = tdItem.find("p").html(allBindAppIds);
						var valueText = tdItem.find("p").text();
						obj.parent().attr("title",valueText);
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

		opts_page = $("#rankListPage").comboPage({
			style : "page table-page",
			lang : '<spring:message code="main.language"/>'
		});

		$.fn.comboPage.pageSkip = function(opts, _idMap, curPage) {
			initDataList(curPage, newHeadItem, newFlag);
		};
		
		changeAuthType();
		
		if (!placeholderSupport()) {
			placeholderCompatible();
		};
		
		$("#searchButton").on("click",function(){
			initDataList(currentPage, newHeadItem, newFlag);
		});	
		
		$("#filter").keydown(function(){
			var evt = arguments[0] || window.event;
			if(evt.keyCode == 13){
				searchEnterUser(evt);
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
	
	function isContainsAppId(arrBindAppIds, appId)
	{
		for(var i = 0; i < arrBindAppIds.length; i++)
		{
			if(appId == arrBindAppIds[i])
			{
				return true;
			}
		}
		return false;
	}
	
	function initDataList(curPage, headItem, flag) {
		currentPage = curPage;
		newHeadItem = headItem;
		newFlag = flag;
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/enterprise/admin/user/employeeManage";
		var filter = $("#filter").val();
		var dn = $("#dn").val();
		var deptId = getTreeId();
		
		var params = {
			"page" : curPage,
			"authServerId" : authServerId,
			"filter" : filter,
			"token" : "${token}",
			"dn" : dn,
			"newHeadItem":newHeadItem,
			"newFlag":newFlag,
			"deptId":deptId
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
				appIds = data[0];
				catalogData = data[1].content;
				$("#rankList").setTableGridData(catalogData, opts_viewGrid);
				$("#rankListPage").setPageData(opts_page, data[1].number,data[1].size, data[1].totalElements);
				var pageH = $("body").outerHeight();
				top.iframeAdaptHeight(pageH);
			}
		});
	}
   
	function cleanPge(){
		$("#treeContent").fadeOut("fast");
		$("#filter").val("");
		$("#storeIds").val("");
		
	}
	
	function deptAddEnterpriseUser() {
		var enterpriseUserId = $("#storeIds").val();
		if(enterpriseUserId == "" || enterpriseUserId==null){
			top.handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.noExist"/>');
			return;
		}
		var deptId = getTreeId();
		if(deptId<0){
			top.handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.noDept"/>');
			return;
		}
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var params = {
			"token" : "${token}",
			"enterpriseUserId" : enterpriseUserId,
			"deptId" : deptId
		};
		$.ajax({
					type : "POST",
					url : "${ctx}/enterprise/admin/organize/deptAddEnterpriseUser",
					data : params,
					error : function(request) {
						if(request.responseText === "ConflictException"){
							top.handlePrompt("error",
							'<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
						}else{
							top.handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
						}
					},
					success : function() {
						cleanPge();
						top.handlePrompt("success",'<spring:message code="organizationChart.addEnterpriseUser.successed"/>');
						onClick();
						
					}
				});
		
	}
	
	function saveUser(tp) {
		if (tp == 'yes') {
			top.ymPrompt.getPage().contentWindow.submitUser();
		} else {
			top.ymPrompt.close();
		}
	}
	
	/* function refreshWindow() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		window.location = "${ctx}/enterprise/admin/user/employeeManage/"+authServerId;
	} */

	function exportUser() {
		
		var authServerId = $("#authenticationMethod").find("option:selected").val();
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
			var url = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId+"/0"+"/"+dn+"/"+filter;
			window.location = url;
			return;
		}else{
			var url = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId+"/0"+"/"+dn+"/"+filter;
			window.location = url;
		}
	}

	function importUser() {
		var authServerId = $("#authenticationMethod").find("option:selected").val();
		var url = "${ctx}/import/enterprise/admin/user/enterImportEmployees/" + authServerId;
		top.ymPrompt.win({
			message : url,
			width : 900,
			height : 500,
			title : '<spring:message code="user.manager.exportUser"/>',
			iframe : true,
			handler : uploadImportUserCsvFile
		});
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
		});
		
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

function getDeleteUserManager(){
	var authServerId = $("#authenticationMethod").find("option:selected").val();
	window.location = "${ctx}/enterprise/admin/ldapuser/enterDeleteUsers/" + authServerId;
}

function enterSyncUserLog(){
    var authServerId = $("#authenticationMethod").find("option:selected").val();
    window.location = "${ctx}/enterprise/admin/ldapuser/enterSyncUserLog/" + authServerId;
}

//For Search user
var submitUsername = null;
function userOnPaste(){
		$(".enterPrompt").hide();
		setTimeout(function() { 
			submitUsername = $("#messageAddr").val();
			userInputAutoSize("#messageAddr");
			searchMessageTo();
		}, 0);
	}
function userInputAutoSize(that){
	var tempObj = $("#enterTempData"),
		_obj = $(that).parent().find("div.invite-member:last"),
		posCon = $("#inviteCollaborator").offset().left +5,
		posInput = _obj.get(0) ? (_obj.offset().left + _obj.outerWidth() + 5) : posCon,
		userConW = 525,
		tempW = 0,
		space = userConW - parseInt(posInput-posCon),
		thatParent = $(that).parent().get(0);
	var tempValue = $(that).val().replace(new RegExp(" ", "g"),"&nbsp;");
	tempValue = tempValue.replace(new RegExp("<", "g"),"&lt;");		
	tempObj.html(tempValue);
	tempW = tempObj.width();
	if((tempW+5) > space || $(that).get(0).scrollHeight > 20){
		$(that).css({"width" : userConW });
		$(that).height(0);
		$(that).css({"height" : $(that).get(0).scrollHeight });
		thatParent.scrollTop = thatParent.scrollHeight;
	}else{
		$(that).css({"width" : space, "height" : 20 });
	}
	
	var conH = parseInt($(".pop-content").outerHeight()+90);
	top.ymPrompt.resizeWin(650,conH);
}


</script>
<script type="text/javascript">
	function displayDeptTree(evt){
		var disAttr=$("#treeContent")[0].style.display;
		if(disAttr==="none"){
			stopDefaultAndBubble(evt);
			showNodeTree();
		}
	}
	
	function stopDefaultAndBubble(evt){
		if(window.event){
			window.event.cancelBubble = true;
			window.event.returnValue = false;
		}else{
			evt.stopPropagation();
			evt.preventDefault();
		}
	}
	
	/* 
	 * 下拉树的设置 
	 */  
	var deviceTypeSetting = {  
	    view: {  
	        dblClickExpand: true  
	    },  
	    data: {  
	        simpleData: {  
	            enable: true  
	        }
	    },  
	    callback: {  
	        onClick: deviceTypeOnClick,
	        onCheck: nodeOnRadio
	    },
	    check : {
	    	autoCheckTrigger : false,
	    	chkboxType : {"Y": "", "N": ""},
	    	chkStyle : "checkbox",
	    	enable : true,
	    	nocheckInherit : false,
	    	chkDisabledInherit:false,
	    	radioType : "all"
	    	}
	};  
	
	var chkedNodes;
	function nodeOnRadio(e,treeId,treeNode){
		var chkedNodeIdAry =new Array(),chkedNodeNmAry =new Array();
		var zTree = $.fn.zTree.getZTreeObj("menuTree");  
		
		chkedNodes = zTree.getCheckedNodes(true);
		 $(chkedNodes).each(function(index,item){
			chkedNodeIdAry.push(item.id);
			chkedNodeNmAry.push(item.name);
		 });
	    $("#storeIds").val(chkedNodeIdAry.join(","));
	    //$("#filter").attr("value",chkedNodeNmAry.join(","));
	   document.getElementById("filter").value=chkedNodeNmAry.join(",");
	    
	}
	
	/* 
	 * 下拉树的点击事件 
	 */  
	function deviceTypeOnClick(e, treeId, treeNode) {
	    var zTree = $.fn.zTree.getZTreeObj("menuTree");  
	}  
	
	/* 
	 * 初始化设备类型 
	 *  
	 */  
	function initTreeNode(){  
		$.ajax({  
			url:'${ctx}/enterprise/admin/organize/listDeptTree',  
	        type:'GET',  
        	async:false,  
        	success:function(msg){  
	            var obj = eval("("+msg+")");  
	            var deviceTypeNodes = [];  
	            getDevTypeObj(obj,deviceTypeNodes);  
	            ($("#menuTree"), deviceTypeSetting, deviceTypeNodes);  
        	}  
    	});  
	}
	
	/* 
	 * 展示SelectTree 
	 */  
	function showNodeTree(){
	    $.ajax({  
	        url:'${ctx}/enterprise/admin/organize/listDeptTree',  
	        type:'GET',  
	        async:true,  
	        success:function(msg){
	            var obj = eval("("+msg+")");  
	            var treeNodes = [];  
	            getTreeObj(obj,treeNodes); 
	            //set tree data
	            loadTreeData(treeNodes);
	        },
	        error:function(){
		       
	        }
	    });
	}

	//To set treeNodes data
	function loadTreeData(treeNodes){
		$.fn.zTree.init($("#menuTree"), deviceTypeSetting, treeNodes);  
		var deptObj = $("#filter"),  
	    	deptOffset = $("#filter").offset();  
	   	$("#treeContent").css({left:deptOffset.left-20 + "px", top:deptOffset.top-99 + deptObj.outerHeight() + "px"}).slideDown("fast");  
//	    $('#menuTree').css({width:deptObj.outerWidth() - 12 + "px"});  
	    
	    var zTree = $.fn.zTree.getZTreeObj("menuTree"),  
	    	nodeIds = $('#storeIds').val(),
	    	nodeIdAry = nodeIds.split(",");
	    if(nodeIdAry.length>0 && nodeIdAry[0]!=""){
	    	$.each(nodeIdAry,function(index,item,nodeIdAry){
			    var node = zTree.getNodeByParam("id", item, null)  
			    zTree.selectNode(node);
			    zTree.checkNode(node);
	    	});
	    }
	    $("body").bind("mousedown", onBodyDownByDevType);
	    $("body").bind("click",hidenSwitch);
	    document.onkeydown=function(){
	    	if(window.event.keyCode == 9){ 
	    		var isContain = hidenSwitch(event);
	    		if(isContain){
	    			 hideDeviceTypeMenu();
	    		}
	    	}
	    }
	}
	
	function hidenSwitch(e) {
		var child = e.target;
		var parent = document.getElementById("deptSectionDiv");
        var parentNode;
        if(child && parent) {
            parentNode = child.parentNode;
            while(parentNode) {
                if(parent === parentNode) {
                    return true;
                }
                parentNode = parentNode.parentNode;
            }
        }
        hideDeviceTypeMenu();
        return false;
    }
	/** 
	 * Transform data into treeNode Data
	 */  
	function getTreeObj(dataObj,treeNodes){
	    for (var i = 0; i < dataObj.length; i++) {  
	        treeNodes.push({id:dataObj[i].id,pId:dataObj[i].enterpriseId,name:dataObj[i].name});  
	    }
	}  
	
	/** 
	 * 查找子节点 
	 */  
	function loadChildObj(dataObj,treeNodes){  
	    var childObj = dataObj.children;  
	    for(var j = 0; j < childObj.length; j++){  
	        treeNodes.push({id:childObj[j].id,pId:childObj[j].pId,name:childObj[j].name});  
	        loadChildObj(childObj[j],treeNodes);  
	    }  
	}  
	/* 
	 * Body鼠标按下事件回调函数 
	 */  
	function onBodyDownByDevType(event) {
	    if(event.target.id.indexOf('switch') == -1){  
	      // hideDeviceTypeMenu();  
	    }  
	}  
	
	/* 
	 * 隐藏Tree 
	 */  
	function hideDeviceTypeMenu() {
	    $("#treeContent").fadeOut("fast");  
	    $("body").unbind("mousedown", onBodyDownByDevType);
	    $("body").unbind("click",hidenSwitch);
	}   


	function submitUser(){
		if(!isValidLoginName()){
			return;
		}
		if(!$("#creatUserForm").valid()) {
	        return;
	    }
		var url="${ctx}/enterprise/admin/user/createUser/"+"<c:out value='${authServerId}'/>";
		$.ajax({
	        type: "POST",
	        url:url,
	        data:$('#creatUserForm').serialize(),
	        error: function(request) {
	        	var status = request.status;
	        	if (status == 409) {
	        		handlePrompt("error",'<spring:message code="createEnterprise.conflict.name.email"/>');
	        	} else {
	        		handlePrompt("error",'<spring:message code="user.manager.createUserFailed"/>');
	        	}
	        },
	        success: function() {
	        	top.ymPrompt.close();
	        	top.handlePrompt("success",'<spring:message code="user.manager.createUserSuccessed"/>');
	        	refreshWindow();
	        }
	    });
	}

	function checkValidLoginName(){
		var ret = false;
		   $.ajax({
		        type: "POST",
		        async: false,
		        url:"${ctx}/enterprise/admin/user/validLoginName",
		        data:$("#creatUserForm").serialize(),
		        success: function(data) {
		        	ret = true;
		        }
		    });
	    return ret;
	}

	function isValidLoginName(){
		if(!checkValidLoginName()){
			$("#isValidLoginName").removeAttr("style"); 
			$("#isValidLoginNameSpan").removeAttr("style"); 
			$("#isValidLoginName").html("<spring:message code='enterprise.user.login.name'/>"); 
		    return false;
		}
		$("#isValidLoginName").attr("style","display: none"); 
		return true;
	}
</script>


<script type="text/javascript">
 	// 判断同级目录树下有是否有相同名称
 	// 参数： id 	  选中节点主鍵， 
 	// 		name 选中节点名称
 	// 返回值：有：true，无：false
	function checkSameName(id,name) {
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var selNode = treeObj.getSelectedNodes()[0];
		var parNode = selNode.getParentNode();
		var length = parNode.children.length;
		for(var i=0 ; i<length; i++) {
			// 如果是自身节点就不用比较了
			if(name ==  parNode.children[i].name && id != parNode.children[i].id) {
				return true;
			}
		}
		return false;		
	};
</script>
</html>
