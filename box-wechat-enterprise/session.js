var config = require("/disk/config.js");
var robot = require("/disk/module/robot.js");

var times = 0;  //一次登录等待的次数（计算时间，一次登录等待十秒）
var interval;   //等待登录成功计时器
var __params;   //记录登录时传入的参数
var isLogining = false;    //是否已经在登录

/**
 * 检查Session是否过期，过期后重新生成。
 */
function invokeAfterLogin(callback) {
    //等待登录成功回调用方法
    waitAndInvoke(callback);
}

/**
 * 判断token是否存在
 */
function tokenIsExist() {
    var app = getApp();

    //App还未生成，返回true 全局变量globalData还未生成
    if (app == undefined || app.globalData == undefined) {
        return false
    }

    var token = app.globalData.token;
    //Token不存在
    if (token == undefined || token == "") {
        return false;
    }

    return true;
}

//token是否有效
function isValid() {
    //已过有效期
    var token = getApp().globalData.token;
    var expire = getApp().globalData.expire;
    if (token == undefined || token == '' || expire == undefined || expire == 0) {
        return false
    }
    var now = new Date().getTime();
    if (expire > now) {
        return true;
    } else {
        return false;
    }
}

//等待登录方法
function waitAndInvoke(callback) {
    var times = 0;
    clearInterval(interval);
    interval = setInterval(function () {
        //等待登录成功执行回掉方法
        if (tokenIsExist() && isValid()) {
            if (typeof (callback) == 'function') {
                callback();
                clearInterval(interval);
            }
        }

        if (times == 80) {
            console.log("登录失败！！");
            clearInterval(interval);
        }
        times++;
    }, 100);
}

/**
 * 登录方法
 */
function login(params) {
    if (isLogining) {
        return;
    } else {
        isLogining = true;
    }

    if (tokenIsExist() && isValid()) {
        isLogining = false;
        return;
    }

    wx.showLoading({
        title: '登录中...',
        mask: true
    });

    //保存登录参数
    if (params) {
        __params = params;
    }

    wx.login({
        success: function (res) {
            var code = res.code;
            if (code) {
                //获取用户信息
                wx.getUserInfo({
                    success: function (res) {
                        var userInfo = res.userInfo;
                        var data = {
                            appId: config.appId,
                            code: code,
                            encryptedData: res.encryptedData,
                            iv: res.iv,
                        };

                        //合并用户传递的参数
                        if (__params) {
                            Object.assign(data, __params);
                        }

                        //向后台发送请求，由后台获取微信用户的ID，后台检查用户是否注册；
                        //如果没有注册，则给用户注册一个个人帐号。
                        wx.request({
                            url: config.host + '/ecm/api/v2/token/wxmp',
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
                                //存在多个企业，需要提醒用户选择企业进入
                                if (result.data.enterpriseList != undefined) {
                                    getApp().globalData.enterpriseList = result.data.enterpriseList;
                                    if (getApp().globalData.isJumpEenterpriseListPage) {
                                        wx.navigateTo({
                                            url: '/disk/enterprise/enterpriselist',
                                        })
                                    }
                                    wx.hideLoading();
                                    clearInterval(interval);    //清楚等待登录方法
                                    isLogining = false;
                                    getApp().globalData.isJumpEenterpriseListPage = false;
                                    return;
                                }
                                if (result.data.token != undefined) {
                                    getApp().globalData.token = result.data.token;
                                    var timeout = result.data.timeout * 1000;
                                    getApp().globalData.expire = new Date().getTime() + timeout; //过期时间为当前时间 + timeout（单位：秒）
                                    getApp().globalData.enterpriseId = result.data.enterpriseId;
                                    if (result.data.enterpriseId == 0) {
                                        getApp().globalData.enterpriseName = '个人账号';
                                    } else {
                                        getApp().globalData.enterpriseName = result.data.enterpriseName;
                                    }
                                    getApp().globalData.userId = result.data.userId;
                                    getApp().globalData.userName = result.data.alias;
                                    getApp().globalData.avatarUrl = userInfo.avatarUrl;
                                    getApp().globalData.cloudUserId = result.data.cloudUserId;
                                    getApp().globalData.accountType = result.data.type;
                                    getApp().globalData.accountId = result.data.accountId;
                                    if (result.data.isAdmin != undefined && result.data.isAdmin == 1) {
                                        getApp().globalData.isAdmin = true;
                                    } else {
                                        getApp().globalData.isAdmin = false;
                                    }


                                    //启动巡检机器人备份状态
                                    robot.openRobotCheck();
                                    //设置定时器，自动执行登录，防止会话超时。
                                    setTimeout(login, timeout);
                                    getApp().globalData.isJumpEenterpriseListPage = true;   //可以跳转
                                } else {
                                    openAccount();
                                }
                                wx.hideLoading();
                                isLogining = false;
                                getApp().globalData.isShowNetException = false;
                            },
                            fail: function (res) {
                                wx.hideLoading();
                                isLogining = false;
                                clearInterval(interval);
                                wx.showModal({
                                    title: '提示',
                                    content: '登录服务器失败，请稍后重试！',
                                    showCancel: false
                                })
                            }
                        })
                    },
                    fail: function (res) {
                        wx.hideLoading();
                        isLogining = false;
                        clearInterval(interval);
                        // wx.navigateTo({
                        //     url: '/disk/exception/refuseAuthInfo',
                        // })
                        wx.openSetting({
                            success: function (res) {
                                if (!res.authSetting["scope.userInfo"]) {
                                    login();
                                }
                            }
                        })
                    }
                });
            } else {
                console.log('获取用户信息失败！');
                wx.navigateTo({
                    url: '/disk/exception/refuseAuthInfo',
                })
            }
        },
        fail: function (res) {
            wx.hideLoading();
            clearInterval(interval);
            wx.showModal({
                title: '提示',
                content: '登录服务器失败，请稍后重试！',
                showCancel: false
            });
        },
        complete: function () {
            wx.hideLoading();
            isLogining = false;
        }
    });
}

function openAccount() {
    wx.showLoading({
        title: '创建账号',
        mask: true
    })
    wx.login({
        success: function (res) {
            var code = res.code;
            if (code) {
                //获取用户信息
                wx.getUserInfo({
                    success: function (res) {
                        var userInfo = res.userInfo;
                        var data = {
                            code: code,
                            encryptedData: res.encryptedData,
                            iv: res.iv,
                            enterpriseId: getApp().globalData.enterpriseId,
                            appId: config.appId
                        };

                        //请求后台，创建账号
                        wx.request({
                            url: config.host + '/ecm/api/v2/wxOauth2/openWxMpAccount',
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
                                    wx.showModal({
                                        title: '提示',
                                        content: '开户失败！！',
                                        showCancel: false
                                    })
                                }
                                if (result.statusCode == 200) {
                                    login({
                                        enterpriseId: getApp().globalData.enterpriseId
                                    });
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
                });
            } else {
                console.log('获取用户登录态失败！' + res.errMsg)
            }
        }
    });
}

module.exports = {
    login,
    invokeAfterLogin
};
