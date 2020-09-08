// disk/cloud/filelist.js
/**
 * 统一的文件列表，使用ownerId和nodeId来获取文件列表
 */
var File = require("../module/file.js");
var utils = require("../module/utils.js");
var musicService = require("../module/music.js");
var operation = require("../template/operation.js");
var menu = require("../template/menu.js");
var music = require("../template/music.js");
var createFolder = require("../template/createFolder.js");

//
var app = getApp();

//文件操作相关
var ownerId = 0;
var nodeId = 0;

//面包屑
var crumbs = [];
var newFolderName = "";
//点击进入的名称 "个人文件"、"团队空间名称"
var optionsName ="";    

Page({
    /**
     * 页面的初始数据
     */
    data: {
        cells: [],
        scrollTop: 40,
        crumbsShow: '',
    },

    /**
     * 生命周期函数--监听页面加载
     */

    onLoad: function (options) {
        ownerId = options.ownerId;
        nodeId = options.nodeId;

        //无效的信息
        // if (ownerId == undefined || nodeId == undefined) {
        //     return;
        // }
        optionsName = decodeURIComponent(options.name)

        //重置面包屑
        crumbs = [];
        var page = this;
        page.setData({
            scrollHeight: (wx.getSystemInfoSync().windowHeight - 41) + "px",
            isShowUplodProgress: false
        })

        //判断是否是首页上传文件
        var jumpType = options.jumpType;
        if (jumpType != undefined && jumpType != ""){
            if (jumpType == "uploadImage"){
                var tempCrumbs = getApp().globalData.crumbs;
                var tempFiles = getApp().globalData.tempFiles;
                //初始化数据
                getApp().globalData.crumbs = [];
                getApp().globalData.tempFiles = [];

                if (tempCrumbs != undefined && tempCrumbs.length > 0 && tempFiles != undefined && tempFiles.length > 0){
                    crumbs = tempCrumbs;
                    page.setData({
                        crumbs: crumbs
                    });
                    var parentFileInfo = crumbs[crumbs.length - 1];
                    var index = 0; //从第一个图片开始上传
                    menu.uploadImage(tempFiles, index, parentFileInfo, page);
                }else{
                    wx.showToast({
                        title: '上传失败！',
                        icon: 'none'
                    })
                }
            } else if (jumpType == "uploadVideo"){
                var tempCrumbs = getApp().globalData.crumbs;
                var tempFile = getApp().globalData.tempFile;
                //初始化数据
                getApp().globalData.crumbs = [];
                getApp().globalData.tempFile = {};

                if (tempCrumbs != undefined && tempCrumbs.length > 0 && tempFile != undefined && tempFile.length != "{}") {
                    crumbs = tempCrumbs;
                    page.setData({
                        crumbs: crumbs
                    });
                    var parentFileInfo = crumbs[crumbs.length - 1];
                    menu.uploadVideo(tempFile, parentFileInfo, page);
                } else {
                    wx.showToast({
                        title: '上传失败！',
                        icon: 'none'
                    })
                }
            }
        }

        //功能菜单
        page['switchMenuPanel'] = menu.switchMenuPanel;
        page['chooseUploadImage'] = menu.chooseUploadImage;
        page['chooseUploadVedio'] = menu.chooseUploadVedio;
        page['switchMusicPanel'] = menu.switchMusicPanel;
        page['showCreateFolderPanel'] = menu.showCreateFolderPanel;
        page['backupIntroduction'] = menu.backupIntroduction;
        page['hideMenuPanel'] = menu.hideMenuPanel;
        
        //长按菜单
        page['showOperation'] = operation.showOperation;
        page['updateNodeName'] = operation.updateNodeName;
        page['deleteNode'] = operation.deleteNode;
        page['hideOperation'] = operation.hideOperation;
        page['moveTo'] = operation.moveTo;

        //音乐播放器
        page['playOrStopMusic'] = music.playOrStopMusic;
        page['lastMusicPlay'] = music.lastMusicPlay;
        page['nextMusicPlay'] = music.nextMusicPlay;
        page['playCurrentMusic'] = music.playCurrentMusic;
        page['deleteMusic'] = music.deleteMusic;
        page['clearMusicList'] = music.clearMusicList;
        page['openMusicList'] = music.openMusicList;
        page['closeMusicList'] = music.closeMusicList;

        //文件夹
        page['inputChange'] = createFolder.inputChange
        page['showUpdateFolderPanel'] = createFolder.showUpdateFolderPanel
        page['onCreateFolderCancel'] = createFolder.onCreateFolderCancel
        page['onCreateFolderConfirm'] = createFolder.onCreateFolderConfirm
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        wx.setNavigationBarTitle({ title: getApp().globalData.systemName + getApp().globalData.enterpriseName });

        var page = this;
        //设置面包屑根节点名称

        if (crumbs.length == 0){
            //获取文件列表
            lsOfFolder(app.globalData.token, ownerId, nodeId, page, optionsName, ownerId, nodeId);
        }else{
            //删除点击节点之后的数据
            var crumb = crumbs[crumbs.length - 1];

            page.lsOfFolderForClickCrum(app.globalData.token, crumb.ownerId, crumb.nodeId);
        }

        
        //初始化音乐播放器
        var page = this;
        music.musicPlayInit(page);
        menu.initMenu(page);
        menu.menuPanelHideAnimation(page);
    },

    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        wx.hideShareMenu();  //屏蔽手机右上角的转发功能
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
        if (typeof (folder.isListAcl) == 'undefined' || folder.isListAcl){
            //刷新文件列表
            lsOfFolder(app.globalData.token, folderOwnerId, folderNodeId, page, folderNodeName, folderOwnerId, folderNodeId);
        }else{
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
        File.openFile(file, function(musicState){
            music.refreshPage(musicState.state, page);
            if (musicState.state == musicService.PLAY_STATE){
                music.listenPlayState(page);
                getApp().globalData.isShowMusicPanel = true;
                page.setData({
                    isShowMusicPanel: getApp().globalData.isShowMusicPanel
                });
            }
        });
    },
    refreshCurrentFolder: function(){
        var page = this;
        var parentFileInfo = crumbs[crumbs.length - 1];
        page.lsOfFolderForClickCrum(app.globalData.token, parentFileInfo.ownerId, parentFileInfo.nodeId);
    },
    lsOfFolderForClickCrum: function (token, ownerId, nodeId){
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
        if (folders.length == 0 && files.length == 0){
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