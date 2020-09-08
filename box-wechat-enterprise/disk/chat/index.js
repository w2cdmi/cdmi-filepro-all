var im = require("../module/im.js");
var config = require("../config.js");
var util = require("../module/utils.js");
var nim = require("../module/NIM_Web_NIM_v3.8.0-beta.js");
var menu = require("../template/menu.js");
var music = require("../template/music.js");

var host = config.host;
var storageIMSessionsName = '';
var storageAvatarUrlsName = config.storageAvatarUrlsName;
var storageObjectNicksName = config.storageObjectNicksName;
var storageIMMessageName = config.storageIMMessageName;
var teamAvatarUrl = '../images/icon/message-active.png';
var token = getApp().globalData.token;
var nim_sessions = '';
var avatarUrls = {};    //聊天头像
var objectNicks = {};   //用户昵称
var connectStatus = false; //连接状态
var sessions = [];      //会话数组

var isShowMenu = false; //长按会话操作菜单
var longTapId = "";     //长按选项编号

Page({
    /**
     * 页面的初始数据
     */
    data: {
        sessions: [],   //当前会话集合
        avatarUrls: {}, //聊天头像集合
        objectNicks: {},   //用户昵称
        isShowMenu: false    //长按会话操作菜单
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        var enterpriseId = options.enterpriseId;
        if (typeof (enterpriseId) != 'undefined' && enterpriseId != '') {
            getApp().globalData.enterpriseId = enterpriseId;
            getApp().globalData.enterpriseName = decodeURIComponent(options.eName);

            var chatObjectId = options.chatObjectId;
            var objectNick = options.objectNick;
            var sessionId = options.sessionId;

            var shareType = options.type
            if (shareType == "p2pchat" || shareType == "teamchat") {
                wx.navigateTo({
                    url: '../shares/chat?type=' + shareType +'&enterpriseId=' + enterpriseId + '&sessionId=' + sessionId + '&chatObjectId=' + chatObjectId + '&objectNick=' + objectNick + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName)
                })
            }
        }

        var page = this;
        //功能菜单
        page['switchMenuPanel'] = menu.switchMenuPanel;
        page['chooseUploadImage'] = menu.chooseUploadImage;
        page['chooseUploadVedio'] = menu.chooseUploadVedio;
        page['switchMusicPanel'] = menu.switchMusicPanel;
        page['showCreateFolderPanel'] = menu.showCreateFolderPanel;
        page['backupIntroduction'] = menu.backupIntroduction;
        page['hideMenuPanel'] = menu.hideMenuPanel;
        page['jumpCreateChatPage'] = menu.jumpCreateChatPage;

        //音乐播放器
        page['playOrStopMusic'] = music.playOrStopMusic;
        page['lastMusicPlay'] = music.lastMusicPlay;
        page['nextMusicPlay'] = music.nextMusicPlay;
        page['playCurrentMusic'] = music.playCurrentMusic;
        page['deleteMusic'] = music.deleteMusic;
        page['clearMusicList'] = music.clearMusicList;
        page['openMusicList'] = music.openMusicList;
        page['closeMusicList'] = music.closeMusicList;
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
        wx.showLoading({
            title: '加载中',
            mask: true
        })
        wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
        
        //初始化音乐播放器
        var page = this;
        music.musicPlayInit(page);
        menu.initMenu(page);
        menu.menuPanelHideAnimation(page);
        getApp().globalData.isShowChatButton = true;

        avatarUrls = wx.getStorageSync(storageAvatarUrlsName);
        objectNicks = wx.getStorageSync(storageObjectNicksName);

        if (avatarUrls == "") {
            avatarUrls = {};
        }
        if (objectNicks == "") {
            objectNicks = {};
        }

        storageIMSessionsName = getApp().globalData.enterpriseId + "_" + getApp().globalData.userId + "_" + config.storageIMSessionsName;
        var that = this;
        that.setData({
            sessions: [],
            avatarUrls: {},
            objectNicks: {},
            isClearOldDate: true
        });

        //连接IM服务器初始化账号
        var imAccount = getApp().globalData.IMAccount;
        if(typeof(imAccount) != 'undefined' && imAccount != ""){
            that.initSessionList();
        }else{
            im.IMInit(function () {
                that.initSessionList();
            });
        }
        
    },
    initSessionList: function(){
        var that = this;
        nim_sessions = nim.getInstance({
            appKey: config.IMAppkey,
            account: getApp().globalData.IMAccount,
            token: getApp().globalData.IMToken,
            onconnect: onConnect,
            onerror: im.onError,
            onwillreconnect: im.onWillReconnect,
            ondisconnect: im.onDisconnect,
            // 会话
            onsessions: that.onSessions,
            onupdatesession: that.onUpdateSession,
            //群组
            onteams: onTeams,
            onsynccreateteam: onCreateTeam,
            onteammembers: that.onTeamMembers,
            onsyncteammembersdone: onSyncTeamMembersDone,
            onupdateteammember: onUpdateTeamMember,
            // 消息
            onroamingmsgs: that.onRoamingMsgs,
            onofflinemsgs: that.onOfflineMsgs,
            onmsg: that.onMsg
        });

        var times = 0;
        var waitConnectInterval = setInterval(function () {
            if (typeof (nim_sessions) != 'undefined' && nim_sessions != "") {
                sessionListUI(that);
                clearInterval(waitConnectInterval);
            }
            if (times == 40) {
                console.log("连接服务器失败");
                clearInterval(waitConnectInterval);
            }
            times++;
        }, 100);
    },
    /**
     * 生命周期函数--监听页面隐藏
     */
    onHide: function () {
        getApp().globalData.isShowChatButton = false;
    },

    /**
     * 生命周期函数--监听页面卸载
     */
    onUnload: function () {
        getApp().globalData.isShowChatButton = false;
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

    onSessions: function (newSessions) {
        console.log("收到会话列表" + newSessions);
        if (typeof (newSessions) == 'undefined' || newSessions.length == 0) {
            return;
        }
        sessions = wx.getStorageSync(storageIMSessionsName);
        sessions = im.mergeSessions(sessions, newSessions);
        wx.setStorageSync(storageIMSessionsName, sessions);

        var page = this;
        sessionListUI(page);
    },
    onUpdateSession: function (session) {
        sessions = wx.getStorageSync(storageIMSessionsName);
        console.log('会话更新了', session);
        if (typeof (session) == 'undefined' || typeof (session.lastMsg) == 'undefined') {
            return;
        }
        var news = [];
        news.push(session);
        sessions = im.mergeSessions(sessions, news);
        wx.setStorageSync(storageIMSessionsName, sessions);

        var page = this;
        sessionListUI(page);
    },
    onRoamingMsgs: function (obj) {
        console.log('漫游消息', obj);
        im.pushMsg(obj.msgs);
    },
    onOfflineMsgs: function (obj) {
        console.log('离线消息', obj);
        im.pushMsg(obj.msgs);
    },
    onMsg: function (msg) {
        console.log('收到消息', msg.scene, msg.type, msg);
        im.pushMsg(msg);
    },
    onTeamMembers:function(obj) {
        // console.log('收到群成员', obj);
        var page = this;
        var teamId = obj.teamId;
        var members = obj.members;
        if(members.length > 0) {
            for (var i = 0; i < members.length; i++) {
                if (typeof (avatarUrls[members[i].account]) == 'undefined') {
                    getIMUserAvatarUrlAndNick(members[i].account, page, true);
                }
            }
        }
    },
    onShareAppMessage: function (options) {
        return im.shareChatLink();
    },
    viewMessage: function(e){
        longTapId = e.currentTarget.dataset.sessionId;
        if (!isShowMenu){
            wx.showLoading({
                title: '加载中',
                mask: true
            })
            this.setData({
                longTapId: longTapId
            });

            var sessionId = e.currentTarget.dataset.sessionId;
            var chatObjectId = e.currentTarget.dataset.chatObjectId;
            var objectNick = e.currentTarget.dataset.objectNick;
            wx.navigateTo({
                url: "chat?sessionId=" + sessionId + "&chatObjectId=" + chatObjectId + "&objectNick=" + objectNick,
            });
        }
    },
    handleMessage: function(e){
        var sessionId = e.currentTarget.dataset.sessionId;
        longTapId = sessionId;
        isShowMenu = true;
        //获取屏幕点击位置
        var top = e.detail.y;
        var left = e.detail.x;
        //获取屏幕宽度
        var window_width = wx.getSystemInfoSync().windowWidth;
        var window_height = wx.getSystemInfoSync().windowHeight;
        
        //获取显示的操作菜单大小；样式设置
        var menu_width = 115;
        var menu_height = 127;

        if (left + menu_width > window_width){
            left = left - menu_width;
        }
        if (top + menu_height > window_height){
            top = top - menu_height;
        }

        var isTop = false;
        var sessionTops = wx.getStorageSync(config.sessionTopsKey);
        if (sessionTops != "" && typeof (sessionTops[sessionId]) != 'undefined' && sessionTops[sessionId] == 0){
            isTop = true;
        }
        this.setData({
            isShowMenu: isShowMenu,
            menu_top: top + "px",
            menu_left: left + "px",
            sessionId: sessionId,
            longTapId: longTapId,
            isTop: isTop
        });
    },
    deleteMessage: function(e){
        var page = this;
        var sessionId = e.currentTarget.dataset.sessionId;

        wx.showLoading({
            title: '正在删除...',
            mask: true
        })
        //删除聊天消息
        var tempMessages = {};
        var messages = wx.getStorageSync(storageIMMessageName);
        if (messages != "") {
            for (var key in messages) {
                if (key == sessionId) {
                    continue;
                }
                tempMessages[key] = messages[key];
            }
            wx.setStorageSync(storageIMMessageName, tempMessages);
        }
        //删除会话信息
        var tempSessions = [];
        if (typeof (sessions) != 'undefined' && sessions.length > 0) {
            for (var i = 0; i < sessions.length; i++) {
                if (sessions[i].id == sessionId) {
                    continue;
                }
                tempSessions.push(sessions[i]);
            }
            wx.setStorageSync(storageIMSessionsName, tempSessions);
        }
        this.hideMenu();

        sessionListUI(page);
    },
    setchatTop: function(e){
        var page = this;
        var sessionId = e.currentTarget.dataset.sessionId;
        var isTop = e.currentTarget.dataset.isTop;
        isTop = isTop?false:true;
        im.setChatTop(sessionId, isTop, function(){
            page.hideMenu();
            sessionListUI(page);
        });
    },
    hideMenu:function(e){
        isShowMenu = false;
        longTapId = "";
        this.setData({
            isShowMenu: isShowMenu,
            longTapId: longTapId
        });
    },
    viewTeamInfo: function(e){
        var sessionId = e.currentTarget.dataset.sessionId;
        wx.navigateTo({
            url: '/disk/chat/chatMemberInfo?sessionId='+sessionId,
        })
        this.hideMenu();
    }
})

function onConnect(){
    console.log("连接成功！");
    connectStatus = true;
}

function onDisconnect() {
    console.log("连接断开！");
    connectStatus = false;
}

//刷新会话界面
function sessionListUI(page) {
    sessions = wx.getStorageSync(storageIMSessionsName);
    if (sessions != '' && sessions.length > 0) {
        for (var i = 0; i < sessions.length; i++) {
            if (typeof (avatarUrls[sessions[i].to]) == 'undefined' || avatarUrls[sessions[i].to] == '' || typeof(objectNicks[sessions[i].to]) == 'undefined' || objectNicks[sessions[i].to] == '') {
                if(sessions[i].scene == "p2p"){
                    getIMUserAvatarUrlAndNick(sessions[i].to, page);
                }else{
                    getIMTeamAvatarUrlAndNick(sessions[i].to, page);
                }
            }
        }
    }
    page.setData({
        sessions: formatSessions(sessions),
        avatarUrls: avatarUrls,
        objectNicks: objectNicks,
        isClearOldDate: false,
    });

    wx.hideLoading();
}

//获取用户头像
//isTeamMember： 收到的是群成员通知消息时候，不刷新会话列表
function getIMUserAvatarUrlAndNick(IMUserName, page, isTeamMember){
    nim_sessions.getUser({
        account: IMUserName,
        done: function (error, user) {
            if (error != null){
                console.log("获取用户名片失败");
                return;
            }
            if (typeof(user.avatar) != 'undefined' && user.avatar != "") {
                avatarUrls[IMUserName] = user.avatar;
            } else {
                avatarUrls[IMUserName] = '';
            }
            if (typeof (user.nick) != 'undefined' && user.nick != ""){
                objectNicks[IMUserName] = user.nick;
            }else{
                objectNicks[IMUserName] = '';
            }
            wx.setStorageSync(storageAvatarUrlsName, avatarUrls);
            wx.setStorageSync(storageObjectNicksName, objectNicks);
            if (!isTeamMember) {
                RefreshsessionUIOnAvatarDone(page);
            }
        }
    });
}
//获取群组头像
function getIMTeamAvatarUrlAndNick(IMTeamId, page){
    nim_sessions.getTeam({
        teamId: IMTeamId,
        done: function (error, team) {
            if (error != null) {
                console.log("获取群组名片失败");
            }
            if (typeof (team.avatar) != 'undefined' && team.avatar != "") {
                avatarUrls[IMTeamId] = team.avatar;
            } else {
                avatarUrls[IMTeamId] = teamAvatarUrl;
            }
            if (typeof (team.name) != 'undefined' && team.name != "") {
                objectNicks[IMTeamId] = team.name;
            }else{
                objectNicks[IMTeamId] = '';
            }
            wx.setStorageSync(storageAvatarUrlsName, avatarUrls);
            wx.setStorageSync(storageObjectNicksName, objectNicks);
            RefreshsessionUIOnAvatarDone(page);
        }
    });
}
//刷新页面 
//1、为了减少刷新次数，本地缓存头像数量大于会话个数再次刷新
function RefreshsessionUIOnAvatarDone(page){
    //计算集合中头像链接的个数
    var urlSize = 0;
    for (var url in avatarUrls) {
        urlSize++;
    }
    //头像链接个数等于会话个数，刷新会话页面
    if (urlSize >= sessions.length) {
        page.setData({
            sessions: formatSessions(sessions),
            avatarUrls: avatarUrls,
            objectNicks: objectNicks,
            isClearOldDate: false
        });
    }
}

function formatSessions(IMSessions){
    if (IMSessions.length == 0){
        return [];
    }
    var sessionTops = wx.getStorageSync(config.sessionTopsKey);
    if (sessionTops == ""){
        sessionTops = {};
    }

    var topSessions = [];       //置顶会话
    var sessions = [];          //会话
    for (var i = 0; i < IMSessions.length;i++){
        IMSessions[i].lastMsg.time = util.formatNewestTime(IMSessions[i].lastMsg.time);
        if (IMSessions[i].lastMsg.type == "notification"){
            IMSessions[i].notifyMessage = im.teamNotificationMsg(IMSessions[i].lastMsg.attach, objectNicks);
        }

        if (sessionTops != {}){
            if (typeof (sessionTops[IMSessions[i].id]) != undefined && sessionTops[IMSessions[i].id] == 0){
                IMSessions[i].isTop = true;
                topSessions.push(IMSessions[i]);
            }else{
                IMSessions[i].isTop = false;
                sessions.push(IMSessions[i]);
            }
        }
    }
    IMSessions = topSessions.concat(sessions);
    return IMSessions;
}

function onTeams(teams) {
    // console.log('群列表', teams);
}
function onInvalidTeams(teams) {
}
function onCreateTeam(team) {
    console.log('你创建了一个群', team);
}

function onSyncTeamMembersDone() {
    console.log('同步群列表完成');
}
function onUpdateTeamMember(teamMember) {
    console.log('群成员信息更新了', teamMember);
}
function refreshTeamMembersUI() {
    // 刷新界面
}

