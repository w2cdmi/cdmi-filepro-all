var enterpriseClient = require("../../module/enterprise.js");
var config = require("../../config.js");
let httpclient = require("../../module/httpclient.js");

//设置http头
var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
}

var enterpriseId = 0;
var enterpriseName = "";
var deptId = 0;

Page({

    /**
     * 页面的初始数据
     */
    data: {
        count: 60,
        marginLeft: 23,
        agree: "/disk/images/tick.png",
        isAgree: true
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        enterpriseId = options.enterpriseId;
        enterpriseName = decodeURIComponent(options.enterpriseName);
        deptId = options.deptId;
        if (enterpriseId == undefined || enterpriseName == undefined || deptId == undefined || enterpriseId == 0 || enterpriseName == ""){
            wx.navigateBack({
                delta: 1
            });
        }
        wx.setNavigationBarTitle({title: enterpriseName});
        this.setData({
            enterpriseName: enterpriseName
        });
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

    },
    isAgree: function () {
        var page = this;
        this.setData({
            isAgree: !page.data.isAgree,
        })
        if (this.data.isAgree) {
            this.setData({
                agree: "/disk/images/tick.png",
            })
        } else {
            this.setData({
                agree: "/disk/images/tick_no.png",
            })
        }
    },
    //离开文本框保存电话号码
    savePhoneNumber: function (e) {
        this.setData({
            phoneNumber: e.detail.value,
        });
    },
    saveUserName: function(e){
        this.setData({
            userName: e.detail.value,
        });
    },
    // 倒计时
    getValidCode: function () {
        if (this.data.phoneNumber && this.data.count == 60) {
            this.setData({
                marginLeft: "65"
            })
            this.tick()
        } else if (!this.data.phoneNumber) {
            wx.showToast({
                title: '请填写电话号码',
                icon: 'loading',
                duration: 1000
            })
        }
    },
    tick: function () {
        var vm = this
        if (vm.data.count > 0) {
            vm.setData({
                count: vm.data.count - 1
            });
            setTimeout(function () {
                return vm.tick()
            }, 1000)
        } else {
            vm.setData({
                count: 60,
                marginLeft: 23,
            });
        }
    },
    //获取微信 手机号码
    getPhoneNumber: function (e) {
        let page = this;
        var data = {
            iv: e.detail.iv,
            encryptedData: e.detail.encryptedData
        }
        wx.login({
            success: function (res) {
                data.code = res.code;
                httpclient.post(config.host + '/ecm/api/v2/wxOauth2/phone', data, header, (PhoneInfo) => {
                    var usePhone = PhoneInfo.phoneNumber;
                    //点击企业注册 用
                    page.setData({
                        phoneNumber: usePhone
                    })
                });

            },
            fail: function (res) {
                wx.navigateTo({
                    url: '/disk/exception/refuseAuthInfo',
                })
            }
        })
    },
    onEnterpriseLogin: function(e){
        var page = this;
        enterpriseClient.createEmployees(enterpriseId, page.data.userName, page.data.phoneNumber, deptId);
    }
})