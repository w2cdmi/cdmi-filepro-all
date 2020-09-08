// disk/inbox/inbox.js
var Inbox = require("../module/inbox.js");
var Menu = require("../template/menu.js");
var Util = require('../module/utils.js');
var File = require('../module/file.js');
var linkClient = require("../module/link.js");

var folderList = [];
var LIMIT = 10;

Page({

    /**
     * 页面的初始数据
     */
    data: {
        showPopup: false,   // 弹出层状态
        showInputModal: false,  // 输入框弹出层
        showErrorModal: false,  // 错误弹出层
        folderName: '',
        folderItem: '',
        showBlank: false,   // 显示空白页
        ownerId: '',
        offset: 0,  // 初始获取数据位置
        folderList: [],
        sendDisabled: false,
        viewHeight: 0,
    },

    gotoFileList: function (e) {
        var folderItem = e.currentTarget.dataset.folderItem;
        wx.navigateTo({
            url: '/disk/inbox/inboxFile/inboxFile?folderId=' + folderItem.id + '&creater=' + folderItem.menderName + '&folderName=' + folderItem.name + '&ownerId=' + this.data.ownerId + '&linkCode=' + this.data.linkCode,
        })
    },

    getMoreList: function () {
        var page = this;
        var ownerId = this.data.ownerId;
        getFolderList(page, ownerId);
    },

    // 唤起发送弹出层
    setModalStatus: function (e) {
        var page = this;
        var folderItem = e.currentTarget.dataset.folderItem;
        var linkCode = '';
        Inbox.getInboxLink(this.data.ownerId, folderItem.id, (link) => {
            if (link.links.length < 1) {  // 无link
                Inbox.setInboxLink(this.data.ownerId, folderItem.id, (linkInfo) => {
                    linkCode = linkInfo.id;
                    page.setData({
                        linkCode: linkCode
                    });
                });
            } else {
                linkCode = link.links[0].id;
                page.setData({
                    linkCode: linkCode
                });
            }
        });
        if (folderItem != undefined) {
            page.setData({
                folderItem: folderItem,
            });
        }


        var animation = wx.createAnimation({
            duration: 200,
            timingFunction: "linear",
            delay: 0
        });
        this.animation = animation
        animation.translateY(300).step()
        this.setData({
            animationData: animation.export()
        });
        this.setData({
            showModalStatus: true
        });
        setTimeout(function () {
            animation.translateY(0).step()
            this.setData({
                animationData: animation
            });
        }.bind(this), 200);
    },

    cancelModalStatus: function () {
        this.setData({
            showModalStatus: false
        });
    },

    // 删除收件箱
    deleteFolderItem: function () {
        var page = this;
        var folderItem = this.data.folderItem;
        var folderId = folderItem.id;
        var ownerId = page.data.ownerId;

        this.setData({
            showModalStatus: false
        });
        wx.showModal({
            content: '确定删除该收件箱吗',
            success: (res) => {
                if (res.confirm) {
                    Inbox.deleteFolderName(ownerId, folderId, function (deleteRes) {
                        var data = deleteRes;
                        page.setData({
                            offset: 0
                        })
                        getFolderList(page, ownerId);
                    });
                }
            }
        })
    },
    onCreateFolderCancel: function () {
        this.setData({
            showPopup: false,
            showInputModal: false,
            showErrorModal: false,
            folderName: ''
        })
    },

    inputChange: function (e) {
        this.setData({
            folderName: e.detail.value
        })
    },

    // 新建收件箱
    onCreateFolderConfirm: function () {
        var page = this;
        var folderName = page.data.folderName;
        var ownerId = page.data.ownerId;
        if (folderName === '') {
            wx.showToast({
                title: '请输入收件箱名称',
                icon: 'none'
            });
            return;
        }
        this.setData({
            showInputModal: false,
            folderName: ''
        });
        if ((/[^\a-\z\A-\Z0-9\u4E00-\u9FA5]/g).test(folderName)) {
            // 创建文件夹失败，显示失败的提示
            this.setData({
                showErrorModal: true,
            });
            return;
        }

        var data = {
            name: folderName,
            parent: page.data.folderId
        }
        Inbox.addFolderName(ownerId, data, function (res) {
            var data = res;
            page.setData({
                offset: 0,
                showBlank: false,
            });
            folderList = [];
            getFolderList(page, ownerId);
        });
        // 创建成功则关闭
        this.setData({
            showPopup: false
        });
    },

    addFolder: function () {
        this.setData({
            showPopup: true,
            showInputModal: true,
        });
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        console.log("getApp().globalData.userId: ", getApp().globalData.userId)
        wx.getSystemInfo({
            success: (res) => {
                if (res.brand === 'HUAWEI') {
                    this.setData({
                        viewHeight: res.windowHeight * 2 - 100
                    });
                } else {
                    this.setData({
                        viewHeight: res.windowHeight * 2 -100
                    });
                }

            },
        })
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
        var ownerId = getApp().globalData.cloudUserId;
        this.setData({
            ownerId: ownerId,
            offset: 0,
        });
        folderList = [];
        var data = {};
        var page = this;
        getFolderList(page, ownerId);
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
    onShareAppMessage: function (res) {
        var folderItem = this.data.folderItem;
        this.setData({
            showModalStatus: false,
        });
        return {
            title: folderItem.menderName + '的收件箱：' + folderItem.name,
            path: '/disk/index?folderId=' + folderItem.id + '&creater=' + folderItem.menderName + '&folderName=' + folderItem.name + '&ownerId=' + this.data.ownerId + '&linkCode=' + this.data.linkCode,
            imageUrl: '/disk/images/shares/share-card-folder.png',
            success: function (res) {
                console.log("转发成功");
            },
            fail: function (res) {
                console.log("转发失败");
            }, complete: function () {
                console.log("转发结束");
            }
        }
    }
})

function getFolderList(page, ownerId) {
    Inbox.getInboxFolder(ownerId, function (res) {
        var folderId = res.id
        if (page.data.offset === 0) {
            folderList = [];
        }
        var param = { ownerId, folderId, offset: page.data.offset, LIMIT};
        Inbox.getFolderList(param, function (res) {
            var folders = res.folders;

            for (var i = 0; i < folders.length; i++) {
                folders[i].date = Util.getFormatDate(folders[i].createdAt);
                folderList.push(folders[i]);
            }
            page.setData({
                folderList: folderList,
                folderId: folderId,
                offset: page.data.offset + LIMIT
            })
            if (folderList.length === 0) {
                page.setData({
                    showBlank: true
                })
            }
        });
    });
}