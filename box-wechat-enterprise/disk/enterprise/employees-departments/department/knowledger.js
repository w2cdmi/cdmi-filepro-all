var enterpriseClient = require("../../../module/enterprise.js");
var config = require("../../../config.js");

var deptId = 0;

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
        deptId = options.deptId;
        if (deptId == undefined) {
            wx.showToast({
                title: '获取部门ID失败！',
                icon: 'none',
                duration: 1000
            })
            setTimeout(function () {
                wx.navigateBack({
                    delta: 1
                })
            }, 1000);
        }
    },

    /**
     * 生命周期函数--监听页面显示
     */
    onShow: function () {
        enterpriseClient.getDepartmentKnowledger(deptId, function (data) {
            console.log(data);
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

    },
})