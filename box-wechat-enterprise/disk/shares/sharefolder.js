// disk/shares/sharefolder.js
/**
 * 此页面只在用户点击“小程序卡片”时（他人分享的目录），才会调用。
 */
var session = require("../../session.js");
var file = require("../module/file.js");
var utils = require("../module/utils.js");
var sharefile = require("../module/sharefile.js")
var app = getApp();

var enterpriseId = 0;
var folderName = "";
var ownerId = 0;
var nodeId = 0;
var nodeId_c = 0;
var NODEID_OWNERID = "";
var NODEID_OWNERID_C = "";
var NODEIDOWNERID = "";
var replyid = "";
var fromId = 0;
var fromName = "";
var crumbs = [];
var isInit = false;

Page({

  /**
   * 页面的初始数据
   */
  data: {
    inputbox: false,
    amount: 0,
    praise_list: [],
    count_comment: 0,
    content: "",
    comments_lists: [],
    showemoji: false,
    showconfirmbar: false,
    reply_type: "top",//"msg" 某条评论 "top" 分享文件的顶层评论
    targetname: "",
    cursor: 1,
    maxcursor: 0
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    // enterpriseId = options.eId;
    ownerId = options.oId;
    nodeId = options.nId;
    fromId = options.fId;

    // ownerId = "1307" || options.oId;
    // nodeId = "1" || options.nId;
    // nodeId_c = "1" || options.nId;


    NODEIDOWNERID = ownerId + nodeId;
    fromName = decodeURIComponent(options.fName || "");
    // getApp().globalData.enterpriseId = enterpriseId;
    getApp().globalData.indexParam = 3; //回到别人分享给我的页面

    //设置分享人
    this.setData({
      sharedBy: fromName,
      crumbs: []
    });
    crumbs = [];
    isInit = false;
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
    if (isInit) {
      return;
    }
    if (this.data.notnet) {
      return this;
    }
    session.login();

    var page = this;
    //等待登录成功后，执行
    session.invokeAfterLogin(function () {

      NODEID_OWNERID = getApp().globalData.cloudUserId;
      NODEID_OWNERID_C = getApp().globalData.cloudUserId;

      wx.setNavigationBarTitle({
        title: getApp().globalData.systemName + getApp().globalData.enterpriseName
      });

      //1. 获取文件信息
      var token = getApp().globalData.token;
      file.getNodeInfo(ownerId, nodeId, function (info) {
        info.menderName = fromName;
        var folders = [];
        folders.push(info);
        folders = file.convertFolderList(folders);
        //设置数据
        page.setData({
          crumbs: crumbs,
          folders: folders,
          scrollHeight: (wx.getSystemInfoSync().windowHeight - 133) + "px",
          isShowSave: true
        });

        isInit = true;
      });

      //2. 保存转发记录(由接收人负责记录)
      var toId = getApp().globalData.cloudUserId;
      file.saveForwardRecord(token, ownerId, nodeId, fromId, toId);

      //点赞
      // page.ispre();
      // page.countpraise();
      // 点赞 / 获取某个信息所获得的点赞人员列表
      // sharefile.praiselist(NODEID_OWNERID, "Tenancy_File", 0, 5, function (data) {
      //   page.setData({
      //     praise_list: data
      //   })
      // })

      // 获取评论数以及评论列表
      page.comments_lists_praise();
      page.setData({
        notnet: true
      });
    });
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
    var cursor = this.data.cursor;
    // console.log("114",cursor < this.data.maxcursor)
    if (cursor < this.data.maxcursor) {
      this.comments_lists_praise({
        cursor: ++cursor,
        more: true
      });
      this.setData({
        cursor: cursor
      })
    }else{
      
    }
  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {
    return {
      title: fileName,
      path: '/disk/index?type=folder&eId=' + enterpriseId + "&oId=" + ownerId + "&nId=" + nodeId + "&fId=" + getApp().globalData.cloudUserId + "&fName=" + encodeURIComponent(getApp().globalData.userName) + "&eName=" + encodeURIComponent(getApp().globalData.enterpriseName),
      imageUrl: '/disk/images/shares/share-card-folder.png',
      success: function (res) {
        // 转发成功
      },
      fail: function (res) {
        // 转发失败
      }
    }
  },

  //点击目录
  onFolderClick: function (e) {
    if (getApp().globalData.token == '') {
      session.login();
      return;
    }
    //转到文件列表视图
    wx.navigateTo({
      url: '/disk/widget/filelist?ownerId=' + ownerId + '&nodeId=' + nodeId + "&name=" + encodeURIComponent(folderName)
    });
  },
  saveToPerson: function (e) {
    //转到文件列表视图
    wx.navigateTo({
      url: '/disk/save/saveToPersion?ownerId=' + ownerId + "&inodeId=" + nodeId,
    })
  },
  onCrumbClick: function (e) { //除第一个面包屑外的面包屑的点击事件
    var page = this;
    var crumb = e.currentTarget.dataset.crumb;

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
    var fileInfo = e.currentTarget.dataset.fileinfo;
    //打开文件
    file.openFile(fileInfo, null);
  },
  lsOfFolderForClickCrum: function (token, ownerId, nodeId) {
    var page = this;
    file.lsOfFolder(token, ownerId, nodeId, function (data) {
      var folders = file.convertFolderList(data.folders);
      var files = file.convertFileList(data.files);

      //判断是不是空文件夹
      var isShowBlankPage = false;
      if (folders.length == 0 && files.length == 0) {
        isShowBlankPage = true;
      }

      page.setData({
        folders: folders,
        files: files,
        isShowBlankPage: isShowBlankPage,
        isShowSave: false
      });
    })
  },
  showinput() {
    NODEID_OWNERID = NODEID_OWNERID_C;
    replyid = NODEIDOWNERID;
    this.setData({
      inputbox: true,
      reply_type: "top",
      targetname: "",
      type: "Tenancy_File"
    })
  },
  comments() {
    //点赞 / test/为某条信息进行点赞
    var that = this;
    if (this.data.is_praised) {
      //分享文件取消点赞
      that.ispre().then(function () {
        remove();
      })

      function remove() {
        sharefile.removeprise({
          id: that.data.ID,
          user_id: NODEID_OWNERID,
          callback: function (data) {
            sharefile.praiselist(NODEIDOWNERID, "Tenancy_File", 0, 5, function (data) {
              that.setData({
                praise_list: data
              })
            })
            that.setData({
              amount: --that.data.amount,
              is_praised: false
            })
          }
        })
      }

    } else {
      //分享文件点赞
      sharefile.comments({
        "target": {
          "id": NODEIDOWNERID,
          "type": "Tenancy_File"
        },
        "owner": {
          "id": NODEID_OWNERID,
          "name": getApp().globalData.userName,
          "headImage": getApp().globalData.avatarUrl
        }
      }, function (data) {
        sharefile.praiselist(NODEIDOWNERID, "Tenancy_File", 0, 5, function (data) {
          that.setData({
            praise_list: data
          })
        })
        that.setData({
          amount: ++that.data.amount,
          is_praised: true
        })
      })
    }

  },
  ispre(options) {
    //// 点赞 / 判断当前用户是否对指定文件点赞
    var that = this;
    options = options || {};
    options.ownerId = options.ownerId || NODEID_OWNERID_C;
    options.nodeId = options.nodeId || NODEIDOWNERID;
    options.type = options.type || "Tenancy_File"
    // Tenancy_File,  //租户文件宝文件  
    //   Tenancy_Comment, //评论类型
    //   Tenancy_User;  //租户用户
    return new Promise(function (reslove, reject) {
      sharefile.ispraise(NODEID_OWNERID, options.nodeId, options.type, function (data) {
        that.setData({
          is_praised: data.praised,
          ID: data.id || ""
        })
        reslove("");
      })

    })
  },
  comments_content() {
    // 评论 / test/对某个信息进行评论
    var that = this;
    var content = that.data.content;
    var targetname = this.data.targetname;
    if (content === "") {
      return;
    }
    if (targetname) {
      content = content.substring(targetname.length + 2)
      if (content) {
        return;
      }
      content = (content + "@><@" + targetname)
    }

    content = escape(content);
    this.close();
    sharefile.comments_msg({
      data: {
        "content": content,
        "target": {
          "id": replyid,
          "type": that.data.type
        },
        "owner": {
          "id": NODEID_OWNERID,
          "name": getApp().globalData.userName,
          "headImage": getApp().globalData.avatarUrl
        }
      },
      callback: function (data) {
        that.setData({
          content: ""
        });
        if (that.data.reply_type === "top") {
          that.comments_lists_praise({
            nodeId: NODEID_OWNERID,
            cursor: "0",
            maxcount: "1"
          });

        } else {
          that.comments_lists_praise({
            nodeId: replyid,
            cursor: "0",
            maxcount: "1",
            target_type: "Tenancy_Comment",
            target_id: replyid,
            callback: function (data) {

            }
          });
        }
      }
    })
  },
  send_content() {
    this.comments_content()
  },
  bindTextAreaInput(e) {
    this.setData({
      content: e.detail.value
    })
  },
  countpraise() {
    // 点赞 / 获取某个信息所获得的点赞数
    var that = this;
    sharefile.countpraise(NODEIDOWNERID, "Tenancy_File", function (data) {
      that.setData({
        amount: data.amount || 0
      })
    })
  },
  reply(e) {
    // NODEID_OWNERID = e.target.dataset.replyid;
    replyid = e.target.dataset.replyid
    this.setData({
      inputbox: true,
      reply_type: "msg",
      type: "Tenancy_Comment"
    })
  },
  close() {
    this.setData({
      inputbox: false,
      targetname: ""
    })
  },
  comments_lists_praise(options) {
    var that = this;
    options = options || {};
    options.cursor = options.cursor || 0;
    options.maxcount = options.maxcount || "6";
    options.target_type = options.target_type || "Tenancy_File";
    options.target_id = options.target_id || NODEIDOWNERID;
    options.callback = options.callback || function () { }

    if (options.target_type === "Tenancy_File") {
      // // 评论 / 获取评论条数
      sharefile.comments_count(NODEIDOWNERID, "Tenancy_File", function (data) {

        that.setData({
          count_comment: data.amount,
          maxcursor: Math.floor(data.amount/options.maxcount) + 1
        })
      })
      // 评论 / 获取对某个信息的评论列表
      sharefile.comments_lists({
        target_id: options.target_id,
        target_type: options.target_type,
        cursor: options.cursor,
        maxcount: options.maxcount,
        callback: function (data) {
          var comments_lists = data;
          var parr = [];
          var isprelist = [];
          if (comments_lists.length > 0) {
            comments_lists.forEach((item) => {
              item.content = unescape(item.content)
              var p = new Promise(function (resolve, reject) {
                //根据一层评论请求二层评论
                sharefile.comments_lists({
                  target_id: item.id,
                  target_type: "Tenancy_Comment", //Tenancy_User
                  cursor: 0,
                  maxcount: 4,
                  callback: function (data) {
                    resolve(data);
                  }
                })
              });
              parr.push(p)
            })
            var promise = Promise.all(parr);
            var newlists;
            promise.then(function (val) {
              comments_lists.map((item, index) => {
                var cur = val[index];
                cur.map((current) => {
                  var con = unescape(current.content).split("@><@");
                  current.content = (con[0]);
                  if (con.length >= 2) {
                    current.owner.showname = unescape(current.owner.name) + "@" + con[1]
                  } else {
                    current.owner.showname = current.owner.name
                  }
                })
                item.chidren = val[index]
                // item.reply = val[index].length;
                item.cursor = 0;
                item.maxpage = 0;
                //判断一层评论是否是当前用户点赞
                var p = new Promise(function (resolve, reject) {
                  sharefile.ispraise(NODEID_OWNERID_C, item.id, "Tenancy_Comment", function (data) {
                    data.Tid = item.id
                    data.type = "praised"
                    resolve(data);
                    reject({
                      id: item.id,
                      praised: false,
                      type: "praised"
                    })
                  })
                })
                var len = new Promise(function (resolve, reject) {
                  sharefile.comments_count(item.id, "Tenancy_Comment", function (data) { //Tenancy_File Tenancy_Comment
                    data.Tid = item.id
                    data.type = "amount"
                    resolve(data);
                    reject({
                      id: item.id,
                      amount: 0,
                      type: "amount"
                    });
                  })
                })
                isprelist.push(p);
                isprelist.push(len);
              })
              newlists = comments_lists;
              var p_isprelist = Promise.all(isprelist);
              p_isprelist.then(function (val) {
                comments_lists.length > 0 && comments_lists.map((item, index) => {
                  val.forEach((cur) => {
                    if (item.id === cur.Tid) {
                      if (cur.type === "amount") {
                        item.reply = cur.amount;
                        item.maxpage = Math.floor(cur.amount / 4) + 1;
                      }
                      if (cur.type === "praised") {
                        item.is_praised = cur.praised;
                        item.praisedID = cur.id;
                      }
                    }
                  })
                })
                var lists = that.data.comments_lists;
                //优化回复否的请求
                if (options.more) {
                  comments_lists = lists.concat(comments_lists);
                } else {
                  comments_lists = comments_lists.concat(lists);
                }
                that.setData({
                  comments_lists: comments_lists
                })
              })

            });
          }

        }
      });
    } else {
      sharefile.comments_lists({
        target_id: options.target_id,
        target_type: "Tenancy_Comment", // bug?   "Tenancy_Comment"
        cursor: options.cursor,
        maxcount: options.maxcount,
        callback: function (data) {
          var con = unescape(data[0].content).split("@><@")
          data[0].content = (con[0]);
          if (con.length >= 2) {
            data[0].owner.showname = data[0].owner.name + "@" + con[1]
          } else {
            data[0].owner.showname = data[0].owner.name
          }
          var lists = that.data.comments_lists;
          for (var i = 0, len = lists.length; i < len; i++) {
            if (lists[i].id == options.target_id) {
              if (!lists[i].chidren) {
                lists[i].chidren = [];
              }
              lists[i].chidren = data.concat(lists[i].chidren);
              ++lists[i].reply;
              break;
            }
          }
          that.setData({
            comments_lists: lists
          })
        }
      })
    }


  },
  comments_isperitem(e) {
    // 每条评论的判断是否已经点赞方法
    // //点赞 / test/为某条信息进行点赞
    var is_praised = e.target.dataset.is_praised;
    var item_id = e.target.dataset.item_id;
    var index = e.target.dataset.index;
    var change = e.target.dataset.change;
    var praisedID = e.target.dataset.praisedid;
    // console.log(praisedID, 1)

    var that = this;
    if (Boolean(is_praised)) {
      //分享文件取消点赞

      var ispraise = new Promise(function (resolve, reject) {
        sharefile.ispraise(NODEID_OWNERID, item_id, "Tenancy_Comment", function (data) {
          var comments_lists = that.data.comments_lists;
          comments_lists[index].praisedID = data.id;
          comments_lists[index].change = true;
          praisedID = data.id;
          that.setData({
            comments_lists: comments_lists
          })
          resolve(data);
        })
      })
      ispraise.then((data) => {
        remove();
      })
      function remove() {
        // console.log(praisedID, 4)
        sharefile.removeprise({
          id: praisedID,
          user_id: NODEID_OWNERID,
          callback: function (data) {
            var lists = that.data.comments_lists;
            lists.map((item) => {
              if (item.id === item_id) {
                item.is_praised = false;
                --item.praiseNumber
              }
            })
            that.setData({
              comments_lists: lists
            })
          }
        })
      }

    } else {
      go();
      function go() {
        sharefile.comments({
          "target": {
            "id": item_id,
            "type": "Tenancy_Comment"
          },
          "owner": {
            "id": NODEID_OWNERID,
            "name": getApp().globalData.userName,
            "headImage": getApp().globalData.avatarUrl
          }
        }, function (data) {
          var lists = that.data.comments_lists;
          lists.map((item) => {
            if (item.id === item_id) {
              item.is_praised = true;
              ++item.praiseNumber
            }
          })
          that.setData({
            comments_lists: lists
          })
        })
      }

    }

  },
  showemoji() {
    this.setData({
      showemoji: true
    })
  },
  more_item_msg(e) {
    var that = this;
    var target_id = e.target.dataset.target_id;
    var cursor = parseInt(e.target.dataset.cursor);

    sharefile.comments_lists({
      target_id: target_id,
      target_type: "Tenancy_Comment", // bug?
      cursor: ++cursor,
      maxcount: "4",
      callback: function (data) {
        var lists = that.data.comments_lists;
        for (var i = 0, len = lists.length; i < len; i++) {
          if (lists[i].id == target_id) {
            if (!lists[i].chidren) {
              lists[i].chidren = [];
            }
            lists[i].cursor = cursor;
            lists[i].chidren = lists[i].chidren.concat(data);
            // lists[i].reply = lists[i].chidren.length;
            break;
          }
        }
        that.setData({
          comments_lists: lists
        })
      }
    })
  },
  reply_target(e) {
    var targetname = e.target.dataset.targetname || "";
    // NODEID_OWNERID = e.target.dataset.targetid;
    replyid = e.target.dataset.targetid;
    var content = "";
    if (targetname) {
      content = "@" + targetname + " ";
    }

    this.setData({
      inputbox: true,
      content: content,
      targetname: targetname,
      type: "Tenancy_Comment",
      reply_type: "msg"
    })

  },
  bindblur() {
    this.setData({
      inputbox: false
    })
  },
  lower(){
    console.log(1)
  }

});

//查询指定目录下的文件列表(ls命令)
function lsOfFolder(token, ownerId, nodeId, page, folderNodeName, folderOwnerId, folderNodeId) {
  file.lsOfFolder(token, ownerId, nodeId, function (data) {
    var folders = file.convertFolderList(data.folders);
    var files = file.convertFileList(data.files);

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
      isShowBlankPage: isShowBlankPage,
      isShowSave: false
    });
  })
}