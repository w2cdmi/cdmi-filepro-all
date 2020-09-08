// disk/cloud/newteamspace.js
var session = require("../../session.js");
var File = require("../module/file.js");
var utils = require("../module/utils.js");
var config = require("../config.js");
var app = getApp();

var teamId = 0;
Page({

    /**
     * 页面的初始数据
     */
    data: {
        name: '新部门',
        change: false,
        showname: true,
        teamspacelist: [],
        scrollHeight: (wx.getSystemInfoSync().windowHeight - 133) + "px",
        ifteam: false,
        ids: ''
    },
    bindblur: function (e) {
        this.setData({
            name: e.detail.value,
            showname: false,
            change: true
        })
    },
    changename: function () {
        this.setData({
            showname: true,
            change: false
        })
    },
    showinput: function () {
        this.setData({
            showname: true,
            change: false
        })
    },
    switchChange: function (e) {
        console.log(e.detail);
        var check = e.detail.value
        if (check === true) {
            console.log(1);
        } else {
            console.log(2);
        }
    },
    addmember: function () {
        wx.navigateTo({
            url: '/disk/cloud/addmember?ids=' + teamId,
        })
    },
    newteamspace: function () {
        console.log(this.data.name);
        var self = this;
        console.log(self.data.teamspacelist);
        if (self.data.teamspacelist == undefined || self.data.teamspacelist.length == 0) {
            wx.showModal({
                cancelText: "不创建",
                confirmText: "创建",
                title: '提示',
                content: '您当前没有添加成员 确定创建？',
                success: function (res) {
                    if (res.confirm) {
                        File.teamspaces(app.globalData.token, self.data.name, function (data) {
                            wx.showToast({
                                title: '添加成功',
                            });
                            var ownedBy = data.ownedBy;
                            console.log(self.data.teamspacelist);

                        });
                        wx.navigateTo({
                            url: '/disk/cloud/teamspacelist',
                        })
                    }
                }
            })
        } else {
            wx.showModal({
                cancelText: "不添加",
                confirmText: "添加",
                title: '提示',
                content: '是否添加？',
                success: function (res) {
                    if (res.confirm) {
                        File.teamspaces(app.globalData.token, self.data.name, function (data) {
                            console.log(data);
                            var ownedBy = data.id;
                            var teamlist = self.data.teamspacelist;
                            for (var i = 0; i < teamlist.length; i++) {
                                console.log(teamlist[i]);
                                delete teamlist[i].name;
                            }

                            File.addmember(app.globalData.token, teamlist, ownedBy, function (data) {
                                wx.showToast({
                                    title: '添加成功',
                                });
                                wx.navigateTo({
                                    url: '/disk/cloud/teamspacelist',
                                })

                            });
                            console.log(this.data.teamspacelist);

                        });
                    }
                }
            })
        }

    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        wx.removeStorageSync('teamspacemember');
        teamId = options.ids;
        if (teamId === undefined) {
            console.log(3333);
        } else {
            this.setData({
                ifteam: true
            })
            
            this.setData({
                scrollHeight: (wx.getSystemInfoSync().windowHeight - 120) + "px",
            });
            console.log(this.data.ids);
            return;

        }
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        wx.removeStorageSync('teamspacemember');
        wx.removeStorageSync('memberships');
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        var selfs = this;
        if(teamId != undefined){
            getTeamMember(teamId, selfs);
        } else {
            var memberlist = wx.getStorageSync('teamspacemember');
            selfs.setData({
                teamspacelist: memberlist
            })

        }

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
    deleteMember: function(e){
        var userId = e.currentTarget.dataset.userId;
        var selfs = this;
        File.deleteMember(userId, teamId, function(){       
            getTeamMember(teamId, selfs);
        });
    }
})

function getTeamMember(teamId, selfs){
    File.memberteamlist(app.globalData.token, teamId, function (data) {
        selfs.setData({
            teamspacelist: data.memberships
        })
    })
}