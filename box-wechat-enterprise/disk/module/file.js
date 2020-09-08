var config = require("../config.js");
var httpclient = require("httpclient.js");
var utils = require("utils.js");
var musicServicce = require("music.js");

//
var LOCAL_FILES_KEY = "LOCAL_FILES_KEY";

var file = {
    host: config.host,
    endpoint: {
        // 获取最新浏览的文件
        listLastReadFile: config.host + '/wxwork/folders/',
        // 获取我分享出去的文件以及文件夹
        listMySharetTo: config.host + '/wxwork/myShares/list',
        // 获取外链信息
        getLinkInfo: config.host + '/ufm/api/v2/links/node',
    },
};

// 获取最新浏览的文件
function listLastReadFile(token, cloudUserId, callback) {
    var header = {
        Authorization: token
    };
    var params = {
        thumbnail: [{ width: 120, height: 120 }, { width: 500, height: 500 }]
    }
    httpclient.post(config.host + '/ufm/api/v2/folders/' + cloudUserId + "/recent", params, header, callback);
};

// 获取我分享出去的文件以及文件夹
function listMySharetTo(token, callback) {
    var header = {
        Authorization: token
    };
    var params = {
        thumbnail: [{ width: 120, height: 120 }, { width: 500, height: 500 }]
    }
    return httpclient.post(config.host + '/ufm/api/v2/shares/distributed', params, header, callback);
};

// 获取他人分享给我的文件以及文件夹
function listShareToMe(token, callback) {
    var header = {
        Authorization: token
    };
    var params = {
        thumbnail: [{ width: 120, height: 120 }, { width: 500, height: 500 }]
    }
    return httpclient.post(config.host + '/ufm/api/v2/shares/received', params, header, callback);
};

// 获取我所拥有的部门文件列表
function listDeptSpace(token, cloudUserId, offset, limit, callback) {
    var header = {
        Authorization: token
    };
    var params = {
        limit: limit,
        offset: offset,
        'type': 1,
        userId: cloudUserId,
    }
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces/items', params, header, callback);
};

// 获取我有权限访问的项目团队空间列表
function listTeamSpace(token, cloudUserId, offset, limit, callback) {
    var params = {
        limit: limit,
        offset: offset,
        'type': 0,
        userId: cloudUserId,
    }
    var header = {
        Authorization: token
    };
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces/items', params, header, callback);
};

// 获取我有权限访问的企业文库空间列表
function listEnterpriseSpace(token, cloudUserId, offset, limit, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        limit: limit,
        offset: offset,
        'type': 4,
        userId: cloudUserId
    }
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces/items', params, header, callback);
};
// 恢复文件
function trash(token, ownerId, nodeId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        autoRename: true
    }
    return httpclient.put(config.host + '/ufm/api/v2/trash/' + ownerId + '/' + nodeId, params, header, callback);
};
// 回收站删除
function trashclean(token, nodeId, ownerId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        autoRename: true
    }
    return httpclient.remove(config.host + '/ufm/api/v2/trash/' + nodeId + '/' + ownerId, params, header, callback);
};
// 获取成员列表
function listDepAndUsers(token, deptId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        deptId: deptId
    }
    return httpclient.post(config.host + '/ecm/api/v2/users/listDepAndUsers', params, header, callback);
};
// 添加成员
function addmember(token, memberList, teamId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        memberList: memberList,
        role:"uploadAndView",
        teamRole:"member"
    }
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces/' + teamId + '/memberships', params, header, callback);
};
// 创建协作空间
function teamspaces(token, name, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        description: '',
        name: name
    }
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces', params, header, callback);
};
// 协作空间成员管理
function memberteamlist(token, taemId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        keyword: ''
    }
    return httpclient.post(config.host + '/ufm/api/v2/teamspaces/' + taemId + '/memberships/items', params, header, callback);
};

function deleteMember(userId, taemId, callback){
    var header = {
        Authorization: getApp().globalData.token,
    };
    var params = [userId]
    return httpclient.remove(config.host + '/ufm/api/v2/teamspaces/' + taemId + '/memberships/batch', params, header, callback);
}

function deleteTeam(taemId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var params = {};
    return httpclient.remove(config.host + '/ufm/api/v2/teamspaces/' + taemId, params, header, callback);
}

//获取文件夹目录信息(ls命令)
function lsOfFolder(token, ownerId, nodeId, callback) {
    var header = {
        Authorization: token,
    };
    var params = {
        order: [{ field: "modifiedAt", desc: "true" }],
        thumbnail: [{ width: 120, height: 120 }, { width: 500, height: 500 }]
    }
    return httpclient.post(config.host + '/ufm/api/wxmp/folders/' + ownerId + '/' + nodeId + '/items', params, header, callback);
};

//获取文件详情信息
function getFileDetail(token, ownerId, fileId, callback) {
    var header = {
        Authorization: token,
    };
    return httpclient.get(config.host + '/ufm/api/wxmp/files/' + ownerId + '/' + fileId, null, header, callback);
}

//获取文件下载地址
function getFileDownloadUrl(ownerId, fileId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    return httpclient.get(config.host + '/ufm/api/wxmp/files/' + ownerId + '/' + fileId + "/url", null, header, callback);
}

//获取文件下载地址
function getPreImageDownloadUrl(ownerId, fileId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    return httpclient.getSync(config.host + '/ufm/api/wxmp/files/' + ownerId + '/' + fileId + "/url", null, header, callback);
}

//获取文件下载地址，并且不将文件加最近浏览记录
function getPreImageDownloadUrlNotRecord(ownerId, fileId, callback){
    var header = {
        Authorization: getApp().globalData.token,
    };
    return httpclient.getSync(config.host + '/ufm/api/v2/files/' + ownerId + '/' + fileId + "/urlWx", null, header, callback);
}

// 获取指定文档空间中的文件列表
function listSpaceFile() {
    var data = {};
    return httpclient.get(file.endpoint.listSpaceFile, data);
};

// 按照指定排序获取指定文档空间中的所有文件列表
function listSpaceFileByOrder(orderstyle, desc) {
    var data = { "order": desc };
    return httpclient.get(file.endpoint.listSpaceFile, data);
};

// 获取指定文档空间中的分页文件列表
function listSpaceFileWithPage(pagenumber, pagesize) {
    if (!pagesize) {
        pagesize = config.defaultPageSize;
    }
    var data = {
        "pagenumber": pagenumber,
        "pagesize": pagesize,
    };
    return httpclient.get(file.endpoint.listSpaceFile, data);
};
// 获取回收站的文件
function recycleFile(token, ownerId, callback) {
    var header = {
        Authorization: token
    };
    var params = {
        thumbnail: [{ width: 120, height: 120 }, { width: 500, height: 500 }]
    }
    httpclient.post(config.host + '/ufm/api/v2/trash/' + ownerId, params, header, callback);
};

// 按照指定排序获取指定文档空间中的分页文件列表（指定页码）
function listSpaceFileByOrderWithPage(pagenumber, pagesize, orderstyle, sort) {
    if (!pagesize) {
        pagesize = config.defaultPageSize;
    }
    if (!orderstyle) {
        orderstyle = config.defaultOrderStyle;
    }
    if (!sort) {
        sort = config.defaultOrderSort;
    }
    var data = {
        "orderstyle": orderstyle,
        "order": sort,
        "pagenumber": pagenumber,
        "pagesize": pagesize,
    };
    return httpclient.get(file.endpoint.listSpaceFile, data);
};

// 显示指定目录下的文件以及子文件列表
function listFolderFile() {
    var data = {};
    return httpclient.get(file.endpoint.listFolderFile, data);
};

// 搜索满足条件的文件与文件目录
function searchFileAndFolder(searchtext) {
    var data = {};
    return httpclient.get(file.endpoint.searchFileAndFolder, data);
};

// 更新最新浏览记录
function updateLastReadFile() {
    var data = {};
    return httpclient.get(file.endpoint.updateLastReadFile, data);
}

// 获取iNode节点信息
function getNodeInfo(ownerId, nodeId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var params = {
        width: 120,
        height: 120
    }
    return httpclient.get(config.host + '/ufm/api/wxmp/nodes/' + ownerId + '/' + nodeId, params, header, callback);
}

// 获取外链信息
function getLinkInfo(linkCode, accessCode, callback) {
    var date = new Date().toUTCString();
    //对访问码+时间加密
    var signature = utils.sha256AndBase64(accessCode, date);
    var token = "link," + linkCode + "," + signature;

    var header = {
        Authorization: token,
        // Date: date  //不允许设置Date字段
    };

    return httpclient.get(file.endpoint.getLinkInfo, null, header, callback);
}

//增加转发记录
function saveForwardRecord(token, ownerId, nodeId, fromId, toId, callback) {
    var header = {
        Authorization: token,
    };
    var data = {
        fromId: fromId,
        toId: toId
    };

    return httpclient.put(config.host + '/ufm/api/v2/forward/' + ownerId + '/' + nodeId, data, header, callback);
}

/**
 * 下载并打开文件。文件会保存在本地缓存，文件信息会保存在本地存储。
 * meta： 文件信息，包含以下字段：
 *  ownerId:
 *  nodeId:
 *  name:  文件名（如果有重名，可能会自动增加后缀）
 *  size:
 */
function downloadAndOpenFile(token, ownerId, nodeId, meta) {
    //检查文件大小
    var size = meta.size || 0;
    //根据文件类型打开
    var ext = meta.name.substring(meta.name.lastIndexOf('.') + 1, meta.name.length).toLowerCase();
    //   if (ext != "mp4"){
    if (size > 1024 * 1024 * 10) {
        wx.showModal({
            title: '提示',
            content: '暂不支持10MB以上文件的在线预览',
            showCancel: false
        });
        return;
    }
    //   }

    //获取URL
    getFileDownloadUrl(ownerId, nodeId, function (data) {
        if (data.statusCode == 403) {
            wx.showToast({
                title: '没有访问权限'
            });
            return;
        };
        wx.showLoading({
            title: '下载中...',
            mask: true
        })

        //小程序不允许URL中有端口，将端口进行替换
        var url = utils.replacePortInDownloadUrl(data.downloadUrl);

        //设置保存到本地的文件信息
        meta = meta || {};
        meta.ownerId = ownerId;
        meta.nodeId = nodeId;

        //如果没有提供文件名，就从URL中获取。
        if (meta.name == undefined) {
            meta.name = decodeURIComponent(url.substring(url.lastIndexOf("/") + 1));
        }

        //下载文件
        wx.downloadFile({
            url: url,
            success: function (res) {
                meta.path = res.tempFilePath;
                openLocalFile(meta);
            },
            fail: function (res) {
                wx.showToast({
                    title: '下载失败！',
                })
            }
        });
    });
}

//打开文件
function openFile(file, callback) {
    //根据文件类型打开
    var ext = file.name.substring(file.name.lastIndexOf('.') + 1, file.name.length).toLowerCase();
    if (ext == 'jpg' || ext == 'png' || ext == 'gif' || ext == 'bmp' || ext == 'jpeg' || ext == 'jpeg2000' || ext == 'tiff' || ext == 'psd') {
        previewImage(file.ownedBy, file.id, file.name);
    } else if (ext == 'txt' || ext == 'doc' || ext == 'xls' || ext == 'ppt' || ext == 'pdf' || ext == 'docx' || ext == 'xlsx' || ext == 'pptx') {
        // downloadFileAndPreview(file.ownedBy, file.id, file.size, ext);  //小程序自带预览接口
        previewFile(file.ownedBy, file.id);      //自己预览接口
    } else if (ext == 'mp4') {
        playVoice(file.ownedBy, file.id);
    } else if (ext == 'mp3') {
        playOrAddMusic(file.ownedBy, file.id, file.name, callback);
    } else {
        wx.showToast({
            title: '不支持文件类型',
        });
    }
}

function playOrAddMusic(ownerId, inodeId, fileName, callback) {
    var playMusicResponse = {};
    var musicList = getApp().globalData.musicList;
    var innerAudioContext = getApp().globalData.innerAudioContext;

    if (typeof (musicList) == 'undefined' || musicList == "" || musicList.length == 0) {
        musicList = musicServicce.getMusicListByStorage();
    }

    if (typeof (innerAudioContext) == 'undefined' || innerAudioContext == '') {
        innerAudioContext = wx.createInnerAudioContext();
        getApp().globalData.innerAudioContext = innerAudioContext;
    }
    //本地缓存为空，则表示重未加入列表，直接播放
    if (typeof (musicList) == 'undefined' || musicList == "" || musicList.length == 0) {
        musicServicce.addMusicToStorage(ownerId, inodeId, fileName, musicServicce.PLAY_STATE);

        playMusic(ownerId, inodeId, fileName, callback);
    } else {
        //只添加到播放列表
        musicServicce.addMusicToStorage(ownerId, inodeId, fileName, musicServicce.NORMAL_STATE);
        if (typeof (callback) == 'function') {
            playMusicResponse.state = musicServicce.NORMAL_STATE;
            callback(playMusicResponse);
        }
        return;
    }
}

function playMusic(ownerId, inodeId, fileName, callback) {
    var playMusicResponse = {};
    var musicList = getApp().globalData.musicList;
    var innerAudioContext = getApp().globalData.innerAudioContext;

    if (typeof (innerAudioContext) == 'undefined' || innerAudioContext == '') {
        innerAudioContext = wx.createInnerAudioContext();
        getApp().globalData.innerAudioContext = innerAudioContext;
    }

    if (typeof (musicList) != 'undefined' || musicList != "" || musicList.length != 0) {
        //获取URL
        getFileDownloadUrl(ownerId, inodeId, (data)=>{

            //小程序不允许URL中有端口，将端口进行替换
            var url = utils.replacePortInDownloadUrl(data.downloadUrl);

            innerAudioContext.src = url;
            innerAudioContext.autoplay = true;

            if (typeof (callback) == 'function') {
                playMusicResponse.state = musicServicce.PLAY_STATE;
                callback(playMusicResponse);
            }
        });
    } else {
        if (typeof (callback) == 'function') {
            //播放列表错误
            playMusicResponse.state = -1;
            callback(playMusicResponse);
        }
    }

}

function previewImage(ownerId, nodeId, name) {
    var imgUrls = getApp().globalData.imgUrls;
    var url = "";
    for (var i = 0; i < imgUrls.length; i++) {
        if (imgUrls[i].indexOf(name) != -1) {
            url = imgUrls[i];
            getPreImageDownloadUrl(ownerId, nodeId);  //添加点击的图片到最近浏览
            break;
        }
    }
    utils.previewImage(imgUrls, url);
}

//下载文件到本地缓存（10M以内文件）
function downloadFileAndPreview(ownerId, inodeId, size, ext) {
    var flag = utils.isPreviewFileSize(size);
    if (!flag) {
        wx.showModal({
            title: '提示',
            content: '暂不支持10MB以上文件的在线预览',
            showCancel: false
        });
        return;
    } else {
        //获取URL
        getFileDownloadUrl(ownerId, inodeId, function (data) {
            if (data.statusCode == 403) {
                wx.showToast({
                    title: '没有访问权限'
                });
                return;
            };
            wx.showLoading({
                title: '下载中...',
                mask: true
            })

            //小程序不允许URL中有端口，将端口进行替换
            var url = utils.replacePortInDownloadUrl(data.downloadUrl);

            //下载文件
            wx.downloadFile({
                url: url,
                success: function (res) {
                    var path = res.tempFilePath;
                    openLocalFile(path, ext);
                },
                fail: function (res) {
                    wx.showToast({
                        title: '下载失败！',
                    })
                }
            });
        });
    }
}

//打开本地文件
//path: 本地缓存文件路径 downloadfile方法获取
//ext： 文件类型 
function openLocalFile(path, ext) {
    wx.openDocument({
        filePath: path,
        fileType: ext,
        success: function (data) {
            wx.hideLoading();
        }, fail: function (res) {
            wx.showToast({
                title: '打开文件失败',
            });
        }
    });
}

//播放视频
function playVoice(ownerId, inodeId) {
    //获取URL
    getFileDownloadUrl(ownerId, inodeId, function (data) {
        if (data.statusCode == 403) {
            wx.showToast({
                title: '没有访问权限'
            });
            return;
        };
        wx.showLoading({
            title: '下载中...',
            mask: true
        })

        //小程序不允许URL中有端口，将端口进行替换
        var url = utils.replacePortInDownloadUrl(data.downloadUrl);

        wx.hideLoading();
        wx.navigateTo({
            url: '/disk/widget/video?path=' + url + "&id=" + inodeId,
        })
    });
}

function getPreUploadFileUrl(ownerId, parentId, name, size, callback) {
    var data = {
        name: name,
        size: size,
        parent: parentId
    }
    var header = {
        Authorization: getApp().globalData.token
    };
    return httpclient.put(config.host + '/ufm/api/v2/files/' + ownerId, data, header, callback);
}

function uploadFile(url, name, path, callback) {
    var url = utils.replacePortInDownloadUrl(url);
    const uploadTask = wx.uploadFile({
        url: url, //仅为示例，非真实的接口地址
        filePath: path,
        name: name,
        success: function (res) {
            if (typeof (callback) == "function") {
                callback(res);
            }
        }
    });
    uploadTask.onProgressUpdate((res) => {
        console.log('上传进度', res.progress)
        console.log('已经上传的数据长度', res.totalBytesSent)
        console.log('预期需要上传的数据总长度', res.totalBytesExpectedToSend)
    })
}

function createFolder(folderName, ownerId, nodeId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var data = {
        name: folderName,
        parent: nodeId
    };
    return httpclient.post(config.host + '/ufm/api/v2/folders/' + ownerId, data, header, callback);
}

function copyFileToOther(ownerId, nodeId, destOwnerId, destParent, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var data = {
        autoRename: true,
        destOwnerId: destOwnerId,
        destParent: destParent
    }
    return httpclient.put(config.host + '/ufm/api/v2/files/' + ownerId + "/" + nodeId + "/copy", data, header, callback);
}
//移动文件到
function moveFileToOther(ownerId, nodeId, destOwnerId, destParent, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var data = {
        autoRename: true,
        destOwnerId: destOwnerId,
        destParent: destParent
    }
    return httpclient.put(config.host + '/ufm/api/v2/files/' + ownerId + "/" + nodeId + "/move", data, header, callback);
}

function copyFolderToOther(ownerId, nodeId, destOwnerId, destParent, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var data = {
        autoRename: true,
        destOwnerId: destOwnerId,
        destParent: destParent
    }
    return httpclient.put(config.host + '/ufm/api/v2/folders/' + ownerId + "/" + nodeId + "/copy", data, header, callback);
}

function moveFolderToOther(ownerId, nodeId, destOwnerId, destParent, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var data = {
        autoRename: true,
        destOwnerId: destOwnerId,
        destParent: destParent
    }
    return httpclient.put(config.host + '/ufm/api/v2/folders/' + ownerId + "/" + nodeId + "/move", data, header, callback);
}

function convertFileList(data) {
    var files = [];
    var imgUrls = [];
    for (var i = 0; i < data.length; i++) {
        var file = data[i];
        if (file.thumbnailUrlList.length == 0) {
            file.icon = utils.getImgSrc(file);
        } else {
            file.icon = utils.replacePortInDownloadUrl(file.thumbnailUrlList[0].thumbnailUrl);
            if (utils.isPreviewFileSize(file.size)) {
                getPreImageDownloadUrlNotRecord(file.ownedBy, file.id, function (data) {
                    //小程序不允许URL中有端口，将端口进行替换
                    var url = utils.replacePortInDownloadUrl(data.downloadUrl);
                    imgUrls.push(url);
                    getApp().globalData.imgUrls = imgUrls;
                });
            }
        }
        file.fileSize = utils.formatFileSize(data[i].size);
        file.modifiedTime = utils.formatDate(data[i].modifiedAt);
        files.push(file);
    }
    return files;
}

function convertFolderList(data) {
    var folders = [];
    for (var i = 0; i < data.length; i++) {
        var folder = data[i];
        if (typeof (folder.isListAcl) == 'undefined' || folder.isListAcl) {
            folder.icon = '../images/icon/folder-icon.png';
        } else {
            folder.icon = '../images/icon/folder-forbidden-icon.png';
        }
        folder.modifiedTime = utils.formatDate(folder.modifiedAt);
        folders.push(folder)
    }
    return folders;
}

function deleteNode(ownerId, nodeId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    var params = {}
    return httpclient.remove(config.host + '/ufm/api/v2/nodes/' + ownerId + "/" + nodeId, params, header, callback);
}

function deleteFileAndClearTrash(ownerId, nodeId, callback) {
    deleteNode(ownerId, nodeId, function () {
        var header = {
            Authorization: getApp().globalData.token,
        };
        var params = {}
        return httpclient.remove(config.host + '/ufm/api/v2/trash/' + ownerId + "/" + nodeId, null, header, callback);
    });
}

function updateFileName(ownerId, nodeId, name, callback){
    var header = {
        Authorization: getApp().globalData.token,
    };
    var params = {
        name: name
    }
    return httpclient.put(config.host + '/ufm/api/v2/nodes/' + ownerId + "/" + nodeId, params, header, callback);
}

function getPreviewFileUrl(ownerId, nodeId, callback){
    var header = {
        Authorization: getApp().globalData.token,
    };
    return httpclient.get(config.host + '/ufm/api/v2/files/' + ownerId + "/" + nodeId + "/preview", null, header, callback);
}

function previewFile(ownerId, nodeId){
    getPreviewFileUrl(ownerId, nodeId, function(data){
        wx.navigateTo({
            url: '/disk/widget/preview?url=' + encodeURIComponent(data.url),
        })
    });
}

function deleteBrowseRecord(ownerId, nodeId, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };
    return httpclient.remove(config.host + '/ufm/api/v2/folders/' + ownerId + "/recent/delete/" + nodeId, null, header, callback);
}

module.exports = {
    listLastReadFile,
    listMySharetTo,
    listShareToMe,
    listTeamSpace,
    listEnterpriseSpace,
    listDeptSpace,
    getFileDetail,
    getFileDownloadUrl,
    getPreImageDownloadUrl,
    getPreImageDownloadUrlNotRecord,
    lsOfFolder,
    getNodeInfo,
    getLinkInfo,
    saveForwardRecord,
    downloadAndOpenFile,
    openLocalFile,
    getPreUploadFileUrl,
    uploadFile,
    convertFileList,
    convertFolderList,
    openFile,
    createFolder,
    copyFileToOther,
    copyFolderToOther,
    moveFileToOther,
    moveFolderToOther,
    playMusic,
    deleteNode,
    deleteFileAndClearTrash,
    updateFileName,
    deleteBrowseRecord,
    recycleFile,
    trash,
    trashclean,
    listDepAndUsers,
    teamspaces,
    addmember,
    memberteamlist,
    deleteMember,
    deleteTeam
};