<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <%@ include file="../../../common/popCommon.jsp" %>
    <style>
        .form-horizontal .hidden-input {
            display: none;
        }
    </style>
</head>
<body>
<div class="pop-content pop-content-en">
    <div class="form-con">
        <form class="form-horizontal" id="createUserForm" name="createUserForm" role="form">
            <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
                <button class="close" data-dismiss="alert">×</button>
                <spring:message code="user.manager.createUserFailed"/>
            </div>
            <div class="form-group">
                <label class="col-sm-2 control-label" for="name"><em>*</em><spring:message code="user.manager.labelUserName"/></label>
                <input type="hidden" id="type" name="type" value='2'>
                <input type="hidden" id="departmentId" name="departmentId" value='0'>
                
                <div class="col-sm-4">
                    <input class="form-control" type="text" id="name" name="name" onblur="isValidLoginName()" maxlength="127"/>
                    <span class="validate-con bottom inline-span3">
                        <span id="isValidLoginNameSpan" style="color:#EA5200">
                            <span for="name" class="error" id="isValidLoginName" style="display: none;">
                                <spring:message code="enterprise.user.login.name"/>
                            </span>
                        </span>
                    </span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label" for="alias"><em>*</em><spring:message code="user.manager.labelName"/></label>

                <div class="col-sm-4">
                    <input class="form-control" type="text" id="alias" name="alias" maxlength="127"/>
                    <span class="validate-con bottom inline-span3"><div></div></span>
                </div>
            </div>
            <c:if test="${isOrganizeEnabled == true}">
                <div class="form-group">
                    <label class="col-sm-2 control-label" for="selectNode"><em>*</em><spring:message code="enterprise.employee.dept.lable"/></label>

                    <div class="col-sm-4" id="deptSectionDiv">
                        <input class="form-control" type="text" id="selectNode" name="departmentNames" readonly="true" style="cursor:pointer"/>
                        <span class="validate-con bottom inline-span3"><div></div></span>
                        <input name="departmentIds" type="hidden" class="selectDevTypeid"/>
                            <%--溢出方式设置为hidden，auto会出现滚动条 --%>
                        <div id="treeContent" class="selectDevTypeid" style="display: none; position: absolute; border: 1px #CCC solid; background-color: white;overflow: auto;">
                            <ul id="menuTree" class="ztree" style="margin-top:0;"></ul>
                        </div>
                    </div>
                </div>
            </c:if>
            <div class="form-group">
                <label class="col-sm-2 control-label" for="email"><em>*</em><spring:message code="user.manager.labelEmail"/></label>

                <div class="col-sm-4">
                    <input class="form-control" type="text" id="email" name="email" maxlength="255"/>
                    <span class="validate-con bottom inline-span3"><div></div></span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label" for="staffNo"><em>*</em>工号</label>

                <div class="col-sm-4">
                    <input class="form-control" type="text" id="staffNo" name="staffNo" maxlength="255"/>
                    <span class="validate-con bottom inline-span3"><div></div></span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label" for="mobile"><em>*</em><spring:message code="user.manager.labelPhone"/></label>

                <div class="col-sm-4">
                    <input class="form-control" type="text" id="mobile" name="mobile" maxlength="11"/>
                    <span class="validate-con bottom inline-span3"><div></div></span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label" for="description"><spring:message code="user.manager.labelDecription"/></label>

                <div class="col-sm-8">
                    <textarea class="form-control span4" id="description" name="description" maxlength="255"></textarea>
                    <span class="validate-con bottom inline-span4"><div></div></span>
                </div>
            </div>
            <input type="hidden" id="token" name="token" value="${token}"/>
        </form>
    </div>
</div>
<script type="text/javascript">
    $(document).ready(function () {
        $("#createUserForm").validate({
            rules: {
                name: {
                    required: true,
                    maxlength: [127],
                    usernameCheck: true
                },
                alias: {
                    required: true,
                    maxlength: [127]
                },
                email: {
                    required: true,
                    isValidEmail: true,
                    maxlength: [127]
                },
                mobile: {
                    required: true,
                    maxlength: [11],
                    minlength: [11],
                    contactPhoneCheck: true
                },
                description: {
                    maxlength: [255]
                }
            },
            messages: {
                name: {
                    usernameCheck: '<spring:message code="createUser.validLoginName"/>'
                }
            },
            onkeyup: function (element) {
                $(element).valid()
            },
            onfocusout: false
        });

        $.validator.addMethod(
                "usernameCheck",
                function (value, element) {
                    var pattern = /^(?!.*((<)|(>)|(\/)|(\\))).*$/;
                    if (!pattern.test(value)) {
                        return false;
                    }
                    return true;
                }
        );

        function isOrgEnabled() {
            return ${isOrganizeEnabled};
        }
    });

    $(function () {
        $("#selectNode").on("click", function (evt) {
            displayDeptTree(evt);
        });
        $("#selectNode").on("focus", function (evt) {
            displayDeptTree(evt);
        });

    });

    function displayDeptTree(evt) {
        var disAttr = $("#treeContent")[0].style.display;
        if (disAttr === "none") {
            stopDefaultAndBubble(evt);
            showNodeTree();
        }
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

    var chkedNodes;
    function nodeOnRadio(e, treeId, treeNode) {
        var chkedNodeIdAry = new Array(), chkedNodeNmAry = new Array();
        var zTree = $.fn.zTree.getZTreeObj("menuTree");

        chkedNodes = zTree.getCheckedNodes(true);
        $(chkedNodes).each(function (index, item) {
        	$("#departmentId").val(item.id);
            chkedNodeIdAry.push(item.id);
            chkedNodeNmAry.push(item.name);
        });
        $(".selectDevTypeid").val(chkedNodeIdAry.join(","));
        $("#selectNode").attr("value", chkedNodeNmAry.join(","));
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
    function initTreeNode() {
        $.ajax({
            url: '${ctx}/enterprise/admin/organize/listDeptTree',
            type: 'GET',
            async: false,
            success: function (msg) {
                var obj = eval("(" + msg + ")");
                var deviceTypeNodes = [];
                getDevTypeObj(obj, deviceTypeNodes);
                $.fn.zTree.init($("#menuTree"), deviceTypeSetting, deviceTypeNodes);
            }
        });
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
                if (msg) {
                    var obj = eval("(" + msg + ")");
                    var treeNodes = [];
                    getTreeObj(obj, treeNodes);
                    //set tree data
                    loadTreeData(treeNodes);
                }
            },
            error: function () {
            }
        });
    }

    //To set treeNodes data
    function loadTreeData(treeNodes) {
        $.fn.zTree.init($("#menuTree"), deviceTypeSetting, treeNodes);
        var deptObj = $("#selectNode"),
                deptOffset = $("#selectNode").offset();
        $("#treeContent").css({left: deptOffset.left + "px", top: deptOffset.top + deptObj.outerHeight() + "px"}).slideDown("fast");
        $('#menuTree').css({width: deptObj.outerWidth() - 12 + "px"});

        var zTree = $.fn.zTree.getZTreeObj("menuTree"),
                nodeIds = $('.selectDevTypeid').val(),
                nodeIdAry = nodeIds.split(",");
        if (nodeIdAry.length > 0 && nodeIdAry[0] != "") {
            $.each(nodeIdAry, function (index, item, nodeIdAry) {
                var node = zTree.getNodeByParam("id", item, null)
                zTree.selectNode(node);
                zTree.checkNode(node);
            });
        }
        $("body").bind("mousedown", onBodyDownByDevType);
        $("body").bind("click", hidenSwitch);
        document.onkeydown = function (e) {
            if (e.keyCode == 9 || e.which == 9) {//Tab Key
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
     */
    function getTreeObj(dataObj, treeNodes) {
        for (var i = 0; i < dataObj.length; i++) {
            treeNodes.push({id: dataObj[i].id, pId: dataObj[i].pId, name: dataObj[i].name, isParent: true});
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


    function submitUser() {
        if (!isValidLoginName()) {
            return;
        }
        if (!$("#createUserForm").valid()) {
            return;
        }
        var url = "${ctx}/enterprise/admin/user/createUser/" + "<c:out value='${authServerId}'/>";
        $.ajax({
            type: "POST",
            url: url,
            data: $('#createUserForm').serialize(),
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
                refreshParentWindow();
            }
        });
    }

    function refreshParentWindow() {
        <%--top.window.frames[0].location = "${ctx}/enterprise/admin/user/employeeManage/0";--%>
        top.window.frames[0].window.refreshWindow();
    }

    function checkValidLoginName() {
        var ret = false;
        $.ajax({
            type: "POST",
            async: false,
            url: "${ctx}/enterprise/admin/user/validLoginName",
            data: $("#createUserForm").serialize(),
            success: function (data) {
                ret = true;
            }
        });
        return ret;
    }


    function checkValidPhone() {
        var ret = false;
        $.ajax({
            type: "POST",
            async: false,
            url: "${ctx}/enterprise/admin/user/validPhone",
            data: $("#createUserForm").serialize(),
            success: function (data) {
                ret = true;
            }
        });
        return ret;
    }

    function isValidLoginName() {
        if (!checkValidLoginName()) {
            $("#isValidLoginName").removeAttr("style");
            $("#isValidLoginNameSpan").removeAttr("style");
            $("#isValidLoginName").html("<spring:message code='enterprise.user.login.name'/>");
            return false;
        }
        $("#isValidLoginName").attr("style", "display: none");
        return true;
    }
</script>
</body>
</html>
