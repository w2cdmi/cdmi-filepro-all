// disk/cloud/index.js
var file = require("../module/file.js");
var menu = require("../template/menu.js");
var File = require("../module/file.js");
var utils = require("../module/utils.js");
var musicService = require("../module/music.js");
var operation = require("../template/operation.js");
var createFolder = require("../template/createFolder.js");
var music = require("../template/music.js");
var app = getApp();
//文件操作相关
var ownerId = 0;
var nodeId = 0;
//面包屑
var crumbs = [];
var newFolderName = "";
var session = require("../../session.js");

var grids = [];
var isShowGrids = false;

Page({
    /**
     * 页面的初始数据
     */
    data: {
        grids: [],
        cells: [],
        scrollTop: 40,
        crumbsShow: '',
        isShowGrids: isShowGrids
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        var page = this;
        //长按菜单
        page['showOperation'] = operation.showOperation;
        page['updateNodeName'] = operation.updateNodeName;
        page['deleteNode'] = operation.deleteNode;
        page['hideOperation'] = operation.hideOperation;
        page['moveTo'] = operation.moveTo;
        //文件夹
        page['inputChange'] = createFolder.inputChange
        page['showUpdateFolderPanel'] = createFolder.showUpdateFolderPanel
        page['onCreateFolderCancel'] = createFolder.onCreateFolderCancel
        page['onCreateFolderConfirm'] = createFolder.onCreateFolderConfirm
        
        //功能菜单
        page['switchMenuPanel'] = menu.switchMenuPanel;
        page['chooseUploadImage'] = menu.chooseUploadImage;
        page['chooseUploadVedio'] = menu.chooseUploadVedio;
        page['switchMusicPanel'] = menu.switchMusicPanel;
        page['showCreateFolderPanel'] = menu.showCreateFolderPanel;
        page['backupIntroduction'] = menu.backupIntroduction;
        page['hideMenuPanel'] = menu.hideMenuPanel;

        //音乐播放器
        page['playOrStopMusic'] = music.playOrStopMusic;
        page['lastMusicPlay'] = music.lastMusicPlay;
        page['nextMusicPlay'] = music.nextMusicPlay;
        page['playCurrentMusic'] = music.playCurrentMusic;
        page['deleteMusic'] = music.deleteMusic;
        page['clearMusicList'] = music.clearMusicList;
        page['openMusicList'] = music.openMusicList;
        page['closeMusicList'] = music.closeMusicList;

        //构造第一个面包屑节点
        crumbs = [];
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        wx.hideShareMenu();  //屏蔽手机右上角的转发功能
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        var page = this;
        session.login();
        session.invokeAfterLogin(function () {
            wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });
            if (getApp().globalData.accountType == 0 || getApp().globalData.accountType > 100) {
                var ownerId = getApp().globalData.cloudUserId
                var nodeId = 0
                //显示个人页面
                page.setData({
                    isShowGrids: false,
                    showModal: false,
                    scrollHeight: (wx.getSystemInfoSync().windowHeight - 41) + "px"
                })
                //刷新文件列表
                if (crumbs.length > 0){
                    //删除点击节点之后的数据
                    var crumb = crumbs[crumbs.length - 1];

                    page.lsOfFolderForClickCrum(app.globalData.token, crumb.ownerId, crumb.nodeId);
                }else{
                    crumbs.push({
                        index: 0,
                        name: "个人文件",
                        ownerId: getApp().globalData.cloudUserId,
                        nodeId: 0
                    });
                    page.setData({
                        crumbs: crumbs
                    });
                    page.lsOfFolderForClickCrum(app.globalData.token, getApp().globalData.cloudUserId, 0);
                }

            } else {
                grids = [{
                    "id": "personalFiles",
                    "icon": '../images/persion-file.png',
                    "text": "个人文件",
                    "description": "个人文件随取随用"
                },
                {
                    "id": "departmentFiles",
                    "icon": '../images/depfile.png',
                    "text": "部门文件",
                    "description": "公司部门文件"
                },
                {
                    "id": "teamSpaceFiles",
                    "icon": '../images/teamfile.png',
                    "text": "协作空间",
                    "description": "团队协作中用到的文件"
                },
                {
                    "id": "enterpriseLibrary",
                    "icon": '../images/library.png',
                    "text": "企业文库",
                    "description": "公司公共资源文件"
                }];

                var isShowGrids = true;
                page.setData({
                    grids: grids,
                    isShowGrids: isShowGrids,
                    crumbs: []
                });
            }

            //初始化音乐播放器
            music.musicPlayInit(page);
            menu.initMenu(page);
            menu.menuPanelHideAnimation(page);
        });
    },

    onclick: function (e) {
        switch (e.currentTarget.id) {
            case "personalFiles":
                wx.navigateTo({
                    url: "/disk/widget/filelist?ownerId=" + getApp().globalData.cloudUserId + '&nodeId=0&name=' + encodeURIComponent("个人文件"),
                });
                break;
            case "departmentFiles":
                wx.navigateTo({
                    url: "./teamspacelist?type=1",
                })
                break;
            case "teamSpaceFiles":
                wx.navigateTo({
                    url: "./teamspacelist?type=0",
                })
                break;
            default:
                this.navigateToFileList();
        }
    },
    onclickPersonFolder: function () {
        wx.navigateTo({
            url: "/disk/widget/filelist?ownerId=" + getApp().globalData.cloudUserId + '&nodeId=0&name=' + encodeURIComponent("个人文件"),
        });
    },
    navigateToFileList: function () {
        if (getApp().globalData.accountType == 0 || getApp().globalData.accountType > 100) {
            wx.showToast({
                title: '暂不开放',
            })
            return;
        }
        var page = this;
        var offset = 0;   //初始值0
        var limit = 100;   //加载数量
        file.listEnterpriseSpace(getApp().globalData.token, getApp().globalData.cloudUserId, offset, limit, function (data) {
            var team = data.memberships[0].teamspace;
            wx.navigateTo({
                url: '/disk/widget/filelist?ownerId=' + team.id + '&nodeId=0&name=' + encodeURIComponent(team.name),
            });
        });
    },

    refreshCurrentFolder: function () {
        var page = this;
        var parentFileInfo = crumbs[crumbs.length - 1];
        page.lsOfFolderForClickCrum(app.globalData.token, parentFileInfo.ownerId, parentFileInfo.nodeId);
    },

    lsOfFolderForClickCrum: function (token, ownerId, nodeId) {
        var page = this;
        File.lsOfFolder(token, ownerId, nodeId, function (data) {
            var folders = File.convertFolderList(data.folders);
            var files = File.convertFileList(data.files);

            //判断是不是空文件夹
            var isShowBlankPage = false;
            if (folders.length == 0 && files.length == 0) {
                isShowBlankPage = true;
            }

            page.setData({
                folders: folders,
                files: files,
                isShowBlankPage: isShowBlankPage
            });
        })
    },

    showPnal: function () {
        this.setData({
            showddodal: true,
            showPanl: true
        });
    },
    onShareAppMessage: function (e) { //打开手机右上角的转发事件
        if (e.from == "button") {
            var fileInfo = e.target.dataset.info;
            var nodeId = fileInfo.id;
            var ownerId = fileInfo.ownedBy;
            var enterpriseId = app.globalData.enterpriseId;

            var url, icon;
            if (fileInfo.type == 0 || fileInfo.type == -5) { //文件夹
                icon = "/disk/images/shares/share-card-floder.png";
                url = '/disk/index?type=folder&eId=' + enterpriseId + "&oId=" + fileInfo.ownedBy + "&nId=" + fileInfo.id + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
            } else if (fileInfo.type == 1) { //文件
                if (fileInfo.thumbnailUrlList.length == 0) {
                    icon = utils.getImgSrcOfShareCard(fileInfo.name);
                } else {
                    icon = fileInfo.thumbnailUrlList[1].thumbnailUrl;
                }
                url = '/disk/index?type=file&eId=' + enterpriseId + "&oId=" + fileInfo.ownedBy + "&nId=" + fileInfo.id + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
            }

            return {
                title: fileInfo.name,
                path: url,
                imageUrl: icon,
                success: function (res) {
                    // 转发成功
                },
                fail: function (res) {
                    // 转发失败
                }
            }
        }
    },
    onCrumbClick: function (e) { //除第一个面包屑外的面包屑的点击事件
        var page = this;
        var crumb = e.currentTarget.dataset.crumb;

        page.setData({
            isShowMusicListPanel: false
        });

        //删除点击节点之后的数据
        crumbs = crumbs.splice(0, crumb.index + 1);
        page.setData({
            crumbs: crumbs
        });

        page.lsOfFolderForClickCrum(app.globalData.token, crumb.ownerId, crumb.nodeId);
    },

    //点击文件夹
    onFolderItemClick: function (e) {
        var page = this;
        page.setData({
            isShowMusicListPanel: false
        });

        var folder = e.currentTarget.dataset.folderinfo;
        var folderNodeName = folder.name;
        var folderOwnerId = folder.ownedBy;
        var folderNodeId = folder.id;
        if (typeof (folder.isListAcl) == 'undefined' || folder.isListAcl) {
            //刷新文件列表
            lsOfFolder(app.globalData.token, folderOwnerId, folderNodeId, page, folderNodeName, folderOwnerId, folderNodeId);
        } else {
            wx.showToast({
                title: '没有访问权限'
            });
        }
    },

    //点击文件
    onFileItemClick: function (e) {
        var file = e.currentTarget.dataset.fileinfo;
        var page = this;
        //打开文件
        File.openFile(file, function (musicState) {
            music.refreshPage(musicState.state, page);
            if (musicState.state == musicService.PLAY_STATE) {
                music.listenPlayState(page);
                getApp().globalData.isShowMusicPanel = true;
                page.setData({
                    isShowMusicPanel: getApp().globalData.isShowMusicPanel
                });
            }
        });
    }
});
//查询指定目录下的文件列表(ls命令)
function lsOfFolder(token, ownerId, nodeId, page, folderNodeName, folderOwnerId, folderNodeId) {
    File.lsOfFolder(token, ownerId, nodeId, function (data) {
        var folders = File.convertFolderList(data.folders);
        var files = File.convertFileList(data.files);

        //增加面包屑节点, 刷新界面
        crumbs.push({
            index: crumbs.length,
            name: folderNodeName,
            ownerId: folderOwnerId,
            nodeId: folderNodeId
        });

        //判断是不是空文件夹
        var isShowBlankPage = false;
        if (folders.length == 0 && files.length == 0) {
            isShowBlankPage = true;
        }

        page.setData({
            crumbs: crumbs,
            folders: folders,
            files: files,
            isShowBlankPage: isShowBlankPage
        });
    })
}
