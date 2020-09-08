<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%
    request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));
%>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="../../../common/popCommon.jsp" %>
</head>
<body>

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
                                <c:if test="${authServer.type == 'LocalAuth'}"><spring:message code="authserver.type.local"/></c:if>
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
                <input type="hidden" id="dn" name="dn" value="${dn}"/>
                <input type="hidden" id="dnName" name="dnName" value="${dnName}"/>
                <button type="button" class="btn" onClick="initDnTree()" id="buttonDnName">
                    <span class="selectTreeName">
                        <c:if test="${empty dnName}"><spring:message code="user.manager.ldap.node"/></c:if>
                        <c:if test="${not empty dnName}">${dnName}</c:if>
                    </span>
                    <i class="icon-caret-down"></i>
                </button>
                <ul id="treeArea" class="ztree"></ul>
            </div>
            <c:if test="${isOrganizeEnabled == true}">
                <div id="deptSectionDiv" class="pull-left filterDeptTree">
                    <input name="departmentIds" id="deptIdInput" type="hidden"/>
                    <button type="button" class="btn" id="selectDeptButton">
		                    <span class="selectTreeName" id="deptDisplay" name="deptDisplay">
		                    	<spring:message code="employee.dept.default.all"/>
		                    </span>

                        <div>
                            <i class="icon-caret-down"></i>
                        </div>
                    </button>
                        <%--溢出方式设置为hidden，auto会出现滚动条 --%>
                    <div id="deptTreeContent" class="treeMenuDiv" style="display: none">
                        <ul id="deptTree" class="ztree"></ul>
                    </div>
                </div>
            </c:if>

            <div class="pull-left input-append">
                <input type="text" id="filter" name="filter" class="span3 search-query" value="${filter}" placeholder='<spring:message code="user.manager.searchDescription"/>'/>
            </div>
            <div class="pull-left">
                <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
            </div>
            <input type="hidden" id="token" name="token" value="${token}"/>
        </div>
    </div>

    <div class="clearfix table-con">
        <div id="rankList"></div>
        <div id="rankListPage"></div>
    </div>
    <input type="hidden" id="storField" value="id"/>
    <input type="hidden" id="storDirection" value="true"/>
</div>

<script type="text/javascript">
    var currentPage = 1;
    var newHeadItem = "";
    var newFlag = false;
    var opts_viewGrid = null;
    var opts_page = null;
    var userDatas;
    
    var dataId='${dataId}';
    var headData = {
        "staffNo": {
            "title": "<spring:message code='user.manager.staffNo'/>",
            "width": "10%",
            "taxis": true
        },
        "alias": {
            "title": "<spring:message code='user.manager.name'/>",
            "width": "15%",
            "taxis": true
        },
        "departmentName": {
            "title": "<spring:message code='enterprise.employee.dept.lable'/>",
            "width": "20%"
        },
        "mobile": {
            "title": "<spring:message code='enterpriseList.contactPhone'/>",
            "width": "30%"
        },
        "email": {
            "title": "<spring:message code='user.manager.email'/>",
            "width": "auto",
            "taxis": true
        },
        "status": {
            "title": "<spring:message code='enterprise.user.status.title'/>",
            "width": "15%",
            "dataId": "status",
            "hideHeader": false
        }
    };

    $(document).ready(function () {
        /*多选*/
        <c:if test="${mode == 'multi'}">
            opts_viewGrid = $("#rankList").comboTableGrid({
                headData: headData,
                checkBox: true,
                height: 375,
                dataId: dataId,
                taxisFlag: true
            });
        </c:if>
        /*单选*/
        <c:if test="${mode != 'multi'}">
            opts_viewGrid = $("#rankList").comboTableGrid({
                headData: headData,
                radioBtn: true,
                height: 375,
                dataId: dataId,
                string: {
                    checkAllTxt: "<spring:message code='grid.checkbox.selectAll'/>",
                    checkCurPageTxt: "<spring:message code='grid.checkbox.selectCurrent'/>"
                },
                taxisFlag: true
            });
        </c:if>
        $.fn.comboTableGrid.setItemOp = function (tableData, rowData, tdItem, colIndex) {
            switch (colIndex) {
                case "departmentName":
                    try {
                        var departmentName = tdItem.find("p").text();
                        if (departmentName == "") {
                            tdItem.find("p").html("<spring:message code='enterprise.employee.dept.unspecified'/>").parent().attr("title", "-");
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
                default:
                    break;
            }
        };

        $.fn.comboTableGrid.taxisOp = function (headItem, flag) {
            initDataList(currentPage, headItem, flag);
        };

        opts_page = $("#rankListPage").comboPage({
            style: "page table-page",
            perDis: 10,
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

        //绑定部门选择事件
        var $button = $("#selectDeptButton");
        $button.on("click", function (evt) {
            displayDeptTree(evt);
        });
        $button.on("focus", function (evt) {
            displayDeptTree(evt);
        });
    });

    function initDataList(curPage, headItem, flag) {
        currentPage = curPage;
        newHeadItem = headItem;
        newFlag = flag;
        var authServerId = $("#authenticationMethod").find("option:selected").val();
        var url = "${ctx}/enterprise/admin/user/employeeManage";
        var filter = $("#filter").val();
        var dn = $("#dn").val();
        var deptId = $("#deptIdInput").val();
        var params = {
            "page": curPage,
            "pageSize": 10,
            "authServerId": authServerId,
            "filter": filter,
            "token": "${token}",
            "dn": dn,
            "deptId": deptId,
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
//                appIds = data[0];
                $("#rankList").setTableGridData(data[1].content, opts_viewGrid);
                $("#rankListPage").setPageData(opts_page, data[1].number, data[1].size, data[1].totalElements);
                var pageH = $("body").outerHeight();
                iframeAdaptHeight(pageH);
            }
        });
    }

    function refreshWindow() {
        initDataList(currentPage, newHeadItem, newFlag);
    }

    function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus, errorThrown) {
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

    function initDnTree() {
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
        });

        stopDefaultScroll("treeArea");
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

    function changeAuthType() {
        $("#buttonDnName").find(">span").html('<spring:message code="user.manager.ldap.node"/>');
        $("#dn").val("");
        $("#dnName").val(null);

        initDataList(1, "", false);
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

    //---------------------Department Ztree----
    var deptTreeSetting = {
        view: {
            dblClickExpand: true
        },
        data: {
            simpleData: {
                enable: true
            }
        },
        callback: {
            onClick: deptTreeNodeOnClick,
            onCheck: deptTreeNodeOnRadio
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
    function deptTreeNodeOnRadio(e, treeId, treeNode) {
        var chkedNodeIdAry = new Array(), chkedNodeNmAry = new Array();
        var zTree = $.fn.zTree.getZTreeObj("deptTree");

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
    function deptTreeNodeOnClick(e, treeId, treeNode) {
        var zTree = $.fn.zTree.getZTreeObj("deptTree");
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
        var disAttr = $("#deptTreeContent")[0].style.display;
        if (disAttr === "" || disAttr === "none") {
            stopDefaultAndBubble(evt);
            showNodeTree();
        }
    }

    //To set treeNodes data
    function loadTreeData(treeNodes) {
        var $selectButton = $("#selectDeptButton");

        var $deptTree = $("#deptTree");
        $.fn.zTree.init($deptTree, deptTreeSetting, treeNodes);
//      $deptTree.css({width: $selectButton.outerWidth() + 12 + "px"});

        var deptOffset = $selectButton.offset();
        $("#deptTreeContent").css({left: deptOffset.left + "px", top: deptOffset.top + $selectButton.outerHeight() + "px"}).slideDown("fast");

        var zTree = $.fn.zTree.getZTreeObj("deptTree"),
                nodeIds = $('#deptIdInput').val(),
                nodeIdAry = nodeIds.split(",");
        //init node selection
        if (nodeIdAry.length > 0 && nodeIdAry[0] != "") {
            $.each(nodeIdAry, function (index, id, nodeIdAry) {
                var node = zTree.getNodeByParam("id", id, null)
                zTree.selectDeptButton(node);
                zTree.checkNode(node);
            });
        } else {
            var node = zTree.getNodeByParam("id", "all", null)
            zTree.selectNode(node);
            zTree.checkNode(node);
        }
        //bind event
        $("body").bind("mousedown", onBodyDownByDevType);
        $("body").bind("click", hiddenSwitch);

        document.onkeydown = function () {
            if (window.event.keyCode == 9) {
                var isContain = hiddenSwitch(event);
                if (isContain) {
                    hideDeptTree();
                }
            }
        }
    }

    function hiddenSwitch(e) {
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
        hideDeptTree();
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
            // hideDeptTree();
        }
    }
    /*
     * 隐藏Tree
     */
    function hideDeptTree() {
        $("#deptTreeContent").fadeOut("fast");
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

    function getSelectedUser() {
        return $("#rankList").getTableGridSelected();
    }
    
</script>
</body>
</html>