var session = require("../../session.js");

const wxRequest = (url, params) => {

    wx.showLoading({
        title: '加载中',
        icon: 'loading',
        mask: true
    })

    wx.request({
        url: url,
        method: params.method || 'GET',
        data: params.data || {},
        header: params.header || {
            'content-type': 'application/json'
        },
        success: (res) => {
            //只要与服务器正常交互，就会回调此方法，哪怕返回4XX、5XX错误
            wx.hideLoading();

            //返回200，才认为调用成功  201:表示创建成功
            if (res.statusCode == 200 || res.statusCode == 201) {
                //返回的信息中没有错误指示
                if (res.data.type == undefined || res.data.type != "error") {
                    (typeof params.success == 'function') && params.success(res.data);
                }
            }

            if (res.statusCode == 404) {
                if (typeof (res.data) != 'undefined' && res.data != "") {
                    if (res.data.code == "NoSuchFile") {
                        wx.showModal({
                            title: '提示',
                            content: '文件已经不存在',
                            showCancel: false
                        });
                    }
                }
            }

            if (res.statusCode == 403) {
                wx.showModal({
                    title: '提示',
                    content: '文件访问权限不足',
                    showCancel: false
                });
            }

            if (res.statusCode == 409) {
                if (typeof (res.data) != 'undefined' && res.data != "") {
                    if (res.data.code == "RepeatNameConflict") {
                        wx.showModal({
                            title: '提示',
                            content: '文件夹已经存在',
                            showCancel: false
                        })
                    }
                }
            }

            if (res.statusCode == 401) {
                session.login({
                    enterpriseId: getApp().globalData.enterpriseId,
                });
                //等待登录成功后，执行
                session.invokeAfterLogin(function () {
                    wx.navigateBack({
                        delta: 0
                    });
                });
            }
            wx.hideLoading();
            return res;
        },
        fail: (res) => {
            
            wx.hideLoading();
            params.fail && params.fail(res);
            session.login();
        },
        complete: (res) => {
            params.complete && params.complete(res);
        }
    });
}

const wxRequestSync = (url, params) => {

    wx.request({
        url: url,
        method: params.method || 'GET',
        data: params.data || {},
        header: params.header || {
            'content-type': 'application/json'
        },
        success: (res) => {

            //返回200，才认为调用成功  201:表示创建成功
            if (res.statusCode == 200 || res.statusCode == 201) {
                //返回的信息中没有错误指示
                if (res.data.type == undefined || res.data.type != "error") {
                    (typeof params.success == 'function') && params.success(res.data);
                }
            }

            if (res.statusCode == 404) {
                if (typeof (res.data) != 'undefined' && res.data != "") {
                    if (res.data.code == "NoSuchFile") {
                    }
                }
            }

            if (res.statusCode == 403) {
                wx.showModal({
                    title: '提示',
                    content: '文件访问权限不足',
                    showCancel: false
                });
            }

            if (res.statusCode == 409) {
                if (typeof (res.data) != 'undefined' && res.data != "") {
                    if (res.data.code == "RepeatNameConflict") {
                        wx.showModal({
                            title: '提示',
                            content: '文件夹已经存在',
                            showCancel: false
                        })
                    }
                }
            }

            if (res.statusCode == 401) {
                session.login({
                    enterpriseId: getApp().globalData.enterpriseId,
                });
            }
            return res;
        },
        fail: (res) => {
            params.fail && params.fail(res);
        },
        complete: (res) => {
            params.complete && params.complete(res);
        }
    });
}

function put(url, data, header, success) {
    wxRequest(url, {
        data: data,
        header: header,
        method: "PUT",
        success: success
    });
}

function get(url, data, header, success) {
    return wxRequest(url, {
        "data": data,
        "header": header,
        "method": "GET",
        success: success
    });
}

function getSync(url, data, header, success) {
    return wxRequestSync(url, {
        "data": data,
        "header": header,
        "method": "GET",
        success: success
    });
}

function post(url, data, header, success) {
    wxRequest(url, {
        data: data,
        header: header,
        method: "POST",
        success: success
    });
}

function remove(url, data, header, success) {
    wxRequest(url, {
        data: data,
        header: header,
        method: "DELETE",
        success: success
    });
}

module.exports = {
    put,
    get,
    getSync,
    post,
    remove
};