// disk/cloud/addmember.js
var session = require("../../session.js");
var File = require("../module/file.js");
var utils = require("../module/utils.js");
var config = require("../config.js");
var app = getApp();
Page({

    /**
     * 页面的初始数据
     */
    data: {
        deptName: '企业通讯录',
        deptId: '0',
        list: [],
        isParent: '',
        checked: '',
        pId: '',
        items: {},
        pages: [],
        pages_id: 0,
        addmember: [],
        confim: false,
        scrollHeight: '',
        teamId:''
    },
    showDepAndUsers: function (e) {
        console.log(e);
        var self = this;
        self.setData({
            deptId: e.currentTarget.dataset.items.userId,//当前文件id
            isParent: e.currentTarget.dataset.items.isParent,
            deptName: e.currentTarget.dataset.items.name,
            pId: e.currentTarget.dataset.items.pId,//父级id
            items: e.currentTarget.dataset.items
        })
        this.data.pages.push(e.currentTarget.dataset.items.pId);
        if (self.data.isParent === true) {
            File.listDepAndUsers(app.globalData.token, self.data.deptId, function (data) {
                for (let i = 0; i < data.length; i++) {
                    data[i].checked = false;
                }
                self.setData({
                    list: data
                })
            })
        } else {
            console.log('人物');
        }

    },
    checkboxChange: function (e) {
        console.log(e);
        var itemId = e.currentTarget.dataset.index;
    },
    checkbox: function (e) {
        var itemId = e.currentTarget.dataset.index;
        var checkId = e.currentTarget.dataset.items.id;
        var check = !e.currentTarget.dataset.items.checked;
        var lists = this.data.list;
        lists[itemId]['checked'] = check;
        this.setData({
            list: lists
        })
        if (check === true) {
            this.data.addmember.map((item, index) => {
                if (checkId === item.id) {
                    this.data.addmember.splice(index, 1)
                }

            })
            this.data.addmember.push(e.currentTarget.dataset.items)

        } else {
            this.data.addmember.map((item, index) => {
                if (checkId === item.id) {
                    this.data.addmember.splice(index, 1)
                }

            })
        }
        if (this.data.addmember.length > 0) {
            this.setData(
                {
                    scrollHeight: (wx.getSystemInfoSync().windowHeight - 86) + "px",
                }
            )
        }
    },
    confim: function () {
        var self = this;
        var memberList = [];
        for (var i = 0; i < self.data.addmember.length; i++) {
            console.log(self.data.addmember[i]);
            memberList.push({
                id: self.data.addmember[i].id,
                type: self.data.addmember[i].type,
                name: self.data.addmember[i].name
            })
        };
        wx.showModal({
            cancelText: "不添加",
            confirmText: "添加",
            title: '提示',
            content: '是否添加所选部门成员？',
            success: function (res) {
                if (res.confirm) {
                    wx.navigateBack(
                        {
                            delta: 1
                        }
                    );
                }
                wx.setStorageSync('teamspacemember', memberList)
            }
        })
        console.log(memberList);
        // var teamId = 
    },
    confimcheck: function() {
        var addteamId = this.data.teamId;
        var self = this;
        var memberList = [];
        for (var i = 0; i < self.data.addmember.length; i++) {
            console.log(self.data.addmember[i]);
            memberList.push({
                id: self.data.addmember[i].id,
                type: self.data.addmember[i].type
            })
        };
        wx.showModal({
            cancelText: "不添加",
            confirmText: "添加",
            title: '提示',
            content: '是否添加所选部门成员？',
            success: function (res) {
                if (res.confirm) {
                    File.addmember(app.globalData.token, memberList, addteamId, function (data) {
                        wx.showToast({
                            title: '添加成功',
                        });
                        wx.navigateBack(
                            {
                                delta: 1
                            }
                        );
                    });
                }
                wx.setStorageSync('teamspacemember', memberList)
            }
        })
        console.log(memberList);
        console.log(this.data.teamId);
        
        
    },
    onCrumbClick: function (e) {
        var selfs = this;
        var crumb = this.data.pages.splice(-1);
        var crumbs = crumb.join("")
        console.log(crumb.join(""));
        File.listDepAndUsers(app.globalData.token, crumbs, function (data) {
            selfs.setData({
                list: data
            })
        })
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        console.log(options);
        if (options.ids != 'undefined') {
            this.setData({
                teamId: options.ids,
                confim: true
            })
        } else{
            this.setData({
                confim: false
            })
        }
        if (app.globalData.token == '' || app.globalData.cloudUserId == '') {
            session.login();
            return;
        }
        var deptId = '0';
        var self = this;
        File.listDepAndUsers(app.globalData.token, deptId, function (data) {
            console.log(data);
            for (let i = 0; i < data.length; i++) {
                data[i].checked = false;
            }
            self.setData({
                list: data,
            })
        })
        var checklist = wx.getStorageSync('checkmemberlist');
        console.log(checklist);
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        wx.removeStorageSync('teamspacemember');
        wx.removeStorageSync('checkmemberlist');
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function (options) {
        console.log(options);
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

    }

})