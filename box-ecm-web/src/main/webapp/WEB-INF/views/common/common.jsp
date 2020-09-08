<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.huawei.sharedrive.uam.util.CSRFTokenManager"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=10" />
<meta http-equiv="X-UA-Compatible" content="IE=9" />
<meta http-equiv="X-UA-Compatible" content="IE=8" />
<META HTTP-EQUIV="Expires" CONTENT="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-control"
	CONTENT="no-cache, no-store, must-revalidate">
<META HTTP-EQUIV="Cache" CONTENT="no-cache">
<title><spring:message code="main.title" /></title>
<link rel="shortcut icon" type="image/x-icon" href="${ctx}/static/skins/default/img/logo.ico">
<link href="${ctx}/static/skins/default/css/bootstrap.min.css"rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/ymPrompt/ymPrompt.css"rel="stylesheet" type="text/css" />
<link href="${ctx}/static/skins/default/css/header.css" type="text/css" rel="stylesheet">
<link href="${ctx}/static/skins/default/css/base.css" type="text/css" rel="stylesheet">
<script src="${ctx}/static/js/public/jquery-1.10.2.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/validate/jquery.validate.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/bootstrap.min.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/ymPrompt.source.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/common.js" type="text/javascript"></script> 
<script src="${ctx}/static/js/public/JQbox-hw-grid.js" type="text/javascript"></script>
<script src="${ctx}/static/js/public/JQbox-hw-page.js" type="text/javascript"></script>

<script src="${ctx}/static/js/public/common_stor.js"></script>

<%@ include file="./messages.jsp"%>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);
request.setAttribute("token", org.springframework.web.util.HtmlUtils.htmlEscape(CSRFTokenManager.getTokenForSession(session)));
%>
<script type="text/javascript">
	ymPrompt.setDefaultCfg({
		closeTxt:'<spring:message code="common.close"/>',
		okTxt:'<spring:message code="common.OK"/>',
		cancelTxt:'<spring:message code="common.cancel"/>'
	})
	
$(function(){
	if('<spring:message code="main.language"/>' == "en"){
		$("head").append('<link href="${ctx}/static/skins/default/css/public_en.css" rel="stylesheet"	type="text/css" />	');
	}
})

 $(document).ready(function() {
		$(".option-item").each(function(e, v) {
				$(v).bind("click",function(t, h) {
						$(".option-item").each(function(k1,v1) {
							$(v1).removeClass("option-header-active");
							$("#"+ $(v1).attr("value")).css("display","none");
						});
						$(this).addClass("option-header-active");
						$("#"+ $(this).attr("value")).css("display","block");
				})
		});
 });
	$(function () {  
		  window.Modal = function () {  
		    var reg = new RegExp("\\[([^\\[\\]]*?)\\]", 'igm');  
		    var alr = $("#com-alert");  
		    var ahtml = alr.html();  
		  
		    var _tip = function (options, sec) {  
		        alr.html(ahtml);    // 复原  
		        alr.find('.ok').hide();  
		        alr.find('.cancel').hide();  
		        alr.find('.modal-content').width(500);  
		        _dialog(options, sec);  
		          
		        return {  
		            on: function (callback) {  
		            }  
		        };  
		    };  
		  
		    var _alert = function (options) {  
		      alr.html(ahtml);  // 复原  
		      alr.find('.ok').removeClass('btn-success').addClass('btn-primary');  
		      alr.find('.cancel').hide();  
		      _dialog(options);  
		  
		      return {  
		        on: function (callback) {  
		          if (callback && callback instanceof Function) {  
		            alr.find('.ok').click(function () { callback(true) });  
		          }  
		        }  
		      };  
		    };  
		  
		    var _confirm = function (options) {  
		      alr.html(ahtml); // 复原  
		      alr.find('.ok').removeClass('btn-primary').addClass('btn-success');  
		      alr.find('.cancel').show();  
		      _dialog(options);  
		  
		      return {  
		        on: function (callback) {  
		          if (callback && callback instanceof Function) {  
		            alr.find('.ok').click(function () { callback(true) });  
		            alr.find('.cancel').click(function () { return; });  
		          }  
		        }  
		      };  
		    };  
		  
		    var _dialog = function (options) {  
		      var ops = {  
		        msg: "提示内容",  
		        title: "操作提示",  
		        btnok: "确定",  
		        btncl: "取消"  
		      };  
		  
		      $.extend(ops, options);  
		  
		      var html = alr.html().replace(reg, function (node, key) {  
		        return {  
		          Title: ops.title,  
		          Message: ops.msg,  
		          BtnOk: ops.btnok,  
		          BtnCancel: ops.btncl  
		        }[key];  
		      });  
		        
		      alr.html(html);  
		      alr.modal({  
		        width: 250,  
		        backdrop: 'static'  
		      });  
		    }  
		  
		    return {  
		tip: _tip,  
		      alert: _alert,  
		      confirm: _confirm  
		    }  
		  
		  }();  
		});  
	function showTip(msg, sec, callback){  
	    if(!sec) {  
	        sec = 1000;  
	    }  
	    Modal.tip({  
	        title:'提示',  
	        msg: msg  
	    }, sec);  
	    setTimeout(callback, sec);  
	}  
	  
	/** 
	 * 显示消息 
	 * @param msg 
	 */  
	function showMsg(msg, callback){  
	    Modal.alert({  
	        title:'提示',  
	        msg: msg,  
	        btnok: '确定'  
	    }).on(function (e) {  
	        if(callback){  
	            callback();  
	        }  
	     }); 
	    setInterval(hideMsg,3000);
	}  
	function hideMsg(msg, callback){  
		$("#com-alert").modal('hide');
	}
	/** 
	 * 模态对话框 
	 * @param msg 
	 * @returns 
	 */  
	function showConfirm(msg,callback){  
	    //var res = false;  
	    Modal.confirm(  
	      {  
	          title:'提示',  
	          msg: msg,  
	      }).on( function (e) {  
	          callback();  
	          //res=true;  
	      });  
	    //return res;  
	} 
</script>


<!-- system modal start -->  
    <div id="com-alert" class="modal" style="z-index:9999;display: none;" >  
      <div class="modal-dialog modal-sm">  
        <div class="modal-content">  
          <div class="modal-header">  
            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span><span class="sr-only">Close</span></button>  
            <h5 class="modal-title"><i class="fa fa-exclamation-circle"></i> [Title]</h5>  
          </div>  
          <div class="modal-body small" style="text-align: center;">  
            <p>[Message]</p>  
          </div>  
          <div class="modal-footer" >  
            <button type="button" class="btn btn-primary ok" data-dismiss="modal">[BtnOk]</button>  
            <button type="button" class="btn btn-default cancel" data-dismiss="modal">[BtnCancel]</button>  
          </div>  
        </div>  
      </div>  
    </div>  
  <!-- system modal end --> 
