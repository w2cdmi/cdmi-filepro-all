/**
 * Created by zz on 2017/4/11.
 */
var showSideText=true;
//显示、隐藏侧导航文字
$(document).on('click','.side-toggle',function () {
    $('.side-text').toggle();
    if(showSideText){
        $('.side').removeClass('side-whole').addClass('side-simple');
        $('.content').css('left','50px');
        $('.side-item .item-text').hide();
        $('.toggle-icon').removeClass('icon-pack-up').addClass('icon-open');
        showSideText=false;
    }else {
        $('.side').removeClass('side-simple').addClass('side-whole');
        $('.content').css('left','180px');
        $('.side-item .item-text').show();
        $('.toggle-icon').removeClass('icon-open').addClass('icon-pack-up');
        showSideText=true;
    }
});
//左侧菜单点击事件
/*$(document).on('click','.side-item',function (e) {
    location.href=$(this).data('url');
});*/
//用户菜单
$('.h_r_user').hover(function () {
    $(this).find('.user-menu').show();
},function () {
    $(this).find('.user-menu').hide();
});
//点击用户菜单列表
$(document).on('click','.user-menu-item',function () {
    $('.user-menu').hide();
});
//消息详细
$('.h_r_message').hover(function () {
    $(this).find('.message-detail').show();
},function () {
    $(this).find('.message-detail').hide();
});
//点击消息菜单列表
$(document).on('click','.message-item',function () {
   $('.message-detail').hide();
});
//全局checkbox事件
/*
* checkbox是否选中 $(checkbox).hasClass('ui-checkbox-selected')
* */
$(document).on('click','.checkbox-group',function () {
    var checkbox=$(this).find('.ui-checkbox');
    if(!checkbox.hasClass('ui-checkbox-disable')) {
        if (checkbox.hasClass('ui-checkbox-selected')) {
            checkbox.removeClass('ui-checkbox-selected')
        } else {
            checkbox.addClass('ui-checkbox-selected')
        }
    }
});

function getCheckboxValue(id){
	if($("[id='"+id+"']").attr("class").indexOf("ui-checkbox-selected")>-1){
		return true;
	}else{
		return false;
	}
}

function getRadioValue(id){
	
	return $("input[name='"+id+"']:checked").val();
};
//全局select组件事件
/*
* 获取选项值 $(select).find('.ui-select-label).html();
* 未封装
* */
$(document).on('click','.ui-select-label',function (e) {
    var p=$(this).parent();
    p.find('.ui-select-menu').toggle();
    e.stopPropagation();
    // window.event.cancelBubble = true
});
$(document).on('click','.ui-select-item',function (e) {
    var text=$(this).text();
    $(this).parents('.ui-select-group').find('.ui-select-label').html(text);
    $(this).parent().hide();
    e.stopPropagation();
});
$(document).on('click','.ui-select-btn',function (e) {
    $(this).parent().find('.ui-select-label').trigger('click');
    e.stopPropagation();
});
$(document).on('click',function () {
   $('.ui-select-menu').hide();
});
//切换选项
var configOption=$('.c_main');
configOption.on('click','.option-item',function () {
    var index=0,
        items=configOption.find('.option-item'),
        contents=configOption.find('.option-content');
    items.removeClass('option-header-active');
    index=items.index($(this));
    $(this).addClass('option-header-active');
    $('.curr-location-now').html($(this).text());
    contents.removeClass('show').hide().eq(index).show()
});