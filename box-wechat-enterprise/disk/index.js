var session = require("../session.js");
var File = require("module/file.js");
var musicService = require("module/music.js");
var utils = require("module/utils.js");
var config = require("/config.js");
var menu = require("template/menu.js");
var music = require("template/music.js");


var app = getApp();
var sliderWidth = 96; // 需要设置slider的宽度，用于计算中间位置

var isShowDeleteModel = false;

Page({
  data: {
    tabs: [{
      "index": 1,
      "imgPath": "./images/icon/tab-files-history.png",
      "name": "最近浏览"
    },
    {
      "index": 2,
      "imgPath": "./images/icon/tab-files-share-byme.png",
      "name": "我的分享"
    },
    {
      "index": 3,
      "imgPath": "./images/icon/tab-files-share-tome.png",
      "name": "他人分享"
    }],
    files: [],
    folders: [],
    isClearOldDate: true,    //清除老数据
    show_check_sharemenu: false,
    sharemenu: false
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
    // const FileList = new shareFileMenu.FileList(this.data.sharemenu);

    var page = this;

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

    // this.FileList_show = FileList.showsharelist
    // // this.checked_item = FileList.checked_item("xxx")
    // this.checked_item.apply(FileList.checked_item, "xxxss")

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
    music.musicPlayInit(page);
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
    var page = this;

    var scollId = e.currentTarget.dataset.id;
    var nodeId = e.currentTarget.dataset.fileinfo.nodeId;
    var ownerId = e.currentTarget.dataset.fileinfo.ownerId;

    if (isShowDeleteModel) {
      return;
    } else {
      isShowDeleteModel = true;
    }
    wx.showModal({
      cancelText: "不删除",
      confirmText: "删除",
      title: '提示',
      content: '是否将本文件从最近浏览中删除？',
      success: function (res) {
        if (res.confirm) {
          page.deleteBrowseRecords(ownerId, nodeId);
          page.onShow();
        } else if (res.cancel) {
          isShowDeleteModel = false;
          page.setData({
            scrollLeft: 0
          })
        }
      }
    })
  },

  deleteBrowseRecords: function (ownerId, nodeId, callback) {
    File.deleteBrowseRecord(ownerId, nodeId, callback);
  },
  //切换Tab选项卡
  tabClick: function (e) {
    var page = this;
    //控制左滑删除是否出现
    var tabId = e.currentTarget.dataset.index;
    if (tabId == 1) {
      page.setData({
        isScrollX: true
      })
    } else {
      page.setData({
        isScrollX: false
      })
    }

    //先初始化页面
    page.setData({
      files: [],
      isClearOldDate: true
    });

    var index = e.currentTarget.dataset.index;
    getApp().globalData.indexParam = index;
    //切换会刷新数据
    if (index == 1) { //获得最新浏览记录
      getRecentFileList(page)
    } else if (index == 2) {//获得我的分享记录
      getSharedByMeFileList(page)
    } else if (index == 3) {//获得他人分享给我的记录
      getSharedToMeFileList(page)
    }
  },

  fileItemClick: function (e) {
    var page = this;
    var dataset = e.currentTarget.dataset;
    var ownerId = dataset.fileinfo.ownerId;
    var nodeId = dataset.fileinfo.nodeId;
    var fileType = dataset.fileinfo.type;
    //文件
    if (fileType == 1 || fileType == 3) {
      var file = {
        id: nodeId,
        ownedBy: ownerId,
        size: dataset.fileinfo.size,
        name: dataset.fileinfo.name,
      };

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
    } else {
      wx.navigateTo({
        url: '/disk/widget/filelist?ownerId=' + ownerId + '&nodeId=' + nodeId + "&name=" + encodeURIComponent(dataset.fileinfo.name)
      });
    }
  },

  //打开手机右上角的转发事件
  onShareAppMessage: function (e) {
    var fileInfo = e.target.dataset.fileinfo;
    var enterpriseId = app.globalData.enterpriseId;


    var icon, url;
    if (fileInfo.type == 0 || fileInfo.type == -5) { //文件夹
      icon = "images/shares/share-card-floder.png";
      url = '/disk/index?type=folder&eId=' + enterpriseId + "&oId=" + fileInfo.ownerId + "&nId=" + fileInfo.nodeId + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
      // url = '/disk/shares/sharefolder?type=link&eId=' + enterpriseId + "&oId=" + fileInfo.ownerId + "&nId=" + fileInfo.nodeId + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
    } else if (fileInfo.type == 1) { //文件
      icon = fileInfo.shareIcon;
      url = '/disk/index?type=file&eId=' + enterpriseId + "&oId=" + fileInfo.ownerId + "&nId=" + fileInfo.nodeId + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
      // url = '/disk/shares/sharefile?type=link&eId=' + enterpriseId + "&oId=" + fileInfo.ownerId + "&nId=" + fileInfo.nodeId + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName);
    } else {
      console.error("无效的文件类型：" + fileInfo.type);
    }

    if (e.from == "button") {
      return {
        title: fileInfo.name,
        path: url,
        imageUrl: icon,
        success: function (res) {
          console.log("转发成功")
          // 转发成功
        },
        fail: function (res) {
          console.log("转发失败")
          // 转发失败
        }, complete: function () {
          console.log("转发结束")
        }
      }
    }
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
  list_long(e) {
    console.log("e", e)
  },
  FileList_show(e) {
    // var lists = this.data.data;
    // lists.sharecontent = "";
    // this.setData({
    //   show_check_sharemenu: true,
    //   data: lists
    // })
  },
  checked_item(e) {
    var index = (e.currentTarget.dataset.index);
    var lists = this.data.data;
    var cur = lists.files[index];
    lists.files[index].checked = !Boolean(lists.files[index].checked);
    this.setData({
      data: lists
    })
  },
  sharebindTextAreaInput(e) {
    var lists = this.data.data;
    lists.sharecontent = e.detail.value;
    this.setData({
      data: lists
    })
  },
  sharelists() {
    var lists = this.data.data;
    this.setData({
      data: lists,
      sharemenu: true
    })
  },
  shareviewclose() {
    this.setData({
      sharemenu: false
    })
  },
  share_go() {
    //发送批量分享
    console.log(this.data.data.sharecontent)
    var lists = this.data.data;
    lists.sharecontent = ""
    lists.files.map((item) => {
      item.checked = false;
    })
    this.setData({
      show_check_sharemenu: false,
      data: lists
    })
    this.shareviewclose();
  }
});

//获取最近浏览的数据
function getRecentFileList(page) {
  initFileList(page);
  if (app.globalData.token == '' || app.globalData.cloudUserId == '') {
    session.login();
    return;
  }
  File.listLastReadFile(app.globalData.token, app.globalData.cloudUserId, function (data) {
    var files = translateRecentRecord(data);
    var data = {};
    data.files = files;
    console.log(files)
    page.setData({
      data: data,
      isClearOldDate: false
    });
  });
}
//获取我的分享的数据
function getSharedByMeFileList(page) {
  initFileList(page);
  File.listMySharetTo(app.globalData.token, function (data) {
    var files = translateShareRecord(data);
    var data = {};
    data.files = files;
    page.setData({
      data: data,
      isClearOldDate: false
    });
  });
}

//获取他人分享的数据
function getSharedToMeFileList(page) {
  initFileList(page);
  File.listShareToMe(app.globalData.token, function (data) {
    var files = translateShareRecord(data);
    var data = {};
    data.files = files;
    data.isShowSaveMenu = true;
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

//将最近浏览记录转换为内部数据
function translateRecentRecord(data) {
  var files = [];
  var imgUrls = [];
  for (var i = 0; i < data.files.length; i++) {
    var row = data.files[i];
    var file = {};
    file.name = row.name;
    file.type = row.type;
    file.nodeId = row.id;
    file.ownerId = row.ownedBy;
    if (row.thumbnailUrlList.length == 0) {
      file.icon = utils.getImgSrc(row);
      file.shareIcon = utils.getImgSrcOfShareCard(row.name);
    } else {
      file.icon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[0].thumbnailUrl);
      file.shareIcon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[1].thumbnailUrl);

      var imgUrls = [];
      File.getPreImageDownloadUrlNotRecord(file.ownerId, file.nodeId, function (data) {
        //小程序不允许URL中有端口，将端口进行替换
        var url = utils.replacePortInDownloadUrl(data.downloadUrl);
        imgUrls.push(url);
        getApp().globalData.imgUrls = imgUrls;
      });
    }
    file.fileSize = utils.formatFileSize(row.size);
    file.modifiedTime = utils.formatNewestTime(row.modifiedAt);
    file.size = row.size;
    files.push(file);
  }

  return files;
}

//将最近分享记录（我分享的、分享给我的，都是同一格式）转换为内部数据
function translateShareRecord(data) {
  var imgUrls = [];
  data.contents.sort((a, b) => {
    //倒序排列
    return b.modifiedAt - a.modifiedAt;
  });
  var files = [];
  for (var i = 0; i < data.contents.length; i++) {
    var row = data.contents[i];
    var file = {};
    file.name = row.name;
    if (typeof (row.originalType) != 'undefined') {
      file.type = row.originalType;
    } else {
      file.type = row.type;
    }
    if (typeof (row.originalNodeId) != 'undefined') {
      file.nodeId = row.originalNodeId;
    } else {
      file.nodeId = row.nodeId;
    }
    if (typeof (row.originalOwnerId) != 'undefined') {
      file.ownerId = row.originalOwnerId;
    } else {
      file.ownerId = row.ownerId;//兼容转发记录, 优先使用原始值
    }
    if (typeof (row.thumbnailUrlList) != 'undefined' && row.thumbnailUrlList.length != 0) {
      file.icon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[0].thumbnailUrl);
      file.shareIcon = utils.replacePortInDownloadUrl(row.thumbnailUrlList[1].thumbnailUrl);

      File.getPreImageDownloadUrlNotRecord(file.ownerId, file.nodeId, function (data) {
        //小程序不允许URL中有端口，将端口进行替换
        var url = utils.replacePortInDownloadUrl(data.downloadUrl);
        imgUrls.push(url);
        getApp().globalData.imgUrls = imgUrls;
      });
    } else {
      file.icon = utils.getImgSrc(row);
      file.shareIcon = utils.getImgSrcOfShareCard(file.name);
    }
    file.modifiedTime = utils.formatNewestTime(row.modifiedAt);
    file.ownerName = row.ownerName;
    file.desc = row.ownerName;

    files.push(file);
  }

  return files;
}
