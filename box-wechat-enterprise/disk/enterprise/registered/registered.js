// disk/enterprise/registered.js
let config = require("../../config.js");
let httpclient = require("../../module/httpclient.js");
//设置http头
var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
}
Page({

    /**
     * 页面的初始数据
     */
    data: {
        count: 60,
        marginLeft: 23,
        agree: "/disk/images/tick.png",
        isAgree: true//同意用户
    },

    onLoad: function(options){
        wx.setNavigationBarTitle({
            title: '注册企业',
        })
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
                        phone: usePhone
                    })
                });
            },
            fail: function (res) {
            }
        })
    },
    //当焦点离开"企业名"，将 企业名 设置进入data
    setEnterpriseName: function (e) {
        let eName = e.detail.value
        this.setData({
            eName: eName
        })
    },
    //当焦点离开"手机号"，将 手机号 设置进入data
    setPhoneNumber: function (e) {
        let ePhone = e.detail.value
        this.setData({
            phone: ePhone
        })
    },
    //点击注册企业  按钮 
    registerEnterprise: function () {
        if (this.data.eName && this.data.phone) {
            wx.showLoading({
                title: '注册中...',
                mask: true
            })
            var data = {
                phone: this.data.phone,
                name: this.data.eName
            }
            wx.login({
                success: function (res) {
                    data.code = res.code;
                    wx.getUserInfo({
                        success: function (res) {
                            data.encryptedData = res.encryptedData;
                            data.iv = res.iv;
                            //请求后台，创建账号
                            wx.request({
                                url: config.host + '/ecm/api/v2/wxmp/authCode/registerbyWxmp',
                                method: "POST",
                                data: data,
                                header: {
                                    'content-type': 'application/json',
                                    'x-device-sn': '123', //能否获取手机相关信息？
                                    'x-device-type': 'web',
                                    'x-device-os': 'mp',
                                    'x-device-name': 'mp',
                                    'x-client-version': 'v0.1'
                                },
                                success: function (result) {
                                    if (result.statusCode == 500) {
                                        wx.hideLoading();
                                        wx.showModal({
                                            title: '提示',
                                            content: '注册失败！！',
                                            showCancel: false
                                        })
                                    }
                                    if (result.statusCode == 200) {
                                        wx.navigateBack({
                                            delta: 2
                                        })
                                        // login();
                                    }
                                }
                            })
                        },
                        fail: function (res) {
                            wx.hideLoading();
                            wx.openSetting({
                                success: function (res) {
                                    if (!res.authSetting["scope.userInfo"]) {
                                        login();
                                    }
                                }
                            })
                        }
                    })
                }
            })
        } else if (!this.data.eName) {
            wx.showModal({
                title: '提示',
                content: '企业名不能为空',
            })
        } else {
            wx.showModal({
                title: '提示',
                content: '手机号没获取或获取失败，请重试',
            })
        }
    },

    //是否同意用户协议 动态显示协议图标
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
    // 倒计时 控制
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
    }

})