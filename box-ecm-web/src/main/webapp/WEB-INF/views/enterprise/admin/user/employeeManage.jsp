<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));%>

<div class="sys-content">
	<div class="clearfix">
		<div class="form-search">
			<input type="hidden" id="page" name="page" value="1"/>
			<div class="pull-left">
				<select class="span3 width-w180" id="authenticationMethod" name="authenticationMethod" onchange="changeAuthType()">
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

			<div class="pull-left folderTreeCon" >
				<input type="hidden" id="dn" name="dn" value="<c:out value='${dn}'/>"/>
				<input type="hidden" id="dnName" name="dnName" value="<c:out value='${dnName}'/>"/>
				<button type="button" class="btn" onClick="initTreeName()" id="buttonDnName">
	                    <span class="selectTreeName">
							<c:if test="${empty dnName}"><spring:message code="user.manager.ldap.node"/></c:if>
	                     	<c:if test="${not empty dnName}"><c:out value='${dnName}'/></c:if>
	                    </span>
					<i class="icon-caret-down"></i>
				</button>
				<ul id="treeArea" class="ztree"></ul>
			</div>
			
			<div class="pull-left" style="margin-left: 25px">
				<select class="span3 width-w180" id="type">
				    <option value="-1">所有员工</option>
				    <option value="0">游客</option>
				    <option value="1">部门主管</option>
				    <option value="2">一般员工</option>
				    <option value="3">外协人员</option>
				</select>
			</div>
			<c:if test="${isOrganizeEnabled == true}">
				<div id="deptSectionDiv" class="pull-left filterDeptTree" >
					<input name="departmentIds" id="deptIdInput" type="hidden"/>
					<button type="button" class="btn" id="selectNode" style="width: 180px">
		                    <span class="selectTreeName" id="deptDisplay" name="deptDisplay">
		                    	<spring:message code="employee.dept.default.all"/>
		                    </span>
						<div>
							<i class="icon-caret-down"></i>
						</div>
					</button>
						<%--溢出方式设置为hidden，auto会出现滚动条 --%>
					<div id="treeContent" class="treeMenuDiv" style="display: none">
                        <ul id="menuTree" class="ztree"></ul>
					</div>
				</div>
			</c:if>

			<div class="pull-left input-append">
				<input type="text" id="filter" name="filter" class="span3 search-query" value="${filter}" placeholder='<spring:message code="user.manager.searchDescription"/>' />
			</div>
			<div class="pull-left">
				<button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
			</div>
			<input type="hidden" id="token" name="token" value="${token}"/>
		</div>

		<%-- <div class="control-group">
            <div class="controls" id=deptSectionDiv>
                    <div>
                       <select id="selectNode" >
                         <option selected name="departmentNames" style="display:none"><spring:message code="employee.dept.default.all"/></option>
                     </select>
                    <input name="departmentIds" id="deptIdInput" type="hidden" class="selectDevTypeid"/>
                    <div id="treeContent" class="selectDevTypeid" style="display: none; position: absolute; border: 1px #CCC solid; background-color: white;">
                        <ul id="menuTree" class="ztree" style="margin-top:0;"></ul>
                    </div>
                   </div>
                <div class="input-append">
                    <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
               </div>
           </div>
        </div> --%>

	</div>

	<div class="clearfix table-con">
        <div id="rankList"></div>
        <div id="rankListPage"></div>
	</div>
	<div class="ta 	ble-con" style="margin-top: 10px">
        <div class="pull-left">
            <div class="btn-group">
                <button type="button" class="btn btn-primary" onclick="createUser()" id="createUserBtn">
                    <i class="icon-plus"></i>
                    <spring:message code="common.create" />
                </button>
            </div>

            <div class="btn-group">
                <button type="button" class="btn" onclick="createSync()" id="createSyncBtn">
                    <spring:message code="user.manager.syncUser" />
                </button>
                <button type="button" class="btn" onclick="enterSyncUserLog()" id="syncLogBtn">
                    <spring:message code="enterprise.user.sync.log.title" />
                </button>
               <%--  <button type="button" class="btn" onClick="openAccount()">
                    <spring:message code="enterpriseAdmin.employee.open.account" />
                </button> --%>
                <button type="button" class="btn" onClick="deleteUser()" id="deleteUserBtn">
                    <spring:message code="common.delete" />
                </button>
				<button type="button" class="btn" onClick="resetUserPassword()" id="resetPasswordBtn">
					<spring:message code="anon.pwd.reset" />
				</button>
            </div>

            <div class="btn-group">
                <button type="button" class="btn" onClick="importUser()" id="importUserBtn">
                    <spring:message code="user.manager.export" />
                </button>
                <button type="button" class="btn" onClick="exportUser()" id="exportUserBtn">
                    <spring:message code="user.manager.exportOut" />
                </button>
            </div>

            <div class="btn-group">
                <button type="button" class="btn" onClick="getDeleteUserManager()" id="clearUserBtn">
                    <spring:message code="employeeManage.clear.user"/>
                </button>
                <button type="button" class="btn" onClick="setLeaveStatus()" id="departureBtn">
                    <spring:message code="departure.btn.leave"/>ְ
                </button>

                <button type="button" class="btn" onClick="showMigrateDataUI()" id="dataMigrationBtn">
                    <spring:message code="departure.btn.migration.data"/>
                </button>

                <c:if test="${isOrganizeEnabled == true}">
                    <button type="button" class="btn" onClick="changeUserDept()" id="chgDeptBtn">
                        <spring:message code="enterprise.employee.dept.switch" />
                    </button>
                </c:if>
            </div>

            <div class="btn-group">
                <button type="button" class="btn" onClick="setSecurityClassification()" id="setSecurityBtn">
                    <spring:message code="enterprise.user.security.classification.set"/>
                </button>
            </div>
        </div>
	</div>
	<input type="hidden" id="storField" value="id" />
	<input type="hidden" id="storDirection" value="true" />
</div>

<script type="text/javascript">
    var appIds = "";
    var currentPage = 1;
    var newHeadItem = "";
    var newFlag = false;
    var opts_viewGrid = null;
    var opts_page = null;
    var userDatas;
    var headData = {
        "name": {
            "title": "<spring:message code='user.manager.loginName'/>",
            "width": "15%",
            "taxis": true
        },
        "alias": {
            "title": "<spring:message code='user.manager.name'/>",
            "width": "15%",
            "taxis": true
        },
        "email": {
            "title": "<spring:message code='user.manager.email'/>",
            "width": "15%",
            "taxis": true
        },
        "mobile": {
            "title": "<spring:message code='enterpriseList.contactPhone'/>",
            "width": "15%"
        },
        "departmentName": {
            "title": "<spring:message code='enterprise.employee.dept.lable'/>",
            "width": "15%"
        },
        "description": {
            "title": "<spring:message code='common.description'/>",
            "width": "auto",
            "taxis": true
        },
        "authAppIdList": {
            "title": "<spring:message code='header.app'/>",
            "width": "15%"
        },
        "status": {
            "title": "<spring:message code='enterprise.user.status.title'/>",
            "width": "15%",
            "dataId": "status",
            "hideHeader": false
        }, 
        "type": {
            "title": "员工类型",
            "width": "10%",
            "dataId": "type",
            "hideHeader": false
        }
        
    };

    //if unsupport organize, remove department
    if (!${isOrganizeEnabled}) {
        delete headData.departmentName;
    }

    $(document).ready(function () {
        opts_viewGrid = $("#rankList").comboTableGrid({
            headData: headData,
            checkBox: true,
            checkAll: true,
            dataId: "id",
            string: {
                checkAllTxt: "<spring:message code='grid.checkbox.selectAll'/>",
                checkCurPageTxt: "<spring:message code='grid.checkbox.selectCurrent'/>"
            },
            taxisFlag: true
        });
        $.fn.comboTableGrid.setItemOp = function (tableData, rowData, tdItem, colIndex) {
            switch (colIndex) {
                case "alias":
                    try {
                        var alisa = tdItem.find("p").text();
                        if (alisa == "") {
                            tdItem.find("p").html("-").parent().attr("title", "-");
                        }
                    } catch (e) {
                    }
                    break;
                /* case "mobile":
                 try {
                 var mobile = tdItem.find("p").text();
                 if (mobile == "") {
                 tdItem.find("p").html("-").parent().attr("title","-");
                 }
                 } catch (e) {
                 }
                 break; */
                case "departmentName":
                    try {
                        var departmentName = tdItem.find("p").text();
                        if (departmentName == "") {
                            tdItem.find("p").html("<spring:message code='enterprise.employee.dept.unspecified'/>").parent().attr("title", "-");
                        }
                    } catch (e) {
                    }
                    break;
                case "description":
                    try {
                        var description = tdItem.find("p").text();
                        if (description == "") {
                            tdItem.find("p").html("-").parent().attr("title", "-");
                        }
                    } catch (e) {
                    }
                    break;
                case "authAppIdList":
                    try {
                        var allBindAppIds = "";
                        var bindAppIds = tdItem.find("p").text();
                        var arrAppIds = "";
                        if ("" != appIds) {
                            arrAppIds = appIds.split(',');
                        }
                        var arrBindAppIds = bindAppIds.split(',');
                        for (var i = 0; i < arrAppIds.length; i++) {
                            if (isContainsAppId(arrBindAppIds, arrAppIds[i])) {
                                if (i == 0) {
                                    allBindAppIds += arrAppIds[i];
                                }
                                else {
                                    allBindAppIds += ", " + arrAppIds[i];
                                }

                            } else {
                                if (i == 0) {
                                    allBindAppIds += arrAppIds[i] + "<span class=\"font_gray\">(<spring:message  code='employeeManage.not.open.account'  />)</span>";
                                }
                                else {
                                    allBindAppIds += ", " + arrAppIds[i] + "<span class=\"font_gray\">(<spring:message  code='employeeManage.not.open.account'  />)</span>";
                                }
                            }
                        }
                        if (allBindAppIds == "") {
                            tdItem.find("p").html("-").parent().attr("title", "-");
                        }
                        else {
                            var obj = tdItem.find("p").html(allBindAppIds);
                            var valueText = tdItem.find("p").text();
                            obj.parent().attr("title", valueText);
                        }
                    } catch (e) {
                    }
                    break;

                case "status":
                    try {
                        var status = tdItem.find("p").text();
                        if (!status) {
                            tdItem.find("p").html("-").parent().attr("title", "-");
                        } else {
                            switch (status) {
                                case "0":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.normal'/>");
                                    break;
                                case "9":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.being.entry'/>");
                                    break;
                                case "8":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.intrial'/>");
                                    break;
                                case "7":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.leave.processing'/>");
                                    break;
                                case "6":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.data.migrated'/>");
                                    break;
                                case "5":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.account.migrated'/>");
                                    break;
                                case "4":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.departured'/>");
                                    break;
                                case "3":
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.retired'/>");
                                    break;
                                default:
                                    tdItem.find("p").empty().text("<spring:message code='enterprise.user.status.exception'/>");
                                    break;
                            }
                        }
                    } catch (e) {
                    }
                    break;
                case "type":
                	 var type = tdItem.find("p").text();
                	 switch (type) {
	                	 case "0":
	                         tdItem.find("p").empty().text("游客");
	                         break;
	                	 case "1":
	                         tdItem.find("p").empty().text("部门主管");
	                         break;
	                	 case "2":
	                         tdItem.find("p").empty().text("普通员工");
	                         break;
	                	 case "3":
	                         tdItem.find("p").empty().text("外协人员");
	                         break;
	                	 default:
	                         break;
                	 }
                default:
                    break;
            }
        };

        $.fn.comboTableGrid.taxisOp = function (headItem, flag) {
            initDataList(currentPage, headItem, flag);
        };

        opts_page = $("#rankListPage").comboPage({
            style: "page table-page",
            lang: '<spring:message code="main.language"/>'
        });

        $.fn.comboPage.pageSkip = function (opts, _idMap, curPage) {
            initDataList(curPage, newHeadItem, newFlag);
        };

        changeAuthType();

        if (!placeholderSupport()) {
            placeholderCompatible();
        }

        $("#searchButton").on("click", function () {
            initDataList(currentPage, newHeadItem, newFlag);
        });
        $("#type").on("change", function () {
            initDataList(currentPage, newHeadItem, newFlag);
        });

        $("#filter").keydown(function () {
            var evt = arguments[0] || window.event;
            if (evt.keyCode == 13) {
                initDataList(currentPage, newHeadItem, newFlag);
                if (window.event) {
                    window.event.cancelBubble = true;
                    window.event.returnValue = false;
                } else {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }
        });

    });

    function isContainsAppId(arrBindAppIds, appId) {
        for (var i = 0; i < arrBindAppIds.length; i++) {
            if (appId == arrBindAppIds[i]) {
                return true;
            }
        }
        return false;
    }

    var catalogData;
    function initDataList(curPage, headItem, flag) {
        currentPage = curPage;
        newHeadItem = headItem;
        newFlag = flag;
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/employeeManage";
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var deptId = $("#deptIdInput").val();
        var type= $("#type").val();
        var params = {
            "page": curPage,
            "authServerId": authServerId,
            "filter": filter,
            "token": "${token}",
            "dn": dn,
            "deptId": deptId,
            "newHeadItem": newHeadItem,
            "newFlag": newFlag,
            "type":type
        };

        $("#rankList").showTableGridLoading();
        $.ajax({
            type: "POST",
            url: url,
            data: params,
            error: function (request) {
                handlePrompt("error", '<spring:message code="common.operationFailed" />');
            },
            success: function (data) {
                appIds = data[0];
                catalogData = data[1].content;
                $("#rankList").setTableGridData(catalogData, opts_viewGrid);
                $("#rankListPage").setPageData(opts_page, data[1].number, data[1].size, data[1].totalElements);
                var pageH = $("body").outerHeight();
                top.iframeAdaptHeight(pageH);
            }
        });
    }

    function createUser() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/createUser/" + authServerId;
        top.ymPrompt.win({
            message: url,
            width: 800,
            height: 600,
            title: '<spring:message code="enterpriseAdmin.employee.add"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.create"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]
            ],
            handler: saveUser
        });
        top.ymPrompt_addModalFocus("#btn-focus");
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
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }
        var ids;
        if (idArray == "all") {
            ids = "all";
        }
        else {
            ids = idArray.join(",");
        }
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var params = {
            "filter": filter,
            "dn": dn,
            "authServerId": authServerId,
            "ids": ids,
            "token": "${token}"
        };
        top.ymPrompt.confirmInfo({
            title: '<spring:message code="user.manager.deleteUser"/>',
            message: '<spring:message code="user.manager.deleteUser"/>'
            + '<br/>'
            + '<spring:message code="user.manager.deleteDescription"/>',
            width: 450,
            closeTxt: '<spring:message code="common.close"/>',
            handler: function (tp) {
                if (tp == "ok") {
                    deleteUsers(params);
                }
            },
            btn: [
                ['<spring:message code="common.OK"/>', "ok"],
                ['<spring:message code="common.cancel"/>',
                    "cancel"]]
        });
    }

    function deleteUsers(params) {
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/user/delete",
            data: params,
            error: function (request) {
                top.handlePrompt("error",
                    '<spring:message code="user.manager.deleteFailed"/>');
            },
            success: function () {
                top.handlePrompt("success",
                    '<spring:message code="user.manager.deteteSuccessed"/>');
                refreshWindow();
            }
        });
    }

    function resetUserPassword() {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == []) {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }
        var ids;
        if (idArray == "all") {
            ids = "all";
        }
        else {
            ids = idArray.join(",");
        }
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var params = {
            "filter": filter,
            "dn": dn,
            "authServerId": authServerId,
            "ids": ids,
            "token": "${token}"
        };
        top.ymPrompt.confirmInfo({
            title: '<spring:message code="user.pwd.reset"/>',
            message: '<spring:message code="anon.resetPwdConfirm"/>',
            width: 450,
            closeTxt: '<spring:message code="common.close"/>',
            handler: function (tp) {
                if (tp == "ok") {
                    doResetUserPassword(params);
                }
            },
            btn: [
                ['<spring:message code="common.OK"/>', "ok"],
                ['<spring:message code="common.cancel"/>',
                    "cancel"]]
        });
    }


    function doResetUserPassword(params) {
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/user/resetPassword",
            data: params,
            error: function (request) {
                top.handlePrompt("error",
                    '<spring:message code="user.manager.deleteFailed"/>');
            },
            success: function () {
                top.handlePrompt("success",
                    '<spring:message code="user.manager.deteteSuccessed"/>');
                refreshWindow();
            }
        });
    }

    function createSync() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var params = {
            "token": "${token}"
        };
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/ldapuser/syncUsers/" + authServerId,
            data: params,
            error: function (request) {
                top.handlePrompt("error",
                        '<spring:message code="user.manager.syncUserFailed"/>');
            },
            success: function () {
                top.handlePrompt("success",
                        '<spring:message code="user.manager.syncUserSuccessed"/>');
                refreshWindow();
            }
        });
    }


    function refreshWindow() {
        initDataList(currentPage, newHeadItem, newFlag);
    }

    function exportUser() {

        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var filter = $("#filter").val();
        if (filter == "" || filter == null) {
            filter = null;
        }
        var dn = $("#dn").val();
        if (dn == "" || dn == null) {
            dn = null;
        }

        if (isIeBelow11()) {
            top.ymPrompt.alert({title: '<spring:message code="common.title.info"/>', message: '<spring:message code="common.download.excel.file" />'});
            window.location = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId + "/0" + "/" + dn + "/" + filter;
        } else {
            window.location = "${ctx}/enterprise/admin/user/exportEmployees/" + authServerId + "/0" + "/" + dn + "/" + filter;
        }
    }

    function importUser() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/import/enterprise/admin/user/enterImportEmployees/" + authServerId;
        top.ymPrompt.win({
            message: url,
            width: 900,
            height: 665,
            title: '<spring:message code="user.manager.exportUser"/>',
            iframe: true
        });
    }

    //ldap
    function initTree(name) {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var setting = {
            async: {
                enable: true,
                url: "${ctx}/enterprise/admin/ldapuser/listTreeNode/" + authServerId,
                autoParam: ["baseDn", "page"],
                otherParam: ["token", "${cse:htmlEscape(token)}"]
            },
            data: {
                simpleData: {
                    enable: true
                }
            },
            view: {
                expandSpeed: "",
                showIcon: false
            },
            callback: {
                onAsyncSuccess: onAsyncSuccess,
                onAsyncError: onAsyncError,
                onClick: zTreeOnClick
            }
        };

        var zNodes = [{name: name, isParent: true, page: 0, baseDn: name},
            {name: '<spring:message code="user.manager.ldap.node"/>', baseDn: ""}];
        $.fn.zTree.init($("#treeArea"), setting, zNodes);
        $("#treeArea > li > span").click();
        $("#treeArea").toggle();

        $("body").mousedown(function () {
            var ev = arguments[0] || window.event;
            var srcElement = ev.srcElement || ev.target;
            if (srcElement != $("#treeArea").get(0) && srcElement != $("#buttonDnName").get(0) && $(srcElement).parents("button").attr("id") != "buttonDnName" && $(srcElement).parents(".ztree").attr("id") != "treeArea") {
                $("#treeArea").hide();
            }
            ;
        });

        stopDefaultScroll("treeArea");
    }

    function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus,
                          errorThrown) {
        top.handlePrompt("error", '<spring:message  code="clusterManage.date.exception"/>');
    }

    function zTreeOnClick(event, treeId, treeNode) {
        if (treeNode.id != "-1") {
            $("#buttonDnName").find(">span").html(treeNode.name);
            $("#dnName").val(treeNode.name);
            $("#dn").val(treeNode.baseDn);
        }
        $("#treeArea").hide();
    }

    function stopDefaultScroll(id) {
        var _this = document.getElementById(id);
        if (navigator.userAgent.indexOf("Firefox") > 0) {
            _this.addEventListener('DOMMouseScroll', function (e) {
                _this.scrollTop += e.detail > 0 ? 60 : -60;
                e.preventDefault();
            }, false);
        } else {
            _this.onmousewheel = function (e) {
                e = e || window.event;
                _this.scrollTop += e.wheelDelta > 0 ? -60 : 60;
                return false;
            };
        }
        return this;
    }

    var pageCount = 0;

    function initTreeName() {
        var params = {
            "token": "${token}"
        };
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/ldapuser/initTreeName/" + authServerId,
            data: params,
            error: function (request) {
                top.handlePrompt("error", '<spring:message  code="clusterManage.date.exception"/>');
            },
            success: function (data) {
                if (data.baseDn != null && data.baseDn != "") {
                    pageCount = data.page;
                    initTree(data.baseDn);
                }
            }
        });
    }

    function onAsyncSuccess(event, treeId, treeNode, msg) {
        var childrenNode = treeNode.children;
        if (childrenNode) {
            var nodesLength = treeNode.children.length;
            if (pageCount > 0 && nodesLength >= pageCount) {
                addDiyDom(treeId, treeNode);
            }
        }
    }

    function addDiyDom(treeId, treeNode) {
        var prevFlag = $("#prevBtn_" + treeNode.tId);
        if (!prevFlag.get(0)) {
            var aObj = $("#" + treeNode.tId + "_switch");
            var addStr = "<span class='button prevPage' id='prevBtn_" + treeNode.tId
                    + "' title='<spring:message code="common.prev.page"/>' onfocus='this.blur();'></span><span class='button nextPage' id='nextBtn_" + treeNode.tId
                    + "' title='<spring:message code="common.next.page"/>' onfocus='this.blur();'></span>";
            aObj.after(addStr);
            var prev = $("#prevBtn_" + treeNode.tId);
            var next = $("#nextBtn_" + treeNode.tId);

            prev.bind("click", function () {
                if (!treeNode.isAjaxing) {
                    goPage(treeNode, treeNode.page - 1);
                }
            });
            next.bind("click", function () {
                if (!treeNode.isAjaxing) {
                    goPage(treeNode, treeNode.page + 1);
                }
            });
        }
    }

    function goPage(treeNode, page) {
        if (page < 0) {
            return;
        }

        var childrenNode = treeNode.children;
        if (childrenNode) {
            var nodesLength = treeNode.children.length;
            if (nodesLength != 0 || (page + 1) == treeNode.page) {
                treeNode.page = page;
                var zTree = $.fn.zTree.getZTreeObj("treeArea");
                zTree.reAsyncChildNodes(treeNode, "refresh");
            }
        }
    }

    function openAccount() {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == "") {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        top.ymPrompt.win({
            message: '${ctx}/enterprise/admin/user/listEnterpriseAccount/' + authServerId,
            width: 700,
            height: 430,
            title: '<spring:message code="employeeManage.open.account"/>',
            iframe: true,
            btn: [
                ['<spring:message code="employeeManage.open.account"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]],
            handler: doOpenAccount
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function doOpenAccount(tp) {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == "") {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
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

    function changeAuthType() {
        $("#buttonDnName").find(">span").html('<spring:message code="user.manager.ldap.node"/>');
        $("#dn").val("");
        $("#dnName").val(null);

        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var localTypeId = "<c:out value='${localTypeId}'/>";
        if (authServerId == localTypeId) {
            $("#createUserBtn").show();
            $("#buttonDnName").hide();
            $("#createSyncBtn").hide();
            $("#syncLogBtn").hide();
            $("#deleteUserBtn").show();
            $("#importUserBtn").show();
            $("#exportUserBtn").show();
            $("#clearUserBtn").hide();
            $("#chgDeptBtn").show();

        }
        else {
            $("#createUserBtn").hide();
            $("#buttonDnName").show();
            $("#createSyncBtn").show();
            $("#syncLogBtn").show();
            $("#deleteUserBtn").hide();
            $("#importUserBtn").hide();
            $("#exportUserBtn").show();
            $("#clearUserBtn").show();
            $("#chgDeptBtn").hide();
        }
        initDataList(1, "", false);
    }

    function getDeleteUserManager() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        window.location = "${ctx}/enterprise/admin/ldapuser/enterDeleteUsers/" + authServerId;
    }

    function enterSyncUserLog() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        window.location = "${ctx}/enterprise/admin/ldapuser/enterSyncUserLog/" + authServerId;
    }

    function isIeBelow11() {
        if (navigator.userAgent.indexOf("MSIE") < 0) {
            return false;
        } else if (navigator.userAgent.indexOf("MSIE 10.0") >= 0) {
            return true;
        } else if (navigator.userAgent.indexOf("MSIE 9.0") >= 0) {
            return true;
        } else if (navigator.userAgent.indexOf("MSIE 8.0") >= 0) {
            return true;
        } else if (navigator.userAgent.indexOf("MSIE 7.0") >= 0) {
            return true;
        } else {
            return false;
        }
    }

    /** 设置用户状态为离职状态 */
    function setLeaveStatus() {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == "") {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }

        var ids;
        if (idArray == "all") {
            ids = "all";
        } else {
            for (var index in catalogData) {
                var tempData = catalogData[index];
                if (tempData.id == idArray[0]) {
                    if (tempData.status != 0) {
                        handlePrompt("error", '<spring:message code="departure.migrate.data.user.status.exception"/>');
                        return;
                    }
                }
            }

            ids = idArray.join(",");
        }

        top.ymPrompt.confirmInfo({
            title: '<spring:message code="departure.migrate.data.setting.leave.status"/>',
            message: '<spring:message code="departure.migrate.data.setting.leave.message"/>',
            width: 450,
            closeTxt: '<spring:message code="common.close"/>',
            handler: function (tp) {
                if (tp == "ok") {
                    changeStatus("leaveProcessing", ids);
                }
            },
            btn: [
                ['<spring:message code="common.OK"/>', "ok"],
                ['<spring:message code="common.cancel"/>', "cancel"]
            ]
        });
    }

    /** 更改用户状态为离职状态 */
    function changeStatus(status, ids) {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var url = "${ctx}/enterprise/admin/user/changeStatus";
        var params = {
            "filter": filter,
            "dn": dn,
            "authServerId": authServerId,
            "status": status,
            "ids": ids,
            "token": "${token}"
        };

        $.ajax({
            type: "POST",
            url: url,
            data: params,
            error: function (request) {
                top.handlePrompt("error", '<spring:message code="common.modifyStatusFailed"/>');
            },
            success: function () {
                top.handlePrompt("success", '<spring:message code="common.modifyStatusSucessed"/>');
                refreshWindow();
            }
        });
    }

    /** 数据迁移*/
    function showMigrateDataUI() {
        var idArray = $("#rankList").getTableGridSelected();

        if (!idArray || idArray.length < 1) {
            handlePrompt("error", '<spring:message code="departure.migrate.data.choose.departure.user"/>');
            return;
        }

        if (idArray.length > 1) {
            handlePrompt("error", '<spring:message code="departure.migrate.data.migrate.num.limit"/>');
            return;
        }

        var departureUserName, authAppIdList;
        for (var index in catalogData) {
            var tempData = catalogData[index];
            if (tempData.id == idArray[0]) {
                departureUserName = tempData.name;
                authAppIdList = tempData.authAppIdList.join(',');
                if (tempData.status == 0) {
                    handlePrompt("error", '<spring:message code="departure.migrate.data.set.leave.status.first"/>');
                    return;
                }
            }
        }

        if (!authAppIdList) {
            handlePrompt("error", '<spring:message code="departure.migrate.data.user.not.openaccount"/>');
            return;
        }

        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/showMigrationDataUI/" + authServerId + "/" + idArray + "?appIds=" + authAppIdList
                + "&departureUserName=" + departureUserName;

        top.ymPrompt.win({
            message: url,
            width: 750,
            height: 440,
            title: '<spring:message code="departure.btn.migration.data"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.OK"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]
            ],
            handler: function (tp) {
                if (tp == 'yes') {
                    top.ymPrompt.getPage().contentWindow.migrateData();
                } else {
                    top.ymPrompt.close();
                }
            }
        });

        top.ymPrompt_addModalFocus("#btn-focus");
    }

    //switch user`s department
    var chngeDeptParams = {};
    function changeUserDept() {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == "") {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }
        var ids;
        if (idArray == "all") {
            ids = "all";
        }
        else {
            ids = idArray.join(",");
        }
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        chngeDeptParams = {
            "filter": filter,
            "dn": dn,
            "authServerId": authServerId,
            "ids": ids,
            "token": "${token}"
        };

        top.ymPrompt.win({
            message: '${ctx}/enterprise/admin/organize/chooseDepartment',
            width: 710,
            height: 590,
            title: '<spring:message code="employee.dept.title"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.OK"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]],
            handler: function (tp) {
                if (tp == 'yes') {
                    var deptId = top.ymPrompt.getPage().contentWindow.getSelectedDepartment();
                    if (deptId == null || deptId.length == 0) {
                        handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.noDept"/>');
                        return;
                    }

                    chngeDeptParams.deptId = deptId.toString();
                    doChangeUserDept(chngeDeptParams);
                }
            }
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function doChangeUserDept(params) {
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/user/changeUserDeptInfo",
            data: params,
            error: function (request) {
                handlePrompt("error",'<spring:message code="employee.dept.switch.failed"/>');
            },
            success: function () {
                top.ymPrompt.close();
                handlePrompt("success", '<spring:message code="employee.dept.switch.success"/>');
                refreshWindow();
            }
        });
    }

    //switch user`s department
    function setSecurityClassification() {
        var idArray = $("#rankList").getTableGridSelected();
        if (idArray == "") {
            handlePrompt("error", '<spring:message code="user.manager.selectUser"/>');
            return;
        }
        var ids;
        if (idArray == "all") {
            ids = "all";
        }
        else {
            ids = idArray.join(",");
        }
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        chngeDeptParams = {
            "filter": filter,
            "dn": dn,
            "authServerId": authServerId,
            "ids": ids,
            "token": "${token}"
        };

        top.ymPrompt.win({
            message: '${ctx}/enterprise/admin/user/setSecurityClassification/0?ids=' + idArray[0],
            width: 800,
            height: 350,
            title: '<spring:message code="enterprise.user.security.classification.set"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.OK"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]],
            handler: doSetSecurityClassification
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function doSetSecurityClassification(tp) {
        if (tp == 'yes') {
            top.ymPrompt.getPage().contentWindow.submitSecurityClassification();
        }
    }

</script>
<script type="text/javascript">
    //---------------------Department Ztree----
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
        check: {
            autoCheckTrigger: false,
            chkboxType: {"Y": "ps", "N": "ps"},
            chkStyle: "radio",
            enable: true,
            nocheckInherit: false,
            chkDisabledInherit: false,
            radioType: "all"
        }
    };

    var chkedNodes;
    function nodeOnRadio(e, treeId, treeNode) {
        var chkedNodeIdAry = new Array(), chkedNodeNmAry = new Array();
        var zTree = $.fn.zTree.getZTreeObj("menuTree");

        chkedNodes = zTree.getCheckedNodes(true);
        $(chkedNodes).each(function (index, item) {
            chkedNodeIdAry.push(item.id);
            chkedNodeNmAry.push(item.name);
        });
        $("#deptIdInput").val(chkedNodeIdAry.join(","));
        $("#deptDisplay").html(chkedNodeNmAry.join(","));
    }

    /*
     * 下拉树的点击事件
     */
    function deviceTypeOnClick(e, treeId, treeNode) {
        var zTree = $.fn.zTree.getZTreeObj("menuTree");
    }

    /*
     * 展示SelectTree
     */
    function showNodeTree() {
        $.ajax({
            url: '${ctx}/enterprise/admin/organize/listDeptTree',
            type: 'GET',
            async: true,
            success: function (msg) {
                var obj = eval("(" + msg + ")");
                var defAtom = {alias: null, children: "", name: '<spring:message code="employee.dept.default.all"/>', id: "all", PId: "-1", type: "department"};
                obj.push(defAtom);
                var treeNodes = [];
                getTreeObj(obj, treeNodes);
                //set tree data
                loadTreeData(treeNodes);
            },
            error: function () {
            }
        });
    }

    function displayDeptTree(evt) {
        var disAttr = $("#treeContent")[0].style.display;
        if (disAttr === "" || disAttr === "none") {
            stopDefaultAndBubble(evt);
            showNodeTree();
        }
    }

    $(function () {
        var $selectNode = $("#selectNode");
        $selectNode.on("click", function (evt) {
            displayDeptTree(evt);
        });
        $selectNode.on("focus", function (evt) {
            displayDeptTree(evt);
        });
    });

    //To set treeNodes data
    function loadTreeData(treeNodes) {
        var $selectButton = $("#selectNode");

        var $menuTree = $("#menuTree");
        $.fn.zTree.init($menuTree, deviceTypeSetting, treeNodes);
//      $menuTree.css({width: $selectButton.outerWidth() - 12 + "px"});

        var deptOffset = $selectButton.offset();
        $("#treeContent").css({left: deptOffset.left + "px", top: deptOffset.top + $selectButton.outerHeight() + "px"}).slideDown("fast");

        var zTree = $.fn.zTree.getZTreeObj("menuTree"),
                nodeIds = $('#deptIdInput').val(),
                nodeIdAry = nodeIds.split(",");
        //init node selection
        if (nodeIdAry.length > 0 && nodeIdAry[0] != "") {
            $.each(nodeIdAry, function (index, id, nodeIdAry) {
                var node = zTree.getNodeByParam("id", id, null)
                zTree.selectNode(node);
                zTree.checkNode(node);
            });
        } else {
            var node = zTree.getNodeByParam("id", "all", null)
            zTree.selectNode(node);
            zTree.checkNode(node);
        }
        //bind event
        $("body").bind("mousedown", onBodyDownByDevType);
        $("body").bind("click", hidenSwitch);

        document.onkeydown = function () {
            if (window.event.keyCode == 9) {
                var isContain = hidenSwitch(event);
                if (isContain) {
                    hideDeviceTypeMenu();
                }
            }
        }
    }

    function hidenSwitch(e) {
        var child = e.target;
        var parent = document.getElementById("deptSectionDiv");
        var parentNode;
        if (child && parent) {
            parentNode = child.parentNode;
            while (parentNode) {
                if (parent === parentNode) {
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
     *
     */
    function getTreeObj(dataObj, treeNodes) {
        for (var i = 0; i < dataObj.length; i++) {
            treeNodes.push({id: dataObj[i].id, pId: dataObj[i].pId, name: dataObj[i].name});
            loadChildObj(dataObj[i], treeNodes);
        }
    }

    /**
     * 查找子节点
     */
    function loadChildObj(dataObj, treeNodes) {
        var childObj = dataObj.children;
        for (var j = 0; j < childObj.length; j++) {
            treeNodes.push({id: childObj[j].id, pId: childObj[j].pId, name: childObj[j].name});
            loadChildObj(childObj[j], treeNodes);
        }
    }
    /*
     * Body鼠标按下事件回调函数
     */
    function onBodyDownByDevType(event) {
        if (event.target.id.indexOf('switch') == -1) {
            // hideDeviceTypeMenu();
        }
    }
    /*
     * 隐藏Tree
     */
    function hideDeviceTypeMenu() {
        $("#treeContent").fadeOut("fast");
        $("body").unbind("mousedown", onBodyDownByDevType);
        $("body").unbind("click", hidenSwitch);
    }

    function stopDefaultAndBubble(evt) {
        if (window.event) {
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        } else {
            evt.stopPropagation();
            evt.preventDefault();
        }
    }
</script>