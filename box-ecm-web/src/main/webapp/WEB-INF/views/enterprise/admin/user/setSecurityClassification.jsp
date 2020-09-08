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
</head>
<body>
<div class="pop-content pop-content-en">
    <div class="form-con">
        <form class="form-horizontal" id="form" role="form">
            <div class="alert alert-error input-medium controls" id="errorTip" style="display:none">
                <button class="close" data-dismiss="alert">×</button>
                <spring:message code="user.manager.createUserFailed"/>
            </div>
            <div class="form-group">
                <label class="col-sm-2 control-label"><em>*</em>工号</label>

                <div class="col-sm-6">
                    <span class="form-control" readonly>${user.staffNo}</span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label"><em>*</em><spring:message code="user.manager.labelName"/></label>

                <div class="col-sm-6">
                    <span class="form-control" readonly>${user.alias}</span>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-2 control-label"><em>*</em><spring:message code="enterprise.user.staffSecretLevel"/></label>

                <div class="col-sm-4">
                    <select class="form-control" name="staffSecretLevel">
                        <option value="1" <c:if test="${user.staffSecretLevel == 1}">selected</c:if>>一级</option>
                        <option value="2" <c:if test="${user.staffSecretLevel == 2}">selected</c:if>>二级</option>
                        <option value="3" <c:if test="${user.staffSecretLevel == 3}">selected</c:if>>三级</option>
                        <option value="4" <c:if test="${user.staffSecretLevel == 4}">selected</c:if>>四级</option>
                        <option value="5" <c:if test="${user.staffSecretLevel == 5}">selected</c:if>>五级</option>
                    </select>
                </div>
            </div>
            <input type="hidden" id="token" name="token" value="${token}"/>
            <input type="hidden" name="enterpriseUserId" value="${user.id}"/>
        </form>
    </div>
</div>
<script type="text/javascript">

    function submitSecurityClassification() {
        var url = "${ctx}/enterprise/admin/user/setSecurityClassification/" + "<c:out value='${authServerId}'/>";
        $.ajax({
            type: "POST",
            url: url,
            data: $('#form').serialize(),
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
</script>
</body>
</html>
