// 引入IM配置
var config = require('../config');
var im = require("../module/im.js");
var nim = require("../module/NIM_Web_NIM_v3.8.0-beta.js");
var util = require("../module/utils.js");
var session = require("../../session.js");

var chatObjectId = '';    //聊天对象名字
var objectNick = '';          //对象昵称
var sessionId = '';     //当前会话ID
var enterpriseId = '';
var storageIMSessionsName = '';
var storageIMMessageName = config.storageIMMessageName;
var storageAvatarUrlsName = config.storageAvatarUrlsName;
var storageObjectNicksName = config.storageObjectNicksName;
var teamAvatarUrl = '../images/icon/message-active.png';

var nim_chat = '';      //IM实例对象
var scene = '';         //场景 p2p:单对单
var avatarUrls = {};    //聊天头像集合
var objectNicks = {};   //用户昵称
var connectStatus = false; //连接状态
var isNotifyScreen = false; //是否开启截屏通知

var scrollTop = 0;
var touchStartTime = 0;
var touchEndTime = 0;
var lastTapTime = 0;

// 声明聊天室页面
Page({
    /**
   * 聊天室使用到的数据，主要是消息集合以及当前输入框的文本
   */
    data: {
        inputContent: '',
        messages: [],
        ownerName: '',
        avatarUrls: {}
    },
    onLoad(e) {
        //url参数获取
        chatObjectId = e.chatObjectId;
        objectNick = e.objectNick;
        sessionId = e.sessionId;
        enterpriseId = e.enterpriseId;
        getApp().globalData.enterpriseId = enterpriseId;
        getApp().globalData.enterpriseName = decodeURIComponent(e.eName);

        avatarUrls = wx.getStorageSync(storageAvatarUrlsName);
        objectNicks = wx.getStorageSync(storageObjectNicksName);

        if (avatarUrls == "") {
            avatarUrls = {};
        }
        if (objectNicks == "") {
            objectNicks = {};
        }
    },
    //页面渲染
    onReady() {
    },

    /**
     * 页面卸载时，退出聊天室
     */
    onUnload() {
    },

    /**
     * 页面切换到后台运行时，退出聊天室
     */
    onHide() {
    },
    onShareAppMessage: function (options) {
        return im.shareChatLink(sessionId, chatObjectId, objectNick);
    },
    onShow: function (e) {
        wx.showLoading({
            title: '登录系统',
            mask: true
        })
        //携带指定的参数登录
        // session.login({
        //     enterpriseId: enterpriseId
        // });

        var that = this;

        //等待登录成功后，执行
        session.invokeAfterLogin(function () {
            wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
            storageIMSessionsName = getApp().globalData.enterpriseId + "_" + getApp().globalData.userId + "_" + config.storageIMSessionsName;

            //连接IM服务器初始化账号
            var imAccount = getApp().globalData.IMAccount;
            im.IMInit(function(){
                wx.showLoading({
                    title: '获取聊天信息',
                    mask: true
                })
                nim_chat = nim.getInstance({
                    //debug: true,
                    appKey: config.IMAppkey,
                    account: getApp().globalData.IMAccount,
                    token: getApp().globalData.IMToken,
                    onconnect: onConnect,
                    onerror: im.onError,
                    onwillreconnect: im.onWillReconnect,
                    ondisconnect: onDisconnect,
                    // 群组
                    onsynccreateteam: that.onCreateTeam,
                    onteammembers: that.onTeamMembers,
                    // 会话
                    onsessions: that.onSessions,
                    onupdatesession: that.onUpdateSession,
                    // 消息
                    onroamingmsgs: that.onRoamingMsgs,
                    onofflinemsgs: that.onOfflineMsgs,
                    onmsg: that.onMsg
                });

                var nimConTimes = 0;
                var nimConInterval = setInterval(function () {
                    if (nim_chat != "") {
                        //获取聊天场景
                        var index = sessionId.indexOf("-");
                        scene = sessionId.substring(0, index);
                        if (scene == 'p2p') {
                            if (typeof (avatarUrls[getApp().globalData.IMAccount]) == 'undefined' || typeof (avatarUrls[getApp().globalData.IMAccount]) == '') {
                                avatarUrls[getApp().globalData.IMAccount] = getApp().globalData.avatarUrl;
                                wx.setStorageSync(storageAvatarUrlsName, avatarUrls);
                            }
                            if (typeof (objectNicks[getApp().globalData.IMAccount]) == 'undefined' || objectNicks[getApp().globalData.IMAccount] == '') {
                                objectNicks[getApp().globalData.IMAccount] = getApp().globalData.userName;
                                wx.setStorageSync(storageObjectNicksName, objectNicks);
                            }
                            if (typeof (avatarUrls[chatObjectId]) == 'undefined' || avatarUrls[chatObjectId] == '' || typeof (objectNicks[chatObjectId]) == 'undefined' || objectNicks[chatObjectId] == '') {
                                getIMUserAvatarUrlAndNick(nim_chat, chatObjectId);
                            }

                            var times = 0;
                            var interval = setInterval(function () {
                                if (typeof (avatarUrls[chatObjectId]) != 'undefined') {
                                    that.messageListUI();
                                    clearInterval(interval);
                                }
                                if (times == 50) {
                                    console.log('获取用户信息失败');
                                    clearInterval(interval);
                                }
                                times++;
                            }, 100);
                        } else {
                            var times = 0;
                            var interval = setInterval(function () {
                                //判断群是否存在
                                nim_chat.getTeam({
                                    teamId: chatObjectId,
                                    done: function (error, team) {
                                        if (error != null) {
                                            console.log("nim初始化失败");
                                        } else {
                                            //申请入群，并刷新群成员信息
                                            joinTeamChat(that);
                                            //监控截屏，截屏就发送群消息
                                            if (typeof (team.custom) != 'undefined' && team.custom != "") {
                                                var custom = team.custom;
                                                isNotifyScreen = JSON.parse(custom).isNotifyScreen;
                                            }
                                            if (isNotifyScreen) {
                                                wx.onUserCaptureScreen(function (res) {
                                                    console.log("触发截屏操作");
                                                    var msg = nim_chat.sendTipMsg({
                                                        scene: scene,
                                                        to: chatObjectId,
                                                        tip: "'" + objectNicks[getApp().globalData.IMAccount] + "'使用了截图操作",
                                                        done: function (error, msg) {
                                                            if (error == null) {
                                                                im.pushMsg(msg);
                                                                that.messageListUI();
                                                            } else {
                                                                console.log("截屏消息通知发送失败！");
                                                            }
                                                        }
                                                    });
                                                })
                                            }
                                            clearInterval(interval);
                                        }
                                    }
                                });
                                if (times == 50) {
                                    console.log("获取群组信息失败");
                                    clearInterval(interval);
                                }
                                times++;
                            }, 100);
                        }
                        clearInterval(nimConInterval);
                    }
                    if (nimConTimes == 20) {
                        clearInterval(nimConInterval);
                    }
                    nimConTimes++;
                }, 200);
            });
        });
    },
    onSessions: function (newSessions) {
        console.log("chat 收到会话列表");
        if (typeof (newSessions) == 'undefined' || newSessions.length == 0) {
            return;
        }
        var sessions = wx.getStorageSync(storageIMSessionsName);
        sessions = im.mergeSessions(sessions, newSessions);
        wx.setStorageSync(storageIMSessionsName, sessions);
    },
    onUpdateSession: function (session) {
        var sessions = wx.getStorageSync(storageIMSessionsName);
        console.log('chat 会话更新了', session);
        if (typeof (session) == 'undefined' || typeof (session.lastMsg) == 'undefined') {
            return;
        }
        //session.lastMsg.time = util.formatDate(session.lastMsg.time);
        var news = [];
        news.push(session);
        sessions = im.mergeSessions(sessions, news);
        wx.setStorageSync(storageIMSessionsName, sessions);
    },
    onRoamingMsgs: function (obj) {
        console.log('漫游消息', obj);
        im.pushMsg(obj.msgs);

        this.messageListUI();
    },
    onOfflineMsgs: function (obj) {
        console.log('离线消息', obj);
        im.pushMsg(obj.msgs);

        this.messageListUI();
    },
    onMsg: function (msg) {
        console.log('收到消息', msg.scene, msg.type, msg);
        im.pushMsg(msg);

        this.messageListUI();
    },
    inputblur(e) {   //键盘事件
        var page = this;
        page.setData({
            inputContent: e.detail.value
        })
    },
    /**
     * 点击「发送」按钮，通过信道推送消息到服务器
     **/
    sendMessage: function (e) {
        var page = this;
        var inputContent = page.data.inputContent;

        //发送到服务器
        sendCustomMessage(inputContent);

        page.setData({
            inputContent: ''
        });

        this.messageListUI();
    },
    messageListUI: function (e) {
        var page = this;
        //清空会话气泡未读记录
        var sessions = wx.getStorageSync(storageIMSessionsName);
        if (sessions == "") {
            sessions = [];
        }
        for (var m = 0; m < sessions.length; m++) {
            if (sessions[m].id == sessionId) {
                sessions[m].unread = 0;
                wx.setStorageSync(storageIMSessionsName, sessions);
            }
        }
        //获取聊天记录
        var messages = wx.getStorageSync(storageIMMessageName);
        var userMessage = '';
        if (messages == '') {
            messages = [];
        }
        if (messages[sessionId] != 'undefined' && messages[sessionId] != "") {
            userMessage = messages[sessionId];
            if (typeof (userMessage) == 'undefined' || userMessage == "") {
                userMessage = [];
            }
            for (var i = 0; i < userMessage.length; i++) {
                if (userMessage[i].type == "notification") {
                    userMessage[i].time = im.convertMessageTime(userMessage[i].time, new Date().getTime, true);
                    userMessage[i].notifyMessage = im.teamNotificationMsg(userMessage[i].attach, objectNicks);
                } else {
                    if (i == 0) {
                        userMessage[i].time = im.convertMessageTime(userMessage[i].time, new Date().getTime, true);
                    } else if (i == (userMessage.length - 1)) {
                        userMessage[i].time = im.convertMessageTime(userMessage[i].time);
                    } else {
                        userMessage[i].time = im.convertMessageTime(userMessage[i].time, userMessage[i + 1].time);
                    }
                }
            }
        }
        // page.getRect();      //计算输入框到滚动条顶部的距离，计算暂时不够准确，不使用
        page.setData({
            ownerName: getApp().globalData.IMAccount,
            messages: userMessage,
            avatarUrls: avatarUrls
        });

        page.setData({
            scrollTop: 999999
        });

        wx.hideLoading();
    },
    getRect: function () {
        wx.createSelectorQuery().select('.chat-container').boundingClientRect(function (rect) {
            scrollTop = rect.top;
            // scrollTop = rect.height;
        }).exec()
    },
    touchStart: function (e) {
        touchStartTime = e.timeStamp;
    },
    touchEnd: function (e) {
        touchEndTime = e.timeStamp;
    },
    viewTeamInfo: function (e) {
        if (touchEndTime - touchStartTime < 350) {
            var currentTime = e.timeStamp;
            var lastTapTime1 = lastTapTime;
            // 更新最后一次点击时间
            lastTapTime = currentTime;

            // 如果两次点击时间在300毫秒内，则认为是双击事件
            if (currentTime - lastTapTime1 < 300) {
                lastTapTime = 0;
                wx.showLoading({
                    title: '加载中',
                    mask: true
                });
                wx.navigateTo({
                    url: '/disk/chat/chatMemberInfo?sessionId=' + sessionId,
                });
            }
        }
    },
    viewPersonInfo: function (e) {
        var avatarUrl = e.currentTarget.dataset.avatarUrl;
        var account = e.currentTarget.dataset.account;
        var nick = objectNicks[account];
        wx.navigateTo({
            url: '/disk/chat/personal?avatarUrl=' + avatarUrl + "&account=" + account + "&nick=" + nick,
        });
    }
});

//发送消息到服务器
function sendCustomMessage(message) {
    var index = sessionId.indexOf("-");
    if (index == -1) {
        wx.showToast({
            title: '发送失败！',
        });
        return;
    }
    var scene = sessionId.substring(0, index);
    var to = sessionId.substring(index + 1);
    var msg = nim_chat.sendText({
        scene: scene,
        to: to,
        text: message,
        done: function () {
            console.log("消息发送成功");
        }
    });
    im.pushMsg(msg);
}

//获取用户头像
function getIMUserAvatarUrlAndNick(nim_chat, chatObjectId) {
    nim_chat.getUser({
        account: chatObjectId,
        done: function (error, user) {
            if (error != null) {
                return;
            }
            if (typeof (user.avatar) != 'undefined' && user.avatar != "") {
                avatarUrls[chatObjectId] = user.avatar;
            } else {
                avatarUrls[chatObjectId] = teamAvatarUrl;
            }

            if (typeof (user.nick) != 'undefined' && user.nick != "") {
                objectNicks[chatObjectId] = user.nick;
            } else {
                objectNicks[chatObjectId] = '';
            }

            wx.setStorageSync(storageAvatarUrlsName, avatarUrls);
            wx.setStorageSync(storageObjectNicksName, objectNicks);
        }
    });
}
//获取群组成员头像
function getIMTeamAvatarUrl() {
    nim_chat.getTeamMembers({
        teamId: chatObjectId,
        done: function (error, teamMembers) {
            if (error != null) {
                console.log("获取群成员息失败");
                return;
            }
            teamMembers = teamMembers.members;
            if (typeof (teamMembers) != 'undefined' && teamMembers != "") {
                for (var i = 0; i < teamMembers.length; i++) {
                    if (typeof (avatarUrls[teamMembers[i].account]) != 'undefined' && avatarUrls[teamMembers[i].account] != "" && typeof (objectNicks[teamMembers[i].account]) != 'undefined' && objectNicks[teamMembers[i].account] != "") {
                        continue;
                    }
                    getIMUserAvatarUrlAndNick(nim_chat, teamMembers[i].account);
                }
            }
        }
    });
}

//加入群组
function joinTeamChat(that){
    nim_chat.getTeamMembers({
        teamId: chatObjectId,
        done: function (error, teamMembers) {
            var isTeamMeber = false;
            teamMembers = teamMembers.members;
            if (typeof (teamMembers) == 'undefined' || teamMembers == "" || teamMembers.length==0){
                isTeamMeber = false;
            }else{
                for (var m = 0; m < teamMembers.length; m++) {
                    if (teamMembers[m].account == getApp().globalData.IMAccount){
                        isTeamMeber = true;
                    }
                }
            }
            if (isTeamMeber){
                getIMTeamAvatarUrl();
                var teamTimes = 0;
                var teamInterval = setInterval(function () {
                    if (teamTimes == 1) {
                        that.messageListUI();
                        clearInterval(teamInterval);
                    }
                    teamTimes++;
                }, 400);
            }else{
                applyTeam(that);
            }
        }
    });
}
//申请入群
function applyTeam(that){
    nim_chat.applyTeam({
        teamId: chatObjectId,
        ps: '请求加入',
        done: function (error, msg) {
            if (error == null) {
                getIMTeamAvatarUrl();
                var teamTimes = 0;
                var teamInterval = setInterval(function () {
                    if (teamTimes == 1) {
                        that.messageListUI();
                        clearInterval(teamInterval);
                    }
                    teamTimes++;
                }, 400);
            } else {
                wx.showModal({
                    title: '提示',
                    content: '申请入群失败',
                    cancel: false
                })
            }
        }
    });
}

function onTeams(teams) {
    // console.log('群列表', teams);
}
function onInvalidTeams(teams) {
}
function onCreateTeam(team) {
    console.log('你创建了一个群', team);
}
function onTeamMembers(obj) {
    console.log('收到群成员', obj);
}
function onConnect() {
    console.log("连接成功！");
    connectStatus = true;
}

function onDisconnect() {
    console.log("连接断开！");
    connectStatus = false;
}