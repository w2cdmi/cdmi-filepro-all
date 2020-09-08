var file = require("../module/file.js");

function showOperation(e) {
    var top = e.detail.y;
    var left = e.detail.x;
    //获取屏幕点击位置
    var top = e.detail.y;
    var left = e.detail.x;
    //获取屏幕宽度
    var window_width = wx.getSystemInfoSync().windowWidth;
    var window_height = wx.getSystemInfoSync().windowHeight;

    //获取显示的操作菜单大小；样式设置
    var menu_width = 128;
    // var menu_height = 126;
    var menu_height = 127;

    if (left + menu_width > window_width) {
        left = left - menu_width;
    }
    if (top + menu_height > window_height) {
        top = top - menu_height;
    }

    var nodeInfo = e.currentTarget.dataset.folderinfo;
    if (typeof (nodeInfo) == 'undefined') {
        nodeInfo = e.currentTarget.dataset.fileinfo;
    }
    var node = {};
    node.ownerId = nodeInfo.ownedBy;
    node.nodeId = nodeInfo.id;
    node.name = nodeInfo.name;
    node.type = nodeInfo.type;
    this.setData({
        menu_top: top,
        menu_left: left,
        isShowMenu: true,
        node: node
    });
}

function hideOperation() {
    this.setData({
        isShowMenu: false
    });
}

function updateNodeName(e) {
    var page = this;
    var newFolderName = e.currentTarget.dataset.name;
    var fileSuffix = "";
    var nodeType = e.currentTarget.dataset.type;
    if (nodeType == 1) {
        var index = newFolderName.lastIndexOf(".");
        if (index != -1) {
            fileSuffix = newFolderName.substring(index);
            newFolderName = newFolderName.substring(0, index);
        }
    }
    page.setData({
        newFolderName: newFolderName,
        isShowMenu: false
    });
    page.showUpdateFolderPanel(page, newFolderName, fileSuffix);
}

function deleteNode(e) {
    var name = e.currentTarget.dataset.name;
    var page = this;
    page.hideOperation();

    wx.showModal({
        title: '提示',
        content: "确认删除 " + name + " 吗？",
        success: function (res) {
            if (res.confirm) {
                var ownerId = e.currentTarget.dataset.ownerId;
                var nodeId = e.currentTarget.dataset.nodeId;
                var accountType = getApp().globalData.accountType;
                if (accountType == 0 || accountType > 100) {
                    //删除文件并清楚回收站
                    file.deleteFileAndClearTrash(ownerId, nodeId, function () {
                        wx.showToast({
                            title: '删除成功！',
                        });
                        page.setData({
                            isShowMenu: false
                        });
                        page.refreshCurrentFolder();
                    });
                } else {
                    //删除文件
                    file.deleteNode(ownerId, nodeId, function () {
                        wx.showToast({
                            title: '删除成功！',
                        });
                        page.setData({
                            isShowMenu: false
                        });
                        page.refreshCurrentFolder();
                    });
                }
            }
        }
    })
}

function moveTo(e) {
    var ownerId = e.currentTarget.dataset.ownerId;
    var nodeId = e.currentTarget.dataset.nodeId;
    wx.navigateTo({
        url: '/disk/save/moveToOther?ownerId=' + ownerId + '&inodeId=' + nodeId,
    });
    var page = this;
    page.hideOperation();
}

module.exports = {
    updateNodeName,
    deleteNode,
    showOperation,
    hideOperation,
    moveTo
};