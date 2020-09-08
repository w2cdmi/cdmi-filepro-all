// disk/me/me.js
var util = require("../module/utils.js");
var user = require("../module/user.js");
var config = require("../config.js");
var httpclient = require("../module/httpclient.js");
var session = require("../../session.js");

Page({

    /**
     * 页面的初始数据
     */
    data: {
        enterpriseName: '',  //企业名称
        storageSize: '',
        spaceUsed: 0,
        spaceSize: 0
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {

    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        var page = this;
        session.login();
        session.invokeAfterLogin(function () {
            wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
            page.setData({
                enterpriseName: getApp().globalData.enterpriseName,
                accountType: getApp().globalData.accountType,
                accountTypeName: util.formatAccountType(getApp().globalData.accountType),
                avatarUrl: getApp().globalData.avatarUrl,
                nick: getApp().globalData.userName,
                spaceUsed: 0,
                spaceSize: 0,
                isAdmin: getApp().globalData.isAdmin
            });

            var userId = getApp().globalData.userId;
            user.getUserInfo(getApp().globalData.userId, function(data){
                var spaceUsed = (data.spaceUsed / data.spaceQuota) * 100;
                var spaceSize = util.formatFileSize(data.spaceUsed) + "/" + util.formatFileSize(data.spaceQuota);
                if (spaceSize == "/"){
                    spaceSize = 0;
                }
                page.setData({
                    spaceUsed: spaceUsed,
                    spaceSize: spaceSize
                });
            });

            user.getUserVipInfo(function (data) {
                page.setData({
                    expireDate: util.getFormatDate(data.expireDate,"yyyy-MM-dd")
                });
            });

            var res = wx.getStorageInfoSync();
            if (res.keys.length == 0){
                page.setData({
                    storageSize: 0
                });
            }else{
                page.setData({
                    storageSize: res.currentSize
                });
            }
        });
    },

    /**
     * 生命周期函数--监听页面隐藏
     */
    onHide: function () {

    },

    /**
     * 生命周期函数--监听页面卸载
     */
    onUnload: function () {

    },

    /**
     * 页面相关事件处理函数--监听用户下拉动作
     */
    onPullDownRefresh: function () {

    },

    /**
     * 页面上拉触底事件的处理函数
     */
    onReachBottom: function () {

    },

    switchEnterprise: function () {
        var enterpriseList = getApp().globalData.enterpriseList;
        if (enterpriseList != '' && enterpriseList.length > 0){
            wx.navigateTo({
                url: '/disk/enterprise/enterpriselist',
            })
        }else{
            wx.showModal({
                title: '提示',
                content: '对不起，你只有一个账号',
                showCancel: false
            })
        }
    },
    bindtoEnterpriseManage:function(){
        wx.navigateTo({
            url: '../enterprise/management',
        })
    },
    openVIP:function(){
        var url = config.host + "/ecm/api/v2/tempAccount/up2VIP";
        var data = {"orderId":1};
        var header = {
            'Authorization': getApp().globalData.token
        }
        httpclient.post(url, data, header);
    },
    gotoBuyPage:function(){
        wx.navigateTo({
            url: '../buy/buyPersonStorage',
        });
    },
    gotorecycle: function () {
        wx.navigateTo({
            url: '../recycle/recycle',
        });
    }
})