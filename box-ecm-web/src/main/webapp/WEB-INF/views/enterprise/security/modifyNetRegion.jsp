<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="cse" uri="http://cse.huawei.com/custom-function-taglib"%>  
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="modifyAdminForm" name="modifyAdminForm">
   		<div id="createNetRegionDiv">
   	        <input type="hidden" id="id" name="id" value="<c:out value='${securityRole.id}'/>"  class="span4" />
   	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='common.name'/>:</label>
	            <div class="controls">
	                <input type="text" id="netRegionName" name="netRegionName"  value="<c:out value='${securityRole.netRegionName}'/>" class="span4" />
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <div class="control-group">
	        	<label class="control-label" for=""><spring:message code='common.description'/>:</label>
	            <div class="controls">
	                <textarea name="netRegionDesc" class="span4" id="netRegionDesc" maxlength="255"><c:out value='${securityRole.netRegionDesc}'/></textarea>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	        <div class="control-group">
                <label class="control-label"><spring:message code='common.net.ipaddress'/></label>
                <div class="controls">
                    <div class="clearfix">
                        <button type="button" class="btn" onClick="createIPAddress()"><i></i><spring:message code='common.addbtn'/></button>
                        <button type="button" class="btn" onClick="deleteNetRegionIp()"><i ></i><spring:message code='common.delete'/></button>
                    </div>
                    <div class="table-con">
                        <div id="netRegionIpList"></div>
                        <div id="page"></div>
                    </div>
                </div>
            </div>
            <div id="manageBtnCon" class="btn-con" style="margin-left:180px">
			    <button id="modifySpaceBtn" type="button" class="btn btn-primary" onclick="submitModify()"><spring:message code='common.modify'/></button>
			    <button id="cancelSpaceBtn" type="button" class="btn" onclick="submitCancel()"><spring:message code='common.cancel'/></button>
			</div>
        </div>
	</form>
	
	<form class="form-horizontal" id="creatIPAddressForm" name="creatIPAddressForm">
        	<div id="addIPDiv" class="hide">
		        <div class="control-group" >
		        	<label class="control-label" for=""><em>*</em><spring:message code='network.region.start.ip'/>:</label>
		            <div class="controls">
		                <input type="text" id="ipStart" name="ipStart" class="span4" />
		                <span class="validate-con bottom"><div></div></span>
		            </div>
		        </div>
		         <div class="control-group">
		        	<label class="control-label" for=""><em>*</em><spring:message code='network.region.end.ip'/>:</label>
		            <div class="controls">
		                <input type="text" id="ipEnd" name="ipEnd" class="span4" />
		                <span class="validate-con bottom"><div></div></span>
		            </div>
		        </div>
		        <input type="hidden" id="netRegionId" name="netRegionId" value="<c:out value='${securityRole.id}'/>" class="span4" />
		        <input type="hidden" id="token" name="token" value="${token}"/>	
		        <div class="control-group">
		        	<div class="controls">
		        		<button type="button" class="btn" onclick="addNewIPAddress()"><spring:message code='common.addbtn'/></button>
		        		<button type="button" class="btn" onclick="cancelNewIPAddress()"><spring:message code='common.cancel'/></button>
		        	</div>
		        </div>
	        </div>	
	</form> 
		
    </div>
</div>
<script type="text/javascript">
var currentPage = 1;
var opts_viewGrid_top = null;
var headDataStatistics = {
        "ipStart" : {
            "title" : "<spring:message code='network.region.start.ip'/>",
            "width" : "45%"
        },
        "ipEnd" : {
            "title" : "<spring:message code='network.region.end.ip'/>",
            "width" : "45%"
        }
};
var pageOpts = $("#page").comboPage({
	style : "page"
});

$(document).ready(function() {
		$("#modifyAdminForm").validate({ 
			rules: { 
				netRegionName: { 
					   required:true, 
					   maxlength:[128]
				   },
				   netRegionDesc:{
					   maxlength:[255]
				   }
			}
	    }); 
		$("#creatIPAddressForm").validate({ 
			rules: { 
				   ipStart:{
					   required:true, 
					   maxlength:[255]
				   },
				   ipEnd: { 
					   required:true,
					   maxlength:[255]
				   }
			}
	    });
		$("label").tooltip({ container:"body", placement:"top", delay: { show: 100, hide: 0 }, animation: false });
		
		opts_viewGrid_top = $("#netRegionIpList").comboTableGrid({
	        headData : headDataStatistics,
	        dataId : "id",
	        height : 120,
	        checkBox : true
	    });
		
		 $.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
				switch (colIndex) {
					case "modifiedAt":
					try {
						tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
						break;
					} catch (e) {}
					break;
				}
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				initIPAddressDataList(curPage)
			}
			
			initIPAddressDataList(1);
});

function initIPAddressDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listNetRegionIp/<c:out value='${appId}'/>/?id=<c:out value='${securityRole.id}'/>";
	var StatisticsParams = {
		"pageNumber" : curPage,
		"token" : "${token}"
	};
	$.ajax({
		type : "POST",
		url : statistics_url,
		data : StatisticsParams,
		error : function(request) {
			handlePrompt("error",'<spring:message code="operation.failed" />');
		},
		success : function(data) {
			$("#netRegionIpList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}

function submitModify() {
	if(!$("#modifyAdminForm").valid()) {
        return false;
    }  
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/modifyNetRegion/<c:out value='${appId}'/>/",
        data:$('#modifyAdminForm').serialize(),
        error: function(request) {
        	handlePrompt("error",'<spring:message code="common.modifyFail"/>');
        },
        success: function() {
        	top.ymPrompt.close();
        	top.handlePrompt("success",'<spring:message code="common.modifySuccess"/>');
        	top.window.frames[0].initNetRegionDataList(1);
        }
    });
}

function submitCancel(){
	top.ymPrompt.close();
}

function createIPAddress() {
	$("#addIPDiv").show();
	$("#createNetRegionDiv").hide();	
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='network.region.create.title'/>");	
}

function addNewIPAddress() {
	if(!$("#creatIPAddressForm").valid()) {
        return false;
    }
	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createNetRegionIp/<c:out value='${appId}'/>/",
        data:$("#creatIPAddressForm").serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="space.tip.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}	
        },
        success: function(data) {
        	    $("#addIPDiv").hide();
				$("#createNetRegionDiv").show();
        	   initIPAddressDataList(1);
        }
    });
}

function cancelNewIPAddress() {
	$("#addIPDiv").hide();
	$("#createNetRegionDiv").show();
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='network.region.add'/>");	
}

function deleteNetRegionIp(){
	var idArray = $("#netRegionIpList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="common.select.none.notice"/>');
		return;
	}

	var ids = idArray.join(",");
	var url="${ctx}/enterprise/security/deleteNetRegionIp/<c:out value='${appId}'/>/";
	$.ajax({
        type: "POST",
        url:url,
        data:{ids:ids,token:"${token}"},
        error: function(request) {
        	top.handlePrompt("error",'<spring:message code="common.modifyFail"/>');
        },
        success: function() {
        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
        	initIPAddressDataList(1);
        }
    });	
}
</script>
</body>
</html>
