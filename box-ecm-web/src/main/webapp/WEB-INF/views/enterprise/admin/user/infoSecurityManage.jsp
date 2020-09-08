<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token", CSRFTokenManager.getTokenForSession(session));%>

<div class="sys-content">
    <c:if test="${manager == null}">
        <div class="info-security">
            <span>当前暂无信息安全管理员</span>
            <span class="alert-warning">没有设置信息安全管理员将不能对用户的操作进行安全审计，可能存在信息安全风险，建议设置</span>
        </div>
        <div class="btn-group">
            <button type="button" class="btn btn-primary" onClick="setInfoManager()">
                <spring:message code="enterprise.security.manager.add"/>
            </button>
        </div>
    </c:if>
    <c:if test="${manager != null}">
        <div class="info-security">
            <span>当前信息安全管理员:<strong style="margin-left: 10px;letter-spacing: 1px;">${manager.alias}/${manager.staffNo}</strong></span>
        </div>
        <div class="btn-group">
            <button type="button" class="btn btn-primary" onClick="setInfoManager()">
                <spring:message code="enterprise.security.manager.modify"/>
            </button>
        </div>
    </c:if>
</div>

<script type="text/javascript">
    function setInfoManager() {
        var url = "${ctx}/enterprise/admin/user/chooseEnterpriseUser/0";
        top.ymPrompt.win({
            message: url,
            width: 900,
            height: 650,
            title: '<spring:message code="enterprise.security.manager.add"/>',
            iframe: true,
            btn: [
                ['<spring:message code="common.OK"/>', 'yes', false, "btn-focus"],
                ['<spring:message code="common.close"/>', 'no', true, "btn-cancel"]
            ],
            handler: function (tp) {
                if (tp == 'yes') {
                    var array = top.ymPrompt.getPage().contentWindow.getSelectedUser();
                    if (array == "") {
                        handlePrompt("error",'<spring:message code="user.manager.selectOneUser"/>');
                        return;
                    }

                    submitInfoManager(array[0]);
                }
            }
        });
        top.ymPrompt_addModalFocus("#btn-focus");
    }

    function submitInfoManager(user) {
        var url = "${ctx}/enterprise/admin/user/setInfoSecurityManager/0";
        $.ajax({
            type: "POST",
            url: url,
            data: {
                "enterpriseUserId": user
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
                top.window.frames[0].window.reloadCurrentTab();
            }
        });
    }

</script>