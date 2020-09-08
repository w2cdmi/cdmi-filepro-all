var config = require('../config');
var im = require("../module/im.js");
var nim = require("../module/NIM_Web_NIM_v3.8.0-beta.js");

// disk/chat/chatMemberInfo.js
var storageIMMessageName = config.storageIMMessageName;
var storageAvatarUrlsName = config.storageAvatarUrlsName;
var storageObjectNicksName = config.storageObjectNicksName;

var teamInfo;    //群组信息
var sessionId;  //场景类型（p2p、team） + 群组会话id
var teamId;  //群id
var scene = '';
var chatObjectId = '';
var avatarUrls = {};    //聊天头像集合
var objectNicks = {};   //用户昵称
var nim_chat = '';
var isNotifyScreen = false;

var isTeam = false;
var isOwner = false;
var isTop = false;      //是否置顶

Page({
    /**
     * 页面的初始数据
     */
    data: {
        avatar: {},   //头像集合
        nickname: {}, //昵称集合
        accounts: [],  //账号数组
        isTeam: isTeam,
        isOwner: isOwner,
        isNotifyScreen: false
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        wx.showLoading({
            title: '加载中',
            mask: true
        })
        sessionId = options.sessionId;

        avatarUrls = wx.getStorageSync(storageAvatarUrlsName);
        objectNicks = wx.getStorageSync(storageObjectNicksName);

        if (typeof (sessionId) != 'undefined') {
            var index = sessionId.indexOf("-");
            if (index != -1) {
                scene = sessionId.substring(0, index);
                chatObjectId = sessionId.substring(index+1);
                teamId = chatObjectId;
            }
            // wx.setNavigationBarTitle({ title: objectNicks[chatObjectId] == 'undefined' ? '' : objectNicks[chatObjectId] });
        }
        //设置是否聊天呢置顶
        var sessionTops = wx.getStorageSync(config.sessionTopsKey);
        if (sessionTops != "") {
            if (typeof (sessionTops[sessionId]) != undefined && sessionTops[sessionId] == 0) {
                isTop = true;
            }
        }
        this.setData({
            isTop: isTop
        });
    
        if (scene == 'p2p'){
            var accounts =[];
            var account ={};
            account.id = chatObjectId;
            account.avatar = avatarUrls[chatObjectId];
            account.nick = objectNicks[chatObjectId];
            accounts.push(account);
            this.setData({
                accounts: accounts,
                teamName: objectNicks[chatObjectId],
                isHideTeamInfo: true
            })
            wx.hideLoading();
            return;
        }

        if(scene == 'team'){
            isTeam = true;
            
            //监听消息
            nim_chat = nim.getInstance({
                //debug: true,
                appKey: config.IMAppkey,
                account: getApp().globalData.IMAccount,
                token: getApp().globalData.IMToken,
                onconnect: im.onConnect,
                onerror: im.onError,
                onwillreconnect: im.onWillReconnect,
                ondisconnect: im.onDisconnect,
            });
            var page = this;
            nim_chat.getTeam({
                teamId: chatObjectId,
                done: function (error, team){
                    isOwner = false;
                    teamInfo = team;
                    if (team.owner == getApp().globalData.IMAccount){
                        isOwner = true;
                    }
                    if(typeof(team.custom) != 'undefined' && team.custom != ""){
                        var custom = team.custom;
                        isNotifyScreen = JSON.parse(custom).isNotifyScreen;
                    }
                    page.setData({
                        teamName: error==null?team.name:"",
                        isHideTeamInfo: false,
                        isTeam: isTeam,
                        isOwner: isOwner,
                        isNotifyScreen: isNotifyScreen
                    })
                }
            });
            nim_chat.getTeamMembers({
                teamId: chatObjectId,
                done: function (error, teamMembers){
                    if(error != null){
                        return;
                    }
                    var accounts = [];
                    var account = {};
                    teamMembers = teamMembers.members;
                    for (var m = 0; m < teamMembers.length; m++) {
                        account = {};
                        account.id = teamMembers[m].account;
                        account.avatar = avatarUrls[teamMembers[m].account];
                        account.nick = objectNicks[teamMembers[m].account];
                        accounts.push(account);
                    }
                    page.setData({
                        accounts: accounts
                    })
                }
            });

            wx.hideLoading();
        }

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

    /**
     * 用户点击右上角分享
     */
    onShareAppMessage: function () {
        return im.shareChatLink(sessionId, teamId, teamInfo.name);
    },
    //清空聊天记录
    clearHistoryMessage: function () {
        wx.showModal({
            title: '提示',
            content: '确定删除聊天记录吗？',
            success: function (res) {
                if (res.confirm) {
                    wx.showLoading({
                        title: '正在清空...',
                        mask: true
                    })
                    var messages = wx.getStorageSync(storageIMMessageName);
                    var message = messages[sessionId];

                    if (typeof (message) != undefined && message != '' && message.length > 0) {
                        var newMessage = [];
                        messages[sessionId] = newMessage;
                        wx.setStorageSync(storageIMMessageName, messages);
                    }

                    wx.showToast({
                        title: '清空成功！',
                    })
                }
            }
        })
    },
    //主动退出群聊
    leaveTeam: function(){
        wx.showModal({
            title: '提示',
            content: '确认退出群聊吗？',
            success: function (res) {
                if (res.confirm) {
                    wx.showLoading({
                        title: '退出中',
                        mask: true
                    })
                    nim_chat.leaveTeam({
                        teamId: teamId,
                        done: leaveTeamDone
                    });
                }
            }
        })
    },
    //解散群聊
    deleteTeam: function(){
        wx.showModal({
            title: '提示',
            content: '确认解散群吗？',
            success: function (res) {
                if (res.confirm) {
                    wx.showLoading({
                        title: '解散群聊',
                        mask: true
                    })
                    nim_chat.dismissTeam({
                        teamId: teamId,
                        done: dismissTeamDone
                    });
                }
            }
        })
    },
    //删除群成员
    deleteManager: function(e){
        if(!isOwner){
            wx.showToast({
                title: '权限不够',
            })
            return
        }

        var id = e.currentTarget.dataset.id;
        if (id == getApp().globalData.IMAccount){
            wx.showToast({
                title: '不能删除自己',
            })
            return
        }
        
        var page = this;
        wx.showModal({
            title: '提示',
            content: '是否删除成员"' + objectNicks[id] + '"',
            success: function (res) {
                if (res.confirm) {
                    nim_chat.removeTeamMembers({
                        teamId: teamId,
                        accounts: [id],
                        done: page.removeTeamMembersDone
                    });
                }
            }
        })
    },
    removeTeamMembersDone: function(error, obj) {
        if (error != null) {
            wx.showToast({
                title: '删除成员失败',
            })
            wx.hideLoading();
            return;
        }
        wx.showToast({
            title: '删除成员成功',
        })
        var page = this;
        nim_chat.getTeamMembers({
            teamId: teamId,
            done: function (error, teamMembers) {
                if (error != null) {
                    return;
                }
                var accounts = [];
                var account = {};
                teamMembers = teamMembers.members;
                for (var m = 0; m < teamMembers.length; m++) {
                    account = {};
                    account.id = teamMembers[m].account;
                    account.avatar = avatarUrls[teamMembers[m].account];
                    account.nick = objectNicks[teamMembers[m].account];
                    accounts.push(account);
                }
                page.setData({
                    accounts: accounts
                })
            }
        });
    },
    notifyScreenChange: function(e){
        isNotifyScreen = e.detail.value;
        updateTeamIsNotifyScreen(isNotifyScreen);
    },
    chatTopChange: function(e){
        isTop = e.detail.value;
        im.setChatTop(sessionId,isTop);
    }
})

function leaveTeamDone(error, obj) {
    if(error != null){
        wx.showToast({
            title: '退出失败',
        })
        wx.hideLoading();
        return;
    }
    wx.showToast({
        title: '退出成功',
    })
    wx.hideLoading();
    wx.navigateBack({
        delta: 1
    });
}

function dismissTeamDone(error, obj) {
    if (error != null) {
        wx.showToast({
            title: '解散失败',
        })
        wx.hideLoading();
        return;
    }
    wx.showToast({
        title: '解散成功',
    })
    wx.hideLoading();
    wx.navigateBack({
        delta: 1
    });
}
function updateTeamIsNotifyScreen(isNotifyScreen){
    wx.showLoading({
        title: '更新中',
        mask: true
    })
    var custom = "{\"isNotifyScreen\": " + isNotifyScreen + "}";
    nim_chat.updateTeam({
        teamId: teamId,
        custom: custom,
        done: updateTeamDone
    });
}
function updateTeamDone(error, team) {
    if (error == null){
        wx.showToast({
            title: '更新成功',
        })
        return;
    }
    wx.showToast({
        title: '更新失败',
    })
}