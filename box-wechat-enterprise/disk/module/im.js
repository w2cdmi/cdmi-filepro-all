var config = require("../config.js");
var httpclient = require("httpclient.js");
var util = require("utils.js");
var NIM = require("NIM_Web_NIM_v3.8.0-beta.js");

var host = config.host;
var token = getApp().globalData.token;   //登录token

var sessions = {};

function IMInit(callback) {
    wx.request({
        url: host + "/ecm/api/v2/im/config",
        method: 'GET',
        header: {
            'content-type': 'application/json',
            'Authorization': getApp().globalData.token
        },
        success: function (res) {
            //返回200，才认为调用成功
            if (res.statusCode == 200) {
                //返回的信息中没有错误指示
                if (typeof (res.data.imaccid) != 'undefined' && typeof (res.data.imaccid) != '') {
                    getApp().globalData.IMAccount = res.data.imaccid;
                    getApp().globalData.IMToken = res.data.impwd;

                    if(typeof(callback) == 'function'){
                        callback();
                    }
                }else{
                    return createIMAccount(callback);
                }
                return true;
            }
        },
        fail: function (res) {
            wx.hideLoading();
            wx.showModal({
                title: '提示',
                content: '网络异常！请重新登录',
                showCancel: false,
                success: function (res) {
                    wx.navigateTo({
                        url: '/disk/enterprise/enterpriselist',
                    })
                }
            });
        }
    });
}
//创建IM账号
function createIMAccount(callback) {
    wx.showLoading({
        title: '创建账号',
        mask: true
    })
    wx.request({
        url: host + "/ecm/api/v2/im/syncImAccount",
        method: 'POST',
        header: {
            'content-type': 'application/x-www-form-urlencoded',
            'Authorization': getApp().globalData.token
        },
        data: {
            icon: getApp().globalData.avatarUrl
        },
        success: function (res) {
            //返回200，才认为调用成功
            if (res.statusCode == 200) {
                if (typeof (res.data.imaccid) != 'undefined' && typeof (res.data.imaccid) != '') {
                    getApp().globalData.IMAccount = res.data.imaccid;
                    getApp().globalData.IMToken = res.data.impwd;

                    if(typeof(callback) == 'function'){
                        callback();
                    }
                }else{
                    wx.showToast({
                        title: '创建IM账号失败！',
                    })
                    return false;
                }
            }
            return true;
        },
        fail: function (res) {
            wx.hideLoading();
            wx.showModal({
                title: '提示',
                content: '网络异常！请重新登录',
                showCancel: false,
                success: function (res) {
                    wx.navigateTo({
                        url: '/disk/enterprise/enterpriselist',
                    })
                }
            })
        }
    });
}

function getUserInfoByIMAccountId(imaccid, callback){
    var url = host + "/ecm/api/v2/im/" + imaccid;
    var data = {};
    var header = {
        'Authorization': getApp().globalData.token
    }
    httpclient.get(url, data, header, callback);
}

function onConnect() {
    console.log('连接成功');
}
function onWillReconnect(obj) {
    // 此时说明 SDK 已经断开连接, 请开发者在界面上提示用户连接已断开, 而且正在重新建立连接
    console.log('即将重连');
}
function onDisconnect(error) {
    // 此时说明 SDK 处于断开状态, 开发者此时应该根据错误码提示相应的错误信息, 并且跳转到登录页面
    console.log('丢失连接');
    if (error) {
        switch (error.code) {
            // 账号或者密码错误, 请跳转到登录页面并提示错误
            case 302:
                break;
            // 重复登录, 已经在其它端登录了, 请跳转到登录页面并提示错误
            case 417:
                break;
            // 被踢, 请提示错误后跳转到登录页面
            case 'kicked':
                break;
            default:
                break;
        }
    }
}
function onError(error) {
}

//合并session
function mergeSessions(olds, news) {
    if (!olds) { olds = []; }
    if (!news) { return olds; }
    if (!NIM.util.isArray(news)) { news = [news]; }
    if (!news.length) { return olds; }
    var options = {
        sortPath: 'updateTime',
        desc: true
    };
    return NIM.util.mergeObjArray([], olds, news, options);
}

//消息存放到本地
function pushMsg(msgs) {
    var IMMessage = wx.getStorageSync(config.storageIMMessageName);
    if (!Array.isArray(msgs)) { msgs = [msgs]; }
    var sessionId = msgs[0].sessionId;
    IMMessage = IMMessage || {};
    IMMessage[sessionId] = mergeMsgs(IMMessage[sessionId], msgs);
    wx.setStorageSync(config.storageIMMessageName, IMMessage);
}
//合并消息
function mergeMsgs(olds, news) {
    if (!olds) { olds = []; }
    if (!news) { return olds; }
    if (!NIM.util.isArray(news)) { news = [news]; }
    if (!news.length) { return olds; }
    var options = {
        keyPath: 'idClient',
        sortPath: 'time'
    };
    return NIM.util.mergeObjArray([], olds, news, options);
}
//两次消息时间不到一分钟，不显示本次发送或接收到的信息,超过则返回显示的时间
//oldTime : 上次发送或接收到的信息的时间
//newTime ： 最近发送或接收到的信息的时间
//isFirstTime : 是否为第一次消息时间
function convertMessageTime(oldTime, newTime, isFirstTime) {
    if (typeof (oldTime) == 'undefined' || oldTime == '') {
        return '';
    }
    var nowTime = new Date().getTime();
    if (typeof (newTime) == 'undefined' || newTime == '') {
        newTime = nowTime;
    }
    
    var differTime = nowTime - oldTime;
    //今天消息时间显示处理
    differTime = newTime - oldTime;
    //小于60秒
    if (differTime < 60 * 1000) {
        if (typeof (isFirstTime) != 'undefined' && isFirstTime != "" && isFirstTime) {
            return util.getFormatDate(oldTime, 'hh:mm');
        }
        return '';
    } else if (differTime < (24 * 60 * 60 * 1000)){
        return util.getFormatDate(oldTime, 'hh:mm');
    }else{
        return util.getFormatDate(oldTime, "yyyy-MM-dd hh:mm");
    }
}
//获取群信息
function getTeamInfo(nim_chat, chatObjectId){
    nim_chat.getTeam({
        teamId: chatObjectId,
        done: function (error, team) {
            if (!error){
                return "";
            }
            return team;
        }
    });
}

/**
 * 聊天链接
 * scene 场景
 */
function shareChatLink(sessionId, chatObjectId, objectNick){
    var scene = 'p2p';
    if(typeof(sessionId) != 'undefined'){
        var index = sessionId.indexOf("-");
        if (index == -1) {
            wx.showToast({
                title: '发送失败！',
            });
            return;
        }
        scene = sessionId.substring(0, index);
    }
    
    if (scene == 'team') {
        return {
            title: getApp().globalData.userName + "邀请你进入群聊：" + objectNick,
            path: '/disk/chat/index?type=teamchat&enterpriseId=' + getApp().globalData.enterpriseId + '&sessionId=' + sessionId + '&chatObjectId=' + chatObjectId + '&objectNick=' + objectNick + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName),
            imageUrl: '../images/shares/share-card-chat.png',
            success: function (res) {
                // 转发成功
            },
            fail: function (res) {
                // 转发失败
            }
        }
    } else {
        return {
            title: getApp().globalData.userName + "邀请你聊天",
            path: '/disk/chat/index?type=p2pchat&enterpriseId=' + getApp().globalData.enterpriseId + '&sessionId=p2p-' + getApp().globalData.IMAccount + '&chatObjectId=' + getApp().globalData.IMAccount + '&objectNick=' + getApp().globalData.userName + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName),
            imageUrl: '../images/shares/share-card-chat.png',
            success: function (res) {
                // 转发成功
            },
            fail: function (res) {
                // 转发失败
            }
        }
    }
}
//群消息提示
function teamNotificationMsg(attach, objectNicks) {
    var notifyMessage = ""
    switch (attach.type) {
        case 'updateTeam':
            if (typeof (attach.team.custom) != 'undefined' && attach.team.custom != ""){
                var isNotifyScreen = JSON.parse(attach.team.custom).isNotifyScreen;
                if (isNotifyScreen){
                    notifyMessage = "截屏聊天记录,将通知群内所有成员";
                }else{
                    notifyMessage = "关闭截屏聊天记录通知";
                }
            }else{
                notifyMessage = "群信息更新：" + attach.team;
            }
            break;
        case 'addTeamMembers':
            // notifyMessage = "'" + objectNicks[attach.team.from] + "'添加群成员：" + objectNicks[attach.team.accounts[0]];
            notifyMessage = "添加新成员";
            break;
        case 'removeTeamMembers':
            notifyMessage = "'" + objectNicks[attach.accounts[0]] + "'被'" + objectNicks[attach.team.owner] + "'踢出群组";
            break;
        case 'acceptTeamInvite':
            notifyMessage = "接受入群邀请";
            break;
        case 'passTeamApply':
            notifyMessage = "'" + objectNicks[attach.users[0].account] + "'进入聊天";
            break;
        case 'addTeamManagers':
            notifyMessage = "添加群聊管理员";
            break;
        case 'removeTeamManagers':
            notifyMessage = "删除群聊管理员";
            break;
        case 'leaveTeam':
            notifyMessage = "'" + objectNicks[attach.users[0].account] + "'退出群组";
            break;
        case 'dismissTeam':
            notifyMessage = "群主已经解散该群组";
            break;
        case 'transferTeam':
            notifyMessage = "群组拥有者已经变更";
            break;
    }
    return notifyMessage;
}
//聊天置顶
function setChatTop(sessionId,isTop,callback){
    wx.showLoading({
        title: '处理中',
        mask: true
    })
    var sessionTops = wx.getStorageSync(config.sessionTopsKey);
    if (sessionTops == "") {
        sessionTops = {};
    }
    if (isTop) {
        sessionTops[sessionId] = 0;
        wx.setStorageSync(config.sessionTopsKey, sessionTops);
    } else {
        var sessionTopsNew = {};
        for (var key in sessionTops) {
            if (key != sessionId) {
                sessionTopsNew[key] = sessionTops[key];
            }
        }
        wx.setStorageSync(config.sessionTopsKey, sessionTopsNew);
    }
    if (typeof(callback)=='function'){
        callback();
    }
    wx.hideLoading();
}

module.exports = {
    IMInit,
    onConnect,
    onWillReconnect,
    onDisconnect,
    onError,
    mergeSessions,
    pushMsg,
    shareChatLink,
    convertMessageTime,
    teamNotificationMsg,
    setChatTop,
    getUserInfoByIMAccountId
};