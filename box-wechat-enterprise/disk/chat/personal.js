// disk/chat/personal.js
var im = require("../module/im.js");
var util = require("../module/utils.js");

var avatarUrl = "";     //用户头像
var nick = "";      //用户昵称
var account = "";       //用户账号
var accountType = 0;   //账号类型
var enterpriseName = "";//企业名称
var telphone = "";      //电话号码
var phone = "";         //电话
var email = "";         //邮箱


Page({

    /**
     * 页面的初始数据
     */
    data: {
        avatarUrl: avatarUrl,
        nick: nick,
        account: account,
        accountType: accountType,
        enterpriseName: enterpriseName,
        telphone: telphone,
        phone: phone,
        email: email
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        // wx.showLoading({
        //     title: '加载中',
        //     mask: true
        // })

        avatarUrl = options.avatarUrl;
        nick = options.nick;
        account = options.account;

        var page = this;
        if (getApp().globalData.enterpriseId == 0){
            page.setData({
                avatarUrl: avatarUrl,
                nick: nick,
                account: account,
                isEnterpriseAccount: false,
                accountTypeName: util.formatAccountType(getApp().globalData.accountType)
            });
        }else{
            im.getUserInfoByIMAccountId(account,function(data){
                page.setData({
                    avatarUrl: avatarUrl,
                    nick: nick,
                    account: account,
                    enterpriseName: data.enterpriseName,
                    departmentName: data.departmentName,
                    accountType: data.accountType,
                    accountTypeName: util.formatAccountType(data.accountType),
                    telphone: data.mobile,
                    phone: data.phone,
                    email: data.email,
                    isEnterpriseAccount: true
                });
            });
        }

        
        // wx.hideLoading();
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {

    },

    sendMessage: function(e){
        //scene 场景为私聊p2p
        var sessionId = "p2p-" + account;
        var chatObjectId = account;
        var objectNick = nick;
        wx.navigateTo({
            url: "chat?sessionId=" + sessionId + "&chatObjectId=" + chatObjectId + "&objectNick=" + objectNick,
        });
    }
})