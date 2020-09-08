var session = require("../../session.js");
var File = require("../module/file.js");
var utils = require("../module/utils.js");
var config = require("../config.js");
var menu = require("../template/menu.js");

var app = getApp();
var sliderWidth = 96; // 需要设置slider的宽度，用于计算中间位置

var isShowDeleteModel = false;

Page({
    data: {
        files: [],
        folders: [],
        isClearOldDate: true,    //清除老数据
        showModalStatus: false,
        check: false,
        confim: false,
        deletearr: [],
        checklists: [],
        checknum: '',
        scrollLeft:0
    },
    onLoad: function (options) {
        //如果是分享链接
        var enterpriseId = options.eId;
        if (typeof (enterpriseId) != 'undefined' && enterpriseId != '') {
            // getApp().globalData.enterpriseId = enterpriseId;
            // getApp().globalData.enterpriseName = decodeURIComponent(options.eName);
            getApp().globalData.indexParam = 3;     //3:他人分享

            var shareType = options.type
            if (shareType == "folder" || shareType == "file") {
                var ownerId = options.oId;
                var nodeId = options.nId;
                var fromId = options.fId;
                var fromName = decodeURIComponent(options.fName || "");
                var eName = decodeURIComponent(options.eName || "");
                wx.navigateTo({
                    url: '/disk/shares/share' + shareType + '?type=folder&eId=' + enterpriseId + "&oId=" + ownerId + "&nId=" + nodeId + "&fId=" + fromId + "&fName=" + encodeURIComponent(fromName) + "&eName=" + encodeURIComponent(eName),
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

    },
    onShow: function () {
        var page = this;

        session.login();
        session.invokeAfterLogin(function () {
            var enterpriseName = getApp().globalData.enterpriseName;
            if (typeof (enterpriseName) != 'undefined' && enterpriseName != '') {
                wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
            }
            var data = {};
            var files = [];
            data.files = files;
            page.setData({
                data: data,
                isClearOldDate: true
            });
            switch (getApp().globalData.indexParam) {
                case 1:
                    getRecentFileList(page)
                    page.setData({
                        isScrollX: true
                    })
                    break;
                case 2:
                    getSharedByMeFileList(page)
                    break;
                case 3:
                    getSharedToMeFileList(page)
                    break;
            }
        });

        //初始化音乐播放器
        menu.initMenu(page);
        menu.menuPanelHideAnimation(page);

        isShowDeleteModel = false;
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        if (wx.hideShareMenu) {
            wx.hideShareMenu();
        } else {
            // 如果希望用户在最新版本的客户端上体验您的小程序，可以这样子提示
            wx.showModal({
                title: '提示',
                content: '当前微信版本过低，无法使用该功能，请升级到最新微信版本后重试。',
                showCancel: false
            })
        }
    },

    scrollToLeft: function (e) {
        var self = this;
        var scollId = e.currentTarget.dataset.id;
        var items = e.currentTarget.dataset.fileinfo;
        var nodeId = e.currentTarget.dataset.fileinfo.nodeId;
        var ownerId = e.currentTarget.dataset.fileinfo.ownerId;

        // if (isShowDeleteModel) {
        //     return;
        // } else {
        //     isShowDeleteModel = true;
        // }
        wx.showModal({
            cancelText: "不恢复",
            confirmText: "恢复",
            title: '提示',
            content: '是否将本文件从回收站中恢复？',
            success: function (res) {
                if (res.confirm) {
                    File.trash(app.globalData.token, items.ownerId, items.nodeId, function (data) {
                        wx.showToast({
                            title: '恢复成功',
                        })
                        getRecentFileList(self);
                    });

                    self.setData(
                        {
                            isShowDeleteModel: false,
                            showModalStatus: false
                        }
                    );
                }
                if (res.cancel) {
                    self.setData({
                        scrollLeft: 0,
                        isShowDeleteModel: false,
                    })
                }
            }
        })
    },

    deleteBrowseRecords: function (ownerId, nodeId, callback) {
        File.deleteBrowseRecord(ownerId, nodeId, callback);
    },
    /**
     * 页面相关事件处理函数--监听用户下拉动作
     */
    onPullDownRefresh: function () {
        // wx.startPullDownRefresh();
        // wx.stopPullDownRefresh();
    },
    saveToPersion: function (e) {
        var fileInfo = e.target.dataset.fileInfo;
        wx.navigateTo({
            url: 'save/saveToPersion?ownerId=' + fileInfo.ownerId + "&inodeId=" + fileInfo.nodeId,
        })
    },
    clickitem: function (e) {
        console.log(e.currentTarget.dataset.item);
        this.setData(
            {
                showModalStatus: true,
                dataItem: e.currentTarget.dataset.item
            }
        );
    },
    checkitem: function (e) {
        var checks = e.currentTarget.dataset.check;
        var self = this;
        var checkeds = this.data.checked;
        console.log(e.target.dataset);
        var item_nodeId = e.target.dataset.id;
        var arr = self.data.checklists;


        var obj = {
            checked: true,
            nodeId: checks.nodeId,
            ownerId: checks.ownerId,
        }
        var has = false;
        arr.map((item, index) => {
            if (item_nodeId === item.nodeId) {
                item.checked = !item.checked
                has = true;
                arr.splice(index, 1)
            }

        })
        if (!has) {
            arr.push({
                checked: false,
                nodeId: checks.nodeId,
                ownerId: checks.ownerId,
            })
        }
        var checknum = self.data.checklists.length;
        self.setData({
            checklists: arr,
            checknum: checknum
        })


        self.setData({
            deletearr: arr,
        })
        console.log("arrlist", self.data.checklists, arr);
        // var checknum = self.data.checklists.length;
        // console.log(arr);
        console.log(self.data.checknum);
        if (arr.length > 0) {
            self.setData(
                {
                    confim: true
                }
            )
        };
        if (arr.length = 0) {
            self.setData(
                {
                    confim: false
                }
            )
        }

    },
    confim: function () {
        var datalist = this.data.checklists;
        var self = this;
        var deletelist = {};
        for (var i = 0; i < datalist.length; i++) {
            deletelist = datalist[i]
            delete datalist[i].checked;
            console.log(deletelist);
        }

        console.log(deletelist);

        wx.showModal({
            cancelText: "不删除",
            confirmText: "删除",
            title: '提示',
            content: '是否删除？',
            success: function (res) {
                console.log(datalist);
                if (res.confirm) {
                    for (var i = 0; i < datalist.length; i++) {
                        deletelist = datalist[i]
                        delete datalist[i].checked;
                        console.log(deletelist);
                        File.trashclean(app.globalData.token, deletelist.ownerId, deletelist.nodeId, function (data) {
                            console.log(deletelist.ownerId);
                            console.log(deletelist.nodeId);
                            wx.showToast({
                                title: '删除成功'
                            })
                            getRecentFileList(self);
                        });
                    }
                } else if (res.cancel) {
                    isShowDeleteModel = false;
                }
                self.setData(
                    {
                        check: false,
                        checknum: '0'
                    }
                )
            }
        })
    },
    checkboxChange: function (e) {
    },
    checkall: function () {
        console.log(this.data.files);
        console.log(this.data.checklists);
    },
    deleteitem: function (e) {
        this.setData(
            {
                check: true
            }
        )
    },
    closecheck: function () {
        this.setData(
            {
                check: false,
                checknum: '0'
            }
        )
    },
    menurestore: function () {
        var self = this;
        wx.showModal({
            cancelText: "不恢复",
            confirmText: "恢复",
            title: '提示',
            content: '是否将本文件从回收站中恢复？',
            success: function (res) {
                if (res.confirm) {
                    File.trash(app.globalData.token, self.data.dataItem.ownerId, self.data.dataItem.nodeId, function (data) {
                        wx.showToast({
                            title: '恢复成功'
                        })
                        getRecentFileList(self);
                    });
                    self.setData(
                        {
                            showModalStatus: false
                        }
                    );
                } else if (res.cancel) {
                    isShowDeleteModel = false;
                }
            }
        })

    },
    menudelete: function () {
        var self = this;
        wx.showModal({
            cancelText: "不删除",
            confirmText: "删除",
            title: '提示',
            content: '是否删除？',
            success: function (res) {
                if (res.confirm) {
                    File.trashclean(app.globalData.token, self.data.dataItem.ownerId, self.data.dataItem.nodeId, function () {
                        wx.showToast({
                            title: '删除成功'
                        })
                        getRecentFileList(self);
                        
                    });
                    self.setData(
                        {
                            showModalStatus: false
                        }
                    );
                } else if (res.cancel) {
                    isShowDeleteModel = false;
                }
                self.setData(
                    {
                        check: false,
                        checknum: '0'
                    }
                )
            }
        })
    },
    menuclose() {
        this.setData(
            {
                showModalStatus: false
            }
        );
    },
    setModalStatus: function (e) {
        console.log("设置显示状态，1显示0不显示", e.currentTarget.dataset.status);
        var animation = wx.createAnimation({
            duration: 200,
            timingFunction: "linear",
            delay: 0
        })
        this.animation = animation
        animation.translateY(300).step()
        this.setData({
            animationData: animation.export()
        })
        if (e.currentTarget.dataset.status == 1) {
            console.log(1);
            this.setData(
                {
                    showModalStatus: true
                }
            );
        }
        setTimeout(function () {
            animation.translateY(0).step()
            this.setData({
                animationData: animation
            })
            if (e.currentTarget.dataset.status == 0) {
                console.log(0);
                this.setData(
                    {
                        showModalStatus: false
                    }
                );
            }
        }.bind(this), 200)
    }
});

//获取回收站的数据
function getRecentFileList(page) {
    initFileList(page);
    if (app.globalData.token == '' || app.globalData.cloudUserId == '') {
        session.login();
        return;
    }
    File.recycleFile(app.globalData.token, app.globalData.cloudUserId, function (data) {
        var files = translateRecentRecord(data);
        var data = {};
        data.files = files;
        console.log(data);
        page.setData({
            data: data,
            isClearOldDate: false
        });
    });
}

function initFileList(page) {
    var data = {};
    var files = [];
    data.files = files;
    page.setData({
        data: data,
        isClearOldDate: true,
        activeIndex: getApp().globalData.indexParam
    });
}

//回收站
function translateRecentRecord(data) {
    console.log(data);
    var files = data.folders.concat(data.files);
    var fileslist = [];
    console.log(files)
    var imgUrls = [];
    for (var i = 0; i <files.length; i++) {
        var row = files[i];
        var file = {};
        file.name = row.name;
        file.type = row.type;
        file.nodeId = row.id;
        file.ownerId = row.ownedBy;

        if (row.thumbnailUrlList != undefined && row.thumbnailUrlList.length > 0){
            file.icon = row.thumbnailUrlList[0].thumbnailUrl;
        }else{
            file.icon = utils.getImgSrc(row);
        }
        // if (row.thumbnailUrlList.length == 0) {
        //     file.icon = utils.getImgSrc(row);
        //     file.shareIcon = utils.getImgSrcOfShareCard(row.name);
        // } else {
        //     file.icon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[0].thumbnailUrl);
        //     file.shareIcon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[1].thumbnailUrl);

        //     var imgUrls = [];
        //     // File.getPreImageDownloadUrlNotRecord(file.ownerId, file.nodeId, function (data) {
        //     //     //小程序不允许URL中有端口，将端口进行替换
        //     //     var url = utils.replacePortInDownloadUrl(data.downloadUrl);
        //     //     imgUrls.push(url);
        //     //     getApp().globalData.imgUrls = imgUrls;
        //     // });
        // }
        file.fileSize = utils.formatFileSize(row.size);
        file.modifiedTime = utils.formatNewestTime(row.modifiedAt);
        file.size = row.size;
        // files.push(file);
        fileslist.push(file);
    }

    return fileslist;
}