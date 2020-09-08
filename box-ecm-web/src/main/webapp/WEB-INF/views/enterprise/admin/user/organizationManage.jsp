<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));%>

<!-- 启用组织机构 -->
<c:if test="${isDeptPrivilege}">
</c:if>
<!-- 未启用组织机构 -->
<c:if test="${!isDeptPrivilege}">
    未启用组织机构
</c:if>
<div class="sys-content">
    <div class="table-con">
        <table style="width: 100%; align: left">
            <tr>
                <td width="25%">
                    <div class="clearfix">
                        <div class="pull-left form-search">
                            <input type="hidden" id="page" name="page" value="1" />

                            <div class="pull-left">
                                <select class="span3 width-w180" id="authenticationMethod" name="authenticationMethod" onchange="changeAuthType()">
                                    <c:forEach items="${authServerList}" var="authServer">
                                        <option value="${authServer.id}" <c:if test="${localTypeId == authServer.id}">selected</c:if>>
                                            <c:if test="${authServer.type != 'LocalAuth'}">
                                                ${authServer.name}
                                            </c:if>
                                            <c:if test="${authServer.type == 'LocalAuth'}">
                                                <spring:message code="authserver.type.local" />
                                            </c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="pull-left">
                                <label>&nbsp;</label>
                            </div>

                            <div class="pull-left folderTreeCon">
                                <input type="hidden" id="dn" name="dn" value="${dn}" />
                                <input type="hidden" id="dnName" name="dnName" value="${dnName}" />
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
                </td>
                <td>
                    <div class="controls" id="deptSectionDiv">
                        <div>当前部门：</div> <div id="orgNavigator"></div>
                        <div class="" style="float: right">
                            <button type="button" class="btn btn-primary" onClick="createDeptButtonClick()" id="createDeptButton">
                                <i class="icon-plus"></i>
                                <spring:message code="organizationChart.addChild"/>
                            </button>
                            <button type="button" class="btn" onclick="addDeptMemberButtonClick()" id="addDeptMemberButton">
                                <spring:message code="organizationChart.addEnterpriseUser"/>
                            </button>
                            <%--
                            <button type="button" class="btn" orgTreeOnClick="deleteUser()" id="deleteUserBtn">
                                <spring:message code="common.delete" />
                            </button>
                            <input type="text" id="filter" name="filter" class="span3" value="${filter}" placeholder='<spring:message code="user.manager.searchDescription"/>'/>
                            --%>

                        </div>
                        <span class="validate-con bottom inline-span3"></span>
                        <input id="storeIds" name="departmentIds" type="hidden" class="selectDevTypeid"/>

                        <div id="treeContent" class="selectDevTypeid" style="display: none; z-index: 2; position: absolute;overflow-y:scroll; border: 1px #CCC solid; background-color: white;">
                            <ul id="menuTree" class="ztree" style="margin-top: 0;"></ul>
                        </div>

                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <div id="treeContent2" class="ztreeUl" style="position: absolute; width:20%; border: 2px #CCC solid; border-radius: 15px; padding: 10px;margin-top:10px">
                        <ul id="orgTree" class="ztree" style="padding: 0px; width: 99%; background-color: white;" />
                    </div>
                </td>
                <td>
                    <div style="border: 2px #CCC solid; border-radius: 15px; padding: 10px;margin-top:10px">
                        <div id="orgInfo" style="height: 120px">
                            <div>
                                <span class="info-label">部门负责人：</span><span class="info-value" id="deptManager">-</span><span class="info-button"><a href="javascript:void(0)" onclick="setDeptManager()">设置负责人</a></span>
                            </div>
                            <div>

                                <span class="info-label">知识管理员：</span><span class="info-value" id="archiveOwner">-</span><span class="info-button"><a href="javascript:void(0)" onclick="setArchiveOwner()">设置管理员</a></span>
                            </div>
                            <div>
                                <span class="info-label">部门空间：</span><span class="info-value" id="deptTeamSpace">-</span><span class="info-button" id="deptTeamSpaceButton" style="display:none"><a href="javascript:void(0)" onclick="createDeptTeamSpace()">开通</a></span>
                            </div>
                            <div>

                                <span class="info-label">部门沟通群：</span>
                            </div>
                        </div>

                        <div id="rankList"></div>
                        <div id="rankListPage"></div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <input type="hidden" id="storField" value="id" />
    <input type="hidden" id="storDirection" value="true" />
</div>

<script type="text/javascript">
    $(document).ready(function () {
        /* set defaultNode for company--start*/
        var defRootNode = {id: "-1", pId: "-2", name: '${enterpriseName}', isParent: "true"};
        /* set defaultNode for company--end*/

        var firstTreeNodes = eval(${deptTree});
        if (typeof firstTreeNodes === "undefined") {
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
                addHoverDom: orgTreeAddHoverDom,
                removeHoverDom: orgTreeRemoveHoverDom,
                selectedMulti: false
            },
            edit: {
                enable: true,
                editNameSelectAll: true,
                showRemoveBtn: orgTreeShowRemoveBtn,
                showRenameBtn: orgTreeShowRenameBtn,
                removeTitle: '<spring:message code="organizationChart.remove" />',
                renameTitle: '<spring:message code="organizationChart.rename" />',
                drag: {
                    isCopy: false,
                    autoExpandTrigger: true,
                    prev: orgTreeDropPrev,
                    inner: orgTreeDropInner,
                    next: orgTreeDropNext
                }
            },
            data: {
                simpleData: {
                    enable: true
                }
            },
            callback: {
                beforeDrag: orgTreeBeforeDrag,
                beforeEditName: orgTreeBeforeEditName,
                beforeRemove: orgTreeBeforeRemove,
                beforeRename: orgTreeBeforeRename,
                onRemove: orgTreeOnRemove,
                onRename: orgTreeOnRename,
                onClick: orgTreeOnClick,
                onDrop: orgTreeOnDrop
            }
        };

        $("#treeContent2").css({height: "600px"});

        /*resize*/
        var $orgTree = $("#orgTree");
        $.fn.zTree.init($orgTree, setting, firstTreeNodes);

        //将机构树展开
        var $zTree = $.fn.zTree.getZTreeObj("orgTree");
        $zTree.expandAll(true);

        //模拟点击根节点
        var nodes = $zTree.getNodes();
        $zTree.selectNode(nodes[0], false);

        $("#selectAll").bind("click", selectAll);
    });

    function openOrganization(that) {
        ymPrompt.confirmInfo({
            title: '<spring:message code="enterprise.organizational.switch"/>',
            message: '<spring:message code="enterprise.organizational.switch"/>'
            + '<br/>'
            + '<spring:message code="enterprise.org.switch.warn"/>',
            width: 450,
            closeTxt: '<spring:message code="common.close"/>',
            handler: function (tp) {
                if (tp == "ok") {
                    var params = {
                        "token": "${token}"
                    };
                    $.ajax({
                        type: "POST",
                        url: '${ctx}/enterprise/admin/openOrganization',
                        data: params,
                        error: function (request) {
                            handlePrompt("error", '<spring:message code="common.operationFailed" />');
                        },
                        success: function (data) {
                        }
                    })
                } else {

                }
            },
            btn: [
                ['<spring:message code="common.OK"/>', "ok"],
                ['<spring:message code="common.cancel"/>', "cancel"]]
        });
    }

    var className = "dark";
    function orgTreeBeforeDrag(treeId, treeNodes) {
        //企业（根节点）不允许拖动
        return treeNodes.length > 0 && treeNodes[0].id != "-1";
    }

    function orgTreeDropPrev(treeId, treeNodes, targetNode) {
        //不允许拖动出企业（根节点）的范围外
        return targetNode.id != "-1";
    }

    function orgTreeDropInner(treeId, treeNodes, targetNode) {
        //不允许拖动成根节点（跟企业同一层级），如果拖拽的节点要成为根节点，则 targetNode = null
        return targetNode != null;
    }

    function orgTreeDropNext(treeId, treeNodes, targetNode) {
        //不允许拖动出企业（根节点）的范围外
        return targetNode.id != "-1";
    }

    function orgTreeOnDrop(event, treeId, treeNodes, targetNode, moveType) {
        var dragId = treeNodes[0].id;

        var parentId = "";

        if (moveType == 'prev' || moveType == 'next') {
            parentId = targetNode.getParentNode().id;
        } else if (moveType == 'inner') {
            parentId = targetNode.id;
        }

        if (parentId != "") {
            moveDept(dragId, parentId);
        }
    }

    function zTreeBeforeAsync(treeId, treeNode) {
        return true;
    }

    function getSelectedTreeId() {
        var treeObj = $.fn.zTree.getZTreeObj("orgTree");
        var sNodes = treeObj.getSelectedNodes();
        var tId = -1;
        if (sNodes.length > 0) {
            tId = sNodes[0].id;
        }
        return tId;
    }

    function getSelectedTreeNode() {
        var treeObj = $.fn.zTree.getZTreeObj("orgTree");
        var sNodes = treeObj.getSelectedNodes();
        return sNodes[0];
    }

    function orgTreeOnClick() {
        currentPage = 1;
        newHeadItem = "";
        newFlag = false;
        var treeObj = $.fn.zTree.getZTreeObj("orgTree");
        var sNodes = treeObj.getSelectedNodes();
        var tId = -1;
        if (sNodes.length > 0) {
            tId = sNodes[0].id;
        }
        if (tId == undefined) {     //快速创建多个部门，出现部门下有员工异常
            return;
        }

        //
        var node = sNodes[0];
        var nav = "";

        while(node != null) {
            nav = surroundOrgNodeWithJsAction(node) + " - " + nav;
            node = node.getParentNode();
        }

        $("#orgNavigator").html(nav);

        //查询当前部门下的员工列表
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/employeeManage";
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var params = {
            "page": 1,
            "deptId": tId,
            "authServerId": authServerId,
            "filter": dn,
            "token": "${token}",
            "dn": dn,
            "newHeadItem": newHeadItem,
            "newFlag": newFlag
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
            }
        });

        //查询部门信息
         $.ajax({
            type: "POST",
            url:  "${ctx}/enterprise/admin/organize/getDeptInfo/" + tId,
            data: {"token": "${token}"},
            error: function (request) {
                handlePrompt("error", '<spring:message code="common.operationFailed" />');
            },
            success: function (data) {
                setDeptInfo(eval("(" + data + ")"));
            }
        });
    }

    function surroundOrgNodeWithJsAction(node) {
        return "<a>" + node.name + "</a>";
    }

    function orgTreeBeforeEditName(treeId, treeNode) {
        className = (className === "dark" ? "" : "dark");
        showLog("[ " + getTime() + " orgTreeBeforeEditName ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
        var zTree = $.fn.zTree.getZTreeObj("orgTree");
        zTree.selectNode(treeNode);
        var nodes = zTree.getNodesByParam("name", "department", treeNode.pId);
        zTree.editName(treeNode);
        return false;
    }

    function orgTreeBeforeRemove(treeId, treeNode) {
        className = (className === "dark" ? "" : "dark");
        showLog("[ " + getTime() + " orgTreeBeforeRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
        var zTree = $.fn.zTree.getZTreeObj("orgTree");
        zTree.selectNode(treeNode);
        /*
         The root directory cannot be deleted
         */
        if (treeNode.id == -1) {
            handlePrompt("error", '<spring:message code="organizationChart.ztree.removeRoot.failed"/>');
            return false;
        }
        var validateDept = false;
        top.ymPrompt.confirmInfo({
            title: '<spring:message code="organizationChart.ztree.deteteDept"/>',
            message: '<spring:message code="organizationChart.ztree.removeDept1"/>'
            + treeNode.name
            + '<spring:message code="organizationChart.ztree.removeDept2"/>',
            width: 450,
            closeTxt: '<spring:message code="common.close"/>',
            handler: function (tp) {
                if (tp == "ok") {
                    validateDept = deleteDept(treeNode.id);
                    if (validateDept) {
                        var nodes = zTree.getSelectedNodes();
                        for (var i = 0, l = nodes.length; i < l; i++) {
                            zTree.removeNode(nodes[i]);
                        }
                    }
                }
            },
            btn: [
                ['<spring:message code="common.OK"/>', "ok"],
                ['<spring:message code="common.cancel"/>', "cancel"]]
        });
        return validateDept;
    }

    function orgTreeOnRemove(e, treeId, treeNode) {
        showLog("[ " + getTime() + " orgTreeOnRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
    }

    function deleteDept(tId) {
        if (tId == undefined || tId == "undefiend") {
            handlePrompt("error", '<spring:message code="organizationChart.deleteDept.nonentity" />');
            return;
        }
        var vildateDept = true;
        var url = "${ctx}/enterprise/admin/organize/deleteDepartment";
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var params = {
            "departmentId": tId,
            "authServerId": authServerId,
            "token": "${token}"
        };
        $.ajax({
            type: "POST",
            url: url,
            data: params,
            async: false,
            error: function (request) {
                vildateDept = false;
                handlePrompt("error", '<spring:message code="user.manager.deteteFailed" />');
                var data = eval("(" + request.responseText + ")");
                appIds = data[0];
                catalogData = data[1].content;
                $("#rankList").setTableGridData(catalogData, opts_viewGrid);
                $("#rankListPage").setPageData(opts_page, data[1].number, data[1].size, data[1].totalElements);
                var pageH = $("body").outerHeight();
                top.iframeAdaptHeight(pageH);

            },
            success: function (data) {
                handlePrompt("success", '<spring:message code="user.manager.deteteSuccessed"/>');
            }
        });
        return vildateDept;
    }

    function renameDept(pId, id, name, rename) {
        var zTree = $.fn.zTree.getZTreeObj("orgTree");
        if (!validateInput(name)) {
            handlePrompt("error", "<spring:message code='organizationChart.rename.character.abnormal'/>");
            zTree.editName(getSelectedTreeNode());
            return;
        } else if (name.length == 0 || name.length > 15) {
            handlePrompt("error", "<spring:message code='organizationChart.ztree.rename.failed'/>");
            zTree.editName(getSelectedTreeNode());
            return;
        }
        if (checkSameName(id, name)) {
            handlePrompt("error", "<spring:message code='employee.dept.insamelevel.error'/>");
            var treeObj = $.fn.zTree.getZTreeObj("orgTree");
            name = treeObj.getSelectedNodes()[0].name;
            zTree.editName(getSelectedTreeNode());
            return;
        }
        //操作过快，未获取Pid
        if (pId == undefined || pId == "undefined" || pId == "") {
            handlePrompt("error",
                    '<spring:message code="organizationChart.addDept.tooFast.error"/>');
            return;
        }
        if (id == undefined || id == "undefined") {
            createDept(pId, name);
        } else {
            $.ajax({
                type: "POST",
                url: "${ctx}/enterprise/admin/organize/modifyDeptName/" + id,
                data: {"parentid": pId, "name": name, "token": "${token}", "rename": rename},
                error: function (request) {
                    handlePrompt("error",
                            '<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
                    var zTree = $.fn.zTree.getZTreeObj("orgTree");
                    zTree.cancelEditName();
                },
                success: function () {
                    handlePrompt("success",
                            '<spring:message code="organizationChart.deptRename.successed"/>');
                }
            });
        }
    }

    function moveDept(depId, parentId) {
        $.ajax({
            type: "POST",
            url: "${ctx}/enterprise/admin/organize/modifyDeptName/" + depId,
            data: {"parentid": parentId, "token": "${token}"},
            error: function (request) {
                handlePrompt("error", '<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
                var zTree = $.fn.zTree.getZTreeObj("orgTree");
                zTree.cancelEditName();
            },
            success: function () {
                handlePrompt("success", '<spring:message code="organizationChart.deptRename.successed"/>');
                var zTree = $.fn.zTree.getZTreeObj("orgTree");
                zTree.expandAll(true);
            }
        });
    }

    /**********名称长度小于16个字节且不为空***************/
    function checkNameLength(name) {
        if (name.length > 0 && name.length < 16) {
            return true;
        } else {
            handlePrompt("error", '<spring:message code="organizationChart.ztree.rename.failed" />');
            return false;
        }
    }

    function orgTreeBeforeRename(treeId, treeNode, newName) {
        return checkNameLength(newName);
    }

    function orgTreeOnRename(e, treeId, treeNode, isCancel) {
        showLog((isCancel ? "<span style='color:red'>" : "") + "[ " + getTime() + " orgTreeOnRename ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name + (isCancel ? "</span>" : ""));
        renameDept(treeNode.pId, treeNode.id, treeNode.name);
    }

    /**********公司名称不能修改和删除，屏蔽rename和remove，button***************/
    function orgTreeShowRemoveBtn(treeId, treeNode) {
        return treeNode.id >= 0;
    }

    function orgTreeShowRenameBtn(treeId, treeNode) {
        return treeNode.id >= 0;
    }

    function showLog(str) {
        var $log = $("#log");
        if ($log != null) {
            $log.append("<li class='" + className + "'>" + str + "</li>");
            if ($log.children("li").length > 8) {
                $log.get(0).removeChild($log.children("li")[0]);
            }
        }
    }

    function getTime() {
        var now = new Date(),
                h = now.getHours(),
                m = now.getMinutes(),
                s = now.getSeconds(),
                ms = now.getMilliseconds();
        return (h + ":" + m + ":" + s + " " + ms);
    }

    var newCount = 1;
    function orgTreeAddHoverDom(treeId, treeNode) {
        var sObj = $("#" + treeNode.tId + "_span");
        if (treeNode.editNameFlag || $("#addBtn_" + treeNode.tId).length > 0) return;
        var addStr = "<span class='button add' id='addBtn_" + treeNode.tId
                + "' title=<spring:message code='organizationChart.add' /> onfocus='this.blur();'></span>";
        sObj.after(addStr);
        var btn = $("#addBtn_" + treeNode.tId);
        if (btn) btn.bind("click", function () {
            beforeCreateDept(treeNode.id, "department" + (newCount++), treeNode);
            return false;
        });
    }

    function beforeCreateDept(id, name, treeNode) {
        var zTree = $.fn.zTree.getZTreeObj("orgTree");
        var array = zTree.addNodes(treeNode, {pId: id, name: name});
        zTree.editName(array[array.length - 1]);
    }

    function createDept(id, name) {
        var url = "${ctx}/enterprise/admin/organize/addDepartment";
        var tt = '${token}';
        $.ajax({
            type: "POST",
            url: url,
            data: {parentid: id, name: name, token: tt},
            error: function (request) {
                if (request.responseText === "ConflictException") {
                    handlePrompt("error",
                            '<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
                } else {
                    handlePrompt("error", '<spring:message code="user.manager.createUserFailed"/>');
                }
            },
            success: function (data) {
                /*  给新增节点设置ID   */
                var curentnode = getSelectedTreeNode();
                curentnode["id"] = data;
                handlePrompt("success", '<spring:message code="createDept.createDeptSuccessed"/>');
            }
        });
    }

    function checkSameName(id, name) {
        var treeObj = $.fn.zTree.getZTreeObj("orgTree");
        var selNode = treeObj.getSelectedNodes()[0];
        var parNode = selNode.getParentNode();
        var length = parNode.children.length;
        for (var i = 0; i < length; i++) {
            // 如果是自身节点就不用比较了
            if (name == parNode.children[i].name && id != parNode.children[i].id) {
                return true;
            }
        }
        return false;
    }

    function orgTreeRemoveHoverDom(treeId, treeNode) {
        $("#addBtn_" + treeNode.tId).unbind().remove();
    }

    function selectAll() {
        var zTree = $.fn.zTree.getZTreeObj("orgTree");
        zTree.setting.edit.editNameSelectAll = $("#selectAll").attr("checked");
    }
    /**
     * Transform data into treeNode Data
     */
    function getFirstTreeObj(dataObj, treeNodes) {
        for (var i = 0; i < dataObj.length; i++) {
            treeNodes.push({id: dataObj[i].id, pId: dataObj[i].pId, name: dataObj[i].name});
            loadChildObj(dataObj[i], treeNodes);
        }
    }

    function cleanPage(){
        $("#treeContent").fadeOut("fast");
        $("#filter").val("");
        $("#storeIds").val("");
    }

    function createDeptButtonClick() {
        var treeObj = $.fn.zTree.getZTreeObj("orgTree");
        var sNodes = treeObj.getSelectedNodes();
        if (sNodes.length > 0) {
            var treeNode = sNodes[0];
            beforeCreateDept(treeNode.id, "department" + (newCount++), treeNode);
        }
    }

    function addDeptMemberButtonClick() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/chooseEnterpriseUser/" + authServerId + "?mode=multi";
        top.ymPrompt.win({
            message: url,
            width: 800,
            height: 640,
            title: '<spring:message code="organizationChart.addEnterpriseUser"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.create"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]
            ],
            handler: function (tp) {
                if (tp == 'yes') {
                    var array = top.ymPrompt.getPage().contentWindow.getSelectedUser();
                    if (array == "") {
                        handlePrompt("error",'<spring:message code="user.manager.selectUser"/>');
                        return;
                    }

                    submitDeptMember(authServerId, array.toString());
                }
            }
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function submitDeptMember(authServerId, member) {
        var deptId = getSelectedTreeId();
        if (deptId == undefined) {
            return;
        }

        if(deptId<0){
            handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.noDept"/>');
            return;
        }

        var params = {
            "token" : "${token}",
            "enterpriseUserId" : member,
            "deptId" : deptId
        };
        $.ajax({
            type : "POST",
            url : "${ctx}/enterprise/admin/organize/deptAddEnterpriseUser",
            data : params,
            error : function(request) {
                if(request.responseText === "ConflictException"){
                    handlePrompt("error",
                            '<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
                }else{
                    handlePrompt("error",'<spring:message code="organizationChart.addEnterpriseUser.deptExist"/>');
                }
            },
            success : function() {
                top.ymPrompt.close();
                cleanPage();
                handlePrompt("success",'<spring:message code="organizationChart.addEnterpriseUser.successed"/>');
                orgTreeOnClick();

            }
        });
    }

    function setDeptInfo(info) {
        var $manager = $("#deptManager");
        if(info.manager != null) {
            $manager.html("<strong>" + info.manager.staffNo + "/" + info.manager.alias + "</strong>");
        } else {
            $manager.html("未指定");
        }

        var $archiveOwner = $("#archiveOwner");
        if(info.archiveOwner != null) {
            $archiveOwner.html("<strong>" + info.archiveOwner.staffNo + "/" + info.archiveOwner.alias + "</strong>");
        } else {
            $archiveOwner.html("未指定");
        }

        var $deptTeamSpace = $("#deptTeamSpace");
        var $deptTeamSpaceButton = $("#deptTeamSpaceButton");
        if(info.departmentAccount != null) {
            $deptTeamSpace.html("<strong>已开通</strong>");
            $deptTeamSpaceButton.hide();
        } else {
            if(info.archiveOwner != null) {
                $deptTeamSpace.html("未开通");
                $deptTeamSpaceButton.show();
            } else {
                $deptTeamSpace.html("未开通(指定知识管理员后才能开通)");
                $deptTeamSpaceButton.hide();
            }
        }
    }

    function setDeptManager() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/chooseEnterpriseUser/" + authServerId;
        top.ymPrompt.win({
            message: url,
            width: 800,
            height: 600,
            title: '选择人员',
            iframe: true,
            btn: [
                ['设置', 'yes', false, "btn-focus"],
                ['<spring:message code="common.cancel"/>', 'no', true, "btn-cancel"]
            ],
            handler: function (tp) {
                if (tp == 'yes') {
                    var array = top.ymPrompt.getPage().contentWindow.getSelectedUser();
                    if (array == "") {
                        handlePrompt("error",'<spring:message code="user.manager.selectOneUser"/>');
                        return;
                    }

                    submitDeptManager(authServerId, array.pop());
                }
            }
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function submitDeptManager(authServerId, user) {
        var tId = getSelectedTreeId();
        if (tId == undefined) {
            return;
        }

        var url = "${ctx}/enterprise/admin/organize/addDeptManager/" + authServerId;
        $.ajax({
            type: "POST",
            url: url,
            data: {
                "enterpriseUserId": user,
                "deptId": tId,
                "appId":appIds
            },
            error: function (request) {
                var status = request.status;
                if (status == 409) {
                    handlePrompt("error", '<spring:message code="createEnterprise.conflict.name.email"/>');
                } else {
                    handlePrompt("error", '<spring:message code="user.manager.createUserFailed"/>');
                }
            },
            success: function () {
                top.ymPrompt.close();
                handlePrompt("success", '设置成功');
                orgTreeOnClick();
//                top.window.frames[0].window.reloadCurrentTab();
            }
        });
    }

    function setArchiveOwner() {
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/chooseEnterpriseUser/" + authServerId;
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
            handler: function (tp) {
                if (tp == 'yes') {
                    var array = top.ymPrompt.getPage().contentWindow.getSelectedUser();
                    if (array == "") {
                        handlePrompt("error",'<spring:message code="user.manager.selectOneUser"/>');
                        return;
                    }

                    submitArchiveOwner(authServerId, array.pop());
                }
            }
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }


    function submitArchiveOwner(authServerId, user) {
        var tId = getSelectedTreeId();
        if (tId == undefined) {
            return;
        }

        var url = "${ctx}/enterprise/admin/user/addArchiveOwner/" + authServerId;
        $.ajax({
            type: "POST",
            url: url,
            data: {
                "enterpriseUserId": user,
                "deptId": tId
            },
            error: function (request) {
                var status = request.status;
                if (status == 409) {
                    handlePrompt("error", '<spring:message code="createEnterprise.conflict.name.email"/>');
                } else {
                    handlePrompt("error", '<spring:message code="user.manager.createUserFailed"/>');
                }
            },
            success: function () {
                top.ymPrompt.close();
                handlePrompt("success", '<spring:message code="user.manager.createUserSuccessed"/>');
                orgTreeOnClick();
//                top.window.frames[0].window.reloadCurrentTab();
            }
        });
    }

    function createDeptTeamSpace(authServerId, user) {
        var tId = getSelectedTreeId();
        if (tId == undefined) {
            return;
        }

        var url = "${ctx}/enterprise/admin/teamspace/config/createDeptTeamSpace";
        $.ajax({
            type: "POST",
            url: url,
            data: {
                "token" : "${token}",
                "deptId": tId
            },
            error: function (request) {
                handlePrompt("error", '<spring:message code="common.failed"/>');
            },
            success: function () {
                handlePrompt("success", '<spring:message code="common.success"/>');
                orgTreeOnClick();
            }
        });
    }
</script>

<%-- employee list --%>
<script type="text/javascript">

    var appIds = "";
    var currentPage = 1;
    var newHeadItem = "";
    var newFlag = false;
    var opts_viewGrid = null;
    var opts_page = null;
    var headData = {
        "name": {
            "title": "<spring:message code='user.manager.loginName'/>",
            "width": "20%",
            "taxis": true
        },
        "alias": {
            "title": "<spring:message code='user.manager.name'/>",
            "width": "20%",
            "taxis": true
        },

        "departmentName": {
            "title": "<spring:message code='enterprise.employee.dept.lable'/>",
            "width": "25%"
        },

        "operation": {
            "title": "<spring:message code='common.operate'/>",
            "width": "20%"
        }
    };
    $(document).ready(function () {
        opts_viewGrid = $("#rankList").comboTableGrid({
            headData: headData,
            checkBox: true,
            checkAll: true,
            height: 400,
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

                case "departmentName":
                    try {
                        var departmentName = tdItem.find("p").text();
                        if (departmentName == "") {
                            tdItem.find("p").html("<spring:message code='enterprise.employee.dept.unspecified'/>").parent().attr("title", "-");
                        }
                    } catch (e) {
                    }
                    break;
                case "option":
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

        $("#filter").keydown(function () {
            var evt = arguments[0] || window.event;
            if (evt.keyCode == 13) {
                searchEnterUser(evt);
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

    function changeAuthType() {
        $("#buttonDnName").find(">span").html('<spring:message code="user.manager.ldap.node"/>');
        $("#dn").val("");
        $("#dnName").val(null);

        initDataList(1, "", false);
    }


    function initDataList(curPage, headItem, flag) {
        currentPage = curPage;
        newHeadItem = headItem;
        newFlag = flag;
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/employeeManage";
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var deptId = getSelectedTreeId();

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
</script>