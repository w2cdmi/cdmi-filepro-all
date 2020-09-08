// 引入IM配置
var config = require('../config');
var nim = require("../module/NIM_Web_NIM_v3.8.0-beta.js");
var im = require("../module/im.js");

var nim_chat = '';
var sessionId = '';
var chatObjectId = '';
var objectNick = '';

Page({

    /**
     * 页面的初始数据
     */
    data: {
        isShowShare: false,
        isShowForm: true
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
        nim_chat = nim.getInstance({
            //debug: true,
            appKey: config.IMAppkey,
            account: getApp().globalData.IMAccount,
            token: getApp().globalData.IMToken,
            onconnect: this.onConnect,
            onerror: im.onError,
            onwillreconnect: im.onWillReconnect,
            ondisconnect: im.onDisconnect,
            // 群组
            onteams: this.onTeams,
            onsynccreateteam: this.onCreateTeam,
            onteammembers: this.onTeamMembers,
            onsyncteammembersdone: this.onSyncTeamMembersDone,
            onupdateteammember: this.onUpdateTeamMember,
            onmsg: this.onMsg
        });
    },
    onMsg: function (msg) {
        console.log('收到消息', msg.scene, msg.type, msg);
        im.pushMsg(msg);
    },
    onConnect: function () {
        console.log("链接成功！");
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
    onShareAppMessage: function (options) {
        return im.shareChatLink(sessionId, chatObjectId, objectNick);
    },

    formSubmit: function (e) {
        if (e.detail.value.teamName == "") {
            wx.showModal({
                title: '提示',
                content: '群名称不能为空',
                showCancel: false
            })
        }
        nim_chat.createTeam({
            type: 'advanced',
            name: e.detail.value.teamName,
            avatar: '',
            accounts: [getApp().globalData.IMAccount],
            intro: '群简介为空',
            announcement: '群公告为空',
            joinMode: 'noVerify',
            beInviteMode: 'noVerify',
            inviteMode: 'all',
            updateTeamMode: 'all',
            updateCustomMode: 'all',
            ps: '我建了一个高级群',
            // custom: '群扩展字段, 建议封装成JSON格式字符串',
            done: this.createTeamDone
        });
    },
    createTeamDone: function (error, obj) {
        if (error != null) {
            wx.showModal({
                title: '提示',
                content: '创建失败！！',
                showCancel: false
            })
            return;
        }

        sessionId = "team-" + obj.team.teamId;
        chatObjectId = obj.team.teamId;
        objectNick = obj.team.name;

        var msg = nim_chat.sendText({
            scene: 'team',
            to: obj.team.teamId,
            text: 'hello team',
            done: function () {
                console.log("发送完成！");
            }
        });
        im.pushMsg(msg);

        this.setData({
            isShowShare: true,
            isShowForm: false
        });
    }
})

function onTeams(teams) {
    console.log('群列表', teams);
}
function onInvalidTeams(teams) {
    console.log('无效群列表完成');
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