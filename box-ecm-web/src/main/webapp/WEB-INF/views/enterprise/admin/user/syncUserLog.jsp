<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%request.setAttribute("token",CSRFTokenManager.getTokenForSession(session));%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../../common/common.jsp"%>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>
</head>
<body>
<div class="sys-content">
    <div class="clearfix control-group">
            <a class="return btn btn-small pull-right"
                href='${ctx}/enterprise/admin/user/employeeManage/<c:out value="${authServerId}"/>'><i
                class="icon-backward"></i>&nbsp;<spring:message code="common.back" /></a>
            <h5 class="pull-left" style="margin: 3px 0 0 4px;">
                <a href='${ctx}/enterprise/admin/user/employeeManage/<c:out value="${authServerId}"/>'><c:out value="${authServrName}"/></a>&nbsp;&gt;&nbsp;
                <spring:message code="enterprise.user.sync.log.title" />
            </h5>
    </div>
    
    <div class="clearfix">
        <div class="pull-right form-search">
                <div class="input-append">                   
                  <input type="text" id="filter" name="filter" class="span3 search-query" value='<c:out value="${filter}"/>' placeholder='<spring:message code="enterprise.user.sync.log.search"/>' />
                  <button type="button" class="btn" id="searchButton"><i class="icon-search"></i></button>
                </div>
        </div>
    </div>
    
    <div id="myPage"></div>
    <div class="table-con">
            <div id="rankList"></div>
            <div id="rankListPage"></div>
    </div>
    
</div>
</body>
<script type="text/javascript">
var opts_viewGrid = null;
var opts_page = null;
var headData = 
{
    "createTime" : 
    {
            "title" : '<spring:message code="common.time"/>',
            "width" : "220px"
    },
    "operatDesc" : 
    {
        "title" : '<spring:message code="common.details"/>',
        "width" : "auto"
    }
};
$(document).ready(function() {
    opts_viewGrid = $("#rankList").comboTableGrid({
        headData : headData,
        height : 740,
        dataId : "id"
    });
    $.fn.comboTableGrid.setItemOp = function(tableData,rowData, tdItem, colIndex) {
        switch (colIndex) {
        case "createTime":
            try {
                var size = tdItem.find("p").text();
                for ( var i = 0; i <catalogData.length; i++) {
                    if(size == catalogData[i].createTime){
                        _txt = catalogData[i].createTime;
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
                        var date = _year+"-"+_month+"-"+_day+" "+_hours+":"+_min+":"+_sec;
                        tdItem.find("p").html(date).parent().attr("title", date);
                    }
                }
            } catch (e) {
            }
            break;
        default:
            break;
        }
    };
    
    $.fn.comboTableGrid.taxisOp = function(headItem, flag) {
        initDataList(1);
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
    initSearchEvent();
    initDataList(1);
    
});

function initSearchEvent() {
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
}

function initDataList(curPage) {
    var url = "${ctx}/enterprise/admin/ldapuser/getSyncUserLog";
    var filter = $("#filter").val();
    var params = {
            "page" : curPage,
            "filter" : filter,
            "authServerId":'${authServerId}',
            "token":'${token}'            
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
            $("#rankList").setTableGridData(catalogData, opts_viewGrid);
            $("#rankListPage").setPageData(opts_page, data.number,data.size, data.totalElements);
            var pageH = $("body").outerHeight();
            top.iframeAdaptHeight(pageH);
        }
    });
}

</script>
</html>
