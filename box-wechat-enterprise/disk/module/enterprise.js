var config = require("../config.js");
var httpclient = require("httpclient.js");

function getUserPhone(data, callback){
    var header = {
        Authorization: getApp().globalData.token,
        'content-type': 'application/json'
    };
    wx.login({
        success: function (res) {
            data.code = res.code;
            return httpclient.post(config.host + '/ecm/api/v2/wxOauth2/phone', data, header, callback);
        }
    })
}

function registerEnterprise(data, callback){
    var header = {
        Authorization: getApp().globalData.token,
        'content-type': 'application/json'
    };
    wx.login({
        success: function (res) {
            data.code = res.code;
            wx.getUserInfo({
                success: function (res) {
                    data.encryptedData = res.encryptedData;
                    data.iv = res.iv;
                    return httpclient.post(config.host + '/ecm/api/v2/wxmp/authCode/registerbyWxmp', data, header, callback);
                },
                fail : function(res) {
                    wx.navigateTo({
                        url: '/disk/exception/refuseAuthInfo',
                    })
                }
            })
        }
    })
}

function getDeptAndEmployees(deptId, callback){
    var header = {
        Authorization: getApp().globalData.token,
        'content-type': 'application/x-www-form-urlencoded'
    };
    var data = {
        deptId: deptId
    }
    return httpclient.get(config.host + '/ecm/api/v2/enterprise/depts_employees', data, header, callback);
}
//创建部门
function createDept(data, callback){
    var header = {
        'Authorization': getApp().globalData.token,
        'content-type': 'application/x-www-form-urlencoded'
    };
    return httpclient.post(config.host + '/ecm/api/v2/enterprise/depts', data, header, callback);
}

function deleteDept(deptId, callback){
    var header = {
        'Authorization': getApp().globalData.token
    };
    var data = {};
    return httpclient.remove(config.host + '/ecm/api/v2/enterprise/depts/' + deptId, data, header, callback);
}
//新增员工
function createEmployees(enterpriseId, name, phone, deptId){
    wx.showLoading({
        title: '生成企业账号',
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
                            enterpriseId: enterpriseId,
                            name: name,
                            phone: phone,
                            deptId: deptId
                        };

                        //请求后台，创建账号
                        wx.request({
                            url: config.host + '/ecm/api/v2/wxmp/authCode/registerUser',
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
                                        content: '生成员工账号失败！！',
                                        showCancel: false
                                    })
                                }
                                if (result.statusCode == 200) {
                                    wx.reLaunch({
                                        url: '/disk/index',
                                    })
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
//删除员工
function deleteEmploy(employId, callback){
    var header = {
        Authorization: getApp().globalData.token
    };
    var data = {}
    return httpclient.remove(config.host + '/ecm/api/v2/enterprise/employees/' + employId, data, header, callback);
}
//设置部门文档外发审核
function setDocumentAudit(deptId, approve, callback){
    var header = {
        Authorization: getApp().globalData.token
    };
    var data = {}
    return httpclient.put(config.host + '/ecm/api/v2/enterprise/depts/' + deptId + '/approve?approve=' + approve, data, header, callback);
}
//获取部门管理员
function getDepartmentManager(deptId, callback){
    var header = {
        Authorization: getApp().globalData.token
    };
    var data = {
        type: "director"
    }
    return httpclient.get(config.host + '/ecm/api/v2/enterprise/depts/'+ deptId +'/specialists/special', data, header, callback);
}
//获取知识管理员
function getDepartmentKnowledger(deptId, callback) {
    var header = {
        Authorization: getApp().globalData.token
    };
    var data = {
        type: "knowledge"
    }
    return httpclient.get(config.host + '/ecm/api/v2/enterprise/depts/' + deptId + '/specialists/special', data, header, callback);
}
//获取员工信息
function getEmploye(userId, callback){
    var header = {
        Authorization: getApp().globalData.token
    };
    return httpclient.get(config.host + '/ecm/api/v2/enterprise/depts/' + deptId + '/specialists/special', data, header, callback);
}

module.exports = {
    getUserPhone,
    registerEnterprise,
    getDeptAndEmployees,
    createEmployees,
    createDept,
    deleteDept,
    deleteEmploy,
    setDocumentAudit,
    getDepartmentManager,
    getDepartmentKnowledger
};