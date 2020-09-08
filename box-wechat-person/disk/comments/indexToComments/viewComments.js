// disk/comments/indextocomments/viewcomments.js
var session = require("../../../session.js");
var Message = require("../../module/message.js");
var Utils = require("../../module/utils.js");

Page({

    /**
     * 页面的初始数据
     */
    data: {

    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
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
        var page = this;

        session.login();
        session.invokeAfterLogin(function () {
            page.reuestCommentsMsg('UNREAD');
        });
    },
    /*请求评论的消息
    */
    reuestCommentsMsg: function (status, param = {}) {//TODO:这里暂时显示“已读”消息
        var page = this;
        var params = new Object();
        status.currentTarget == undefined ? status = "UNREAD" : status = "READED";
        if (status == "READED") {
            params.cursor = param.cursor == undefined ? 0 : param.cursor;
            params.maxcount = 5;//一次加载最大的条数
        }
        params.status = status;

        Message.viewCommentsList(params, (res) => {
            if (res !== undefined && res.length > 0) {
                for (var i = 0; i < res.length; i++) {
                    res[i].createTime = Utils.formatNewestTime(res[i].createTime);
                    if (res[i].eventObject.type == "Tenancy_File") {//等接口完善，这里可以获取文件详情，加一个判断来动态显示文件图片
                        res[i].eventContent.text = unescape(res[i].eventContent.text);
                        if (res[i].eventContent.text == ""){
                            res[i].eventContent.text = "他点赞了你";
                        }
                        res[i].fileImg = '../../images/shares/share-card-mp4.png';
                    } else {
                        var con = unescape(res[i].eventContent.text).split("@><@");
                        res[i].eventContent.text = (con[0]);
                        // if (con.length >= 2) {
                        //     current.owner.showname = unescape(current.owner.name) + " 回复 " + con[1]
                        // } else {
                        //     current.owner.showname = current.owner.name
                        // }

                        // res[i].eventContent.text = unescape(res[i].eventContent.text);
                        if (res[i].eventContent.text == "") {
                            res[i].eventContent.text = "他点赞了你";
                        }
                        res[i].fileImg = '../../images/icon/message-active.png';
                    }
                }
                if (status == 'READED' && page.data.readedPage != undefined && page.data.readedPage != 0) {//将已读和未读消息都展示
                    res.push.apply(page.data.commentsList, res);
                }
                page.setData({
                    commentsList: res,
                })
            }
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
        this.setData({
            readedPage: this.data.readedPage == undefined ? 0 : this.data.readedPage + 1
        })
        var params = new Object();
        var status = new Object();
        params.cursor = this.data.readedPage;
        status.currentTarget = "READED"
        this.reuestCommentsMsg(status, params);
    },

    jumpSharefile: function (e) {
        var item = e.currentTarget.dataset.item;

        if (item.eventObject.type == "Tenancy_File") {
            wx.navigateTo({
                url: '/disk/shares/sharefile?linkCode=' + item.eventObject.id,
            })
        } else {
            Message.getLinkCodeByObjectId(item.eventObject.id, function (data) {
                wx.navigateTo({
                    url: '/disk/shares/sharefile?linkCode=' + data.targetId,
                })
            });
        }
    }
})