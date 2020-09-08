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
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <%@ include file="../../../common/popCommon.jsp" %>
</head>
<body>
    <div class="pop-content pop-content-en">
        <div class="clearfix">
            <form class="form-horizontal" id="openAccountForm" name="openAccountForm">
                <div class="control-group">
                    <label class="control-label"><em>*</em><spring:message code="enterprise.employee.dept.lable"/></label>

                    <div class="controls" id="deptSectionDiv">
                        <input type="text" id="selectNode" name="departmentNames" readonly="true" style="width: 620px"/>
                        <span class="validate-con bottom inline-span3"><div></div></span>

                        <div id="treeContent" class="selectDevTypeid">
                            <ul id="deptTree" class="ztree" style="margin-top:0;"></ul>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
<link href="${ctx}/static/zTree/zTreeStyle.css" rel="stylesheet" type="text/css"/>
<script src="${ctx}/static/zTree/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>
<script type="text/javascript">
    /*
     *show department node as one tree
     *
     */
    /*多选*/
    var deptTreeSetting;
    <c:if test="${mode == 'multi'}">
    deptTreeSetting = {
        view: {
            selectedMulti: true,
            dblClickExpand: true,
            expandSpeed: ""
        },
        data: {
            simpleData: {
                enable: true
            }
        },
        callback: {
            onClick: deptTreeOnClick,
            onCheck: deptTreeOnCheck
        },
        check: {
            autoCheckTrigger: false,
            chkboxType: {"Y": "", "N": ""},
            chkStyle: "checkbox",
            enable: true,
            nocheckInherit: false,
            chkDisabledInherit: false,
            radioType: "all"
        }
    };
    </c:if>
    /*单选*/
    <c:if test="${mode != 'multi'}">
    deptTreeSetting = {
        view: {
            selectedMulti: false,
            dblClickExpand: true,
            expandSpeed: ""
        },
        data: {
            simpleData: {
                enable: true
            }
        },
        callback: {
            onClick: deptTreeOnClick,
            onCheck: deptTreeOnCheck
        },
        check: {
            autoCheckTrigger: false,
            chkStyle: "radio",
            enable: true,
            nocheckInherit: false,
            chkDisabledInherit: false,
            radioType: "all"
        }
    };
    </c:if>

    /*
     * 下拉树的点击事件
     */
    function deptTreeOnClick(e, treeId, treeNode) {
        var zTree = $.fn.zTree.getZTreeObj("deptTree");

        //反转check状态
        zTree.checkNode(treeNode, !treeNode.checked);

        showDeptName(zTree.getCheckedNodes());
    }

    function deptTreeOnCheck(e, treeId, treeNode) {
        //勾选时同步选择状态
        var zTree = $.fn.zTree.getZTreeObj("deptTree");

        zTree.selectNode(treeNode);

        showDeptName(zTree.getCheckedNodes());
    }

    function showDeptName(nodes) {
        var array = [];
        for(var i in nodes) {
            array.push(nodes[i].name);
        }

        $("#selectNode").attr("value", array.join(","));
    }
    /*
     * 展示SelectTree
     */
    function showNodeTree() {
        $.ajax({
            url: '${ctx}/enterprise/admin/organize/listDeptTree',
            type: 'GET',
            async: false,
            success: function (msg) {
                if (msg) {
                    var obj = eval("(" + msg + ")");
                    //set tree data
                    loadTreeData(obj);
                }
            },
            error: function () {

            }
        });
    }

    //To set treeNodes data
    function loadTreeData(dataObj) {
        var treeNodes = [];
        for (var i = 0; i < dataObj.length; i++) {
            treeNodes.push({id: dataObj[i].id, pId: dataObj[i].pId, name: dataObj[i].name, isParent: false});
        }
        var tree = $.fn.zTree.init($("#deptTree"), deptTreeSetting, treeNodes);
        tree.expandAll(true);

        var deptObj = $("#selectNode");
        var deptOffset = deptObj.offset();
        $("#treeContent").css({left: deptOffset.left + "px", top: deptOffset.top + deptObj.outerHeight() + "px"}).slideDown("fast");
    }

    $(function () {
        //initial data
        showNodeTree();
    });

    function getSelectedDepartment() {
        var ids = [];
        var nodes = $.fn.zTree.getZTreeObj("deptTree").getCheckedNodes();

        for (var i in nodes) {
            ids.push(nodes[i].id);
        }

        return ids;
    }

</script>
</html>
