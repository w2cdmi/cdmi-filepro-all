<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../../common/common.jsp"%>
</head>
<body>
<div class="pop-content">
	<div class="form-con">
   	<form class="form-horizontal" id="creatForm" name="creatForm">
      <div id="createFileTypeDiv">
	        <div class="control-group">
	        	<label class="control-label" for=""><em>*</em><spring:message code='common.name'/>:</label>
	            <div class="controls">
	                <input type="text" id="safeLevelName" name="safeLevelName" class="span4"/>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>

	         <div class="control-group">
	        	<label class="control-label" for=""><spring:message code='common.description'/>:</label>
	            <div class="controls">
	                <textarea name="safeLevelDesc" class="span4" id="safeLevelDesc" maxlength="255"></textarea>
	                <span class="validate-con bottom"><div></div></span>
	            </div>
	        </div>
	        <input type="hidden" id="strRlues" name="strRlues" class="span4" />
	        <input type="hidden" id="token" name="token" value="${token}"/>	
	         <div class="control-group">
                <label class="control-label"><spring:message code='file.type.policy'/>:</label>
                <div class="controls">
                    <div class="clearfix">
                        <div class="pull-left">
                            <button type="button" id="createNewPolicyID" class="btn" onClick="createNewFilePolicy()"><i></i><spring:message code='common.create'/></button>
                            <button type="button" id="deteNewPolicyID" class="btn" onClick="deleteNewFilePolicy()"><i ></i><spring:message code='common.delete'/></button>
                        </div>
                        <div class="pull-right">
                            <a href="#" title="<spring:message code='file.type.policyHelp'/>"><spring:message code='file.type.policyLevel'/></a>
                        </div>

                    </div>
                    <div class="table-con">
                        <div id="addNewDocumentList"></div>
                         <div id="page"></div>
                    </div>
                </div>
            </div>
            <div id="manageBtnCon" class="btn-con" style="margin-left:180px">
			    <button id="createSafeLevelBtn" type="button" class="btn btn-primary" onclick="submitCreate()"><spring:message code='common.create'/></button>
			    <button id="cancelSafeLevelBtn" type="button" class="btn" onclick="submitCancel()"><spring:message code='common.cancel'/></button>
			</div>
          </div>
	</form>
	
	<form class="form-horizontal" id="creatSafeForm" name="creatSafeForm">
		<div id="addNewPolicyDiv" class="hide">
   	 		<div class="control-group ">
                <span><spring:message code="fileType.message.tip"/></span>
       		</div>
       		<div class="control-group">
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="fileType.user.upload"/></p><br/>
                    <div class="control-new-label">
			        	<select class="span3" id="securityRoleId" name="securityRoleId" size="6">
				                <option value="-1" selected><spring:message code='security.role.any'/></option>
			        		<c:forEach items="${safeRoleList}" var="oper">
			        			<option value="<c:out value='${oper.id}'/>"><c:out value='${oper.roleName}'/></option>
			        		</c:forEach>
						</select>
                    </div>
                </div>
                <div class="pull-left icon-add"><i class="icon-plus"></i></div>
                <div class="pull-left">
                    <p class="controls-strategy"><spring:message code="fileType.net.type"/></p><br/>
                    <div class="control-new-label">
	       				<select class="span2 span-new-two" id="netRegionId" name="netRegionId" size="6">
	               	 		<option value="-1" selected title="<spring:message code='network.region.any'/>"><spring:message code="network.region.any"/></option>
        					<c:forEach items="${netRegionList}" var="oper">
        						<option title="<c:out value='${oper.netRegionName}'/>" value="<c:out value='${oper.id}'/>"><c:out value='${oper.netRegionName}'/></option>
        					</c:forEach>
						</select>
                    </div>
                </div>
            </div> 
	        <input type="hidden" id="token" name="token" value="${token}"/>
	         <input type="hidden" id="resourceSecurityLevelId" name="resourceSecurityLevelId" value="<c:if test="${securityRole.id == null}" ><c:out value='-1'/></c:if>
		        <c:if test="${securityRole.id != null}" ><c:out value='${securityRole.id}'/></c:if>" class="span4" />
	        <div class="control-group">
		        	<div class="controls">
		        		<button type="button" class="btn" onclick="addNewPolicy()"><spring:message code='common.addbtn'/></button>
		        		<button type="button" class="btn" onclick="cancelNewPolicy()"><spring:message code='common.cancel'/></button>
		        	</div>
		   </div>
        </div>
	</form>
    </div>
</div>
<script type="text/javascript"> 
var currentPage = 1;
var opts_viewGrid_top = null;
var pageOpts = $("#page").comboPage({
	style : "page"
});
var headDataStatistics = {
        "newPolicy" : {
            "title" : "<spring:message code='file.type.policy'/>",
            "width" : "90%"
        }
    };

$(document).ready(function() {
	$("#safeLevelName").focus();
	opts_viewGrid_top = $("#addNewDocumentList").comboTableGrid({
        headData : headDataStatistics,
        dataId : "id",
        checkBox : true
    });  
	
		$("#creatForm").validate({ 
			rules: { 
				   priority:{
					   required:true, 
					   digits:true,
					   maxlength:[20]
				   },
				   safeLevelName:{
					   required:true, 
					   maxlength:[128]
				   },
				   safeLevelDesc: { 
					   maxlength:[255]
				   }
			}
	    });
		
		 $.fn.comboTableGrid.setItemOp = function(tableData, rowData, tdItem, colIndex){
				switch (colIndex) {
					case "newPolicy":
						try {
							tdItem.find("p").html("<spring:message code='fileType.policy.help' arguments='"+rowData.safeRoleName+","+rowData.netRegionName+","+$("#safeLevelName").val()+"' />");
							tdItem.attr("title",tdItem.find("p").text());
							break;
						} catch (e) {}
						break;
						// 这是谁写的两个case一样？
// 					case "newPolicy":
// 						try {
// 							tdItem.find("p").text(getLocalTime(rowData.modifiedAt));
// 							break;
// 						} catch (e) {}
// 						break;
				}
			}
			
			$.fn.comboPage.pageSkip = function(opts, _idMap, curPage){
				initFileTypeDataList(curPage)
			} 
			
			initFileTypeDataList(1);
});

function initFileTypeDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listResourceStrategy/<c:out value='${appId}'/>/?id=<c:if test='${securityRole.id==null}' ><c:out value='-1'/></c:if><c:if test='${securityRole.id!=null}' ><c:out value='${securityRole.id}'/></c:if>";
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
			$("#addNewDocumentList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}

function initNewTypeDataList(curPage) {
	var statistics_url = "${ctx}/enterprise/security/listNewResourceStrategy/<c:out value='${appId}'/>/?id=<c:if test='${securityRole.id==null}' ><c:out value='-1'/></c:if><c:if test='${securityRole.id!=null}' ><c:out value='${securityRole.id}'/></c:if>";
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
			$("#addNewDocumentList").setTableGridData(data.content, opts_viewGrid_top);
			$("#page").setPageData(pageOpts, data.number, data.size, data.totalElements);
		}
	});
}

function addRules(){
	var node = $("#ruleCon").clone(true).removeAttr("id");
	node.find("button").remove().end().append('<button type="button" class="btn" onclick="deleteRules(this)">-</button>');
	$("#ruleCon").parent().find(".help-block").before(node);
}

function deleteRules(obj){
	$(obj).parent().remove();
}

function submitCreate() {
	var obj = $("#creatForm .ruleCon");
	var strRlues="";
	for(var i=0; i<obj.length; i++){
		var sigleRule = $(obj[i]).find("select[name=securityRoleId]").val()+','+ $(obj[i]).find("select[name=netRegionId]").val();
		if(i==0){
			strRlues += sigleRule;
		}else{
			strRlues += "@"+ sigleRule;
			
		}
	}
	$("#strRlues").val(strRlues);
	
	if(!$("#creatForm").valid()) {
        return false;
    }

	$.ajax({
        type: "POST",
        url:"${ctx}/enterprise/security/createSafeLevel/<c:out value='${appId}'/>/",
        data:$('#creatForm').serialize(),
        error: function(request) {
        	if(request.status==409){
        		handlePrompt("error",'<spring:message code="security.level.conflict"/>');
        	}else{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}	
        },
        success: function(data) {
        	if(data == "AlreadyDomainNameOrContactEmail")
        	{
        		handlePrompt("error",'<spring:message code="common.createFail"/>');
        	}
        	else
        	{	
        		top.ymPrompt.close();
        	    top.handlePrompt("success",'<spring:message code="common.createSuccess"/>');
        	    top.window.frames[0].initFileTypeDataList(1);
        	}
        }
    });
}

function submitCancel(){
	top.ymPrompt.close();
	deleteCloseNewFileType();
}

function createNewFilePolicy() {
	if($("#safeLevelName").val() != ""){
		
		$("#createFileTypeDiv").hide();
		$("#addNewPolicyDiv").show();
		$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='filetype.newpolicy.title'/>");
	}
}

function addNewPolicy() {
	var securityRoleId = $("#securityRoleId").val();
	var netRegionId = $("#netRegionId").val();
	if(securityRoleId==-1&&netRegionId==-1){
		handlePrompt("error",'<spring:message code="upload.security.level.create.rule.desc"/>');
		return;
	}

	
	if(!$("#creatSafeForm").valid()) {
        return false;
    }
	if("${securityRole.id}" == null || "${securityRole.id}" == "") {
		$.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/security/addResourceStrategy/<c:out value='${appId}'/>/",
	        data:$('#creatSafeForm').serialize(),
	        error: function(request) {
	        	if(request.status==409){
	        		handlePrompt("error",'<spring:message code="upload.security.level.conflict"/>');
	        	}else{
	        		handlePrompt("error",'<spring:message code="common.createFail"/>');
	        	}	
	        },
	        success: function(data) {
	        	if(data == "AlreadyDomainNameOrContactEmail")
	        	{
	        		handlePrompt("error",'<spring:message code="common.createFail"/>');
	        	}
	        	else
	        	{	
	        		$("#addNewPolicyDiv").hide();
	        		$("#createFileTypeDiv").show();
	        	    initNewTypeDataList(1);
	        	}
	        }
	    });
	}else {
		$.ajax({
	        type: "POST",
	        url:"${ctx}/enterprise/security/createResourceStrategy/<c:out value='${appId}'/>/",
	        data:$('#creatSafeForm').serialize(),
	        error: function(request) {
	        	if(request.status==409){
	        		handlePrompt("error",'<spring:message code="upload.security.level.conflict"/>');
	        	}else{
	        		handlePrompt("error",'<spring:message code="common.createFail"/>');
	        	}	
	        },
	        success: function(data) {
	        	if(data == "AlreadyDomainNameOrContactEmail")
	        	{
	        		handlePrompt("error",'<spring:message code="common.createFail"/>');
	        	}
	        	else
	        	{	
	        		$("#addNewPolicyDiv").hide();
	        		$("#createFileTypeDiv").show();
	        	    initFileTypeDataList(1);
	        	}
	        }
	    });
	}
	
}

function deleteNewFilePolicy() {
	var idArray = $("#addNewDocumentList").getTableGridSelected();
	if (idArray == "") {
		handlePrompt("error",'<spring:message code="common.select.none.notice"/>');
		return;
	}

	var ids = idArray.join(",");
	if("${securityRole.id}" == null || "${securityRole.id}" == "") {
		var url="${ctx}/enterprise/security/deleteNewAddResourceStrategy/<c:out value='${appId}'/>/";
		$.ajax({
	        type: "POST",
	        url:url,
	        data:{ids:ids,"token" : "${token}"},
	        error: function(request) {
	        	top.handlePrompt("error",'<spring:message code="common.has.been.used"/>');
	        },
	        success: function() {
	        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
	        	initNewTypeDataList(1);
	        }
	    });	
	}else {
		var url="${ctx}/enterprise/security/deleteResourceStrategy/<c:out value='${appId}'/>/";
		$.ajax({
	        type: "POST",
	        url:url,
	        data:{ids:ids,"token" : "${token}"},
	        error: function(request) {
	        	top.handlePrompt("error",'<spring:message code="common.has.been.used"/>');
	        },
	        success: function() {
	        	top.handlePrompt("success",'<spring:message code="common.delete.success"/>');
	        	initFileTypeDataList(1);
	        }
	    });	
	}
}
function cancelNewPolicy() {
	$("#addNewPolicyDiv").hide();
	$("#createFileTypeDiv").show();
	$("#ym-window",window.parent.document).find(".ym-header-text").text("<spring:message code='security.level.modify'/>");	
}

function deleteCloseNewFileType() {
	var url="${ctx}/enterprise/security/deleteCloseNewFileType/<c:out value='${appId}'/>/";
	$.ajax({
        type: "POST",
        url:url,
        data:{token:"${token}"},
        error: function(request) {
        },
        success: function() {
        	initNewTypeDataList(1);
        }
    });
}
</script>
</body>
</html>
