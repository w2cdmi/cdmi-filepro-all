// disk/comments/comments.js
var util = require("../module/utils.js");
var user = require("../module/user.js");
var config = require("../config.js");
var httpclient = require("../module/httpclient.js");
var session = require("../../session.js");
Page({

  /**
   * 页面的初始数据
   */
  data: {
    inputbox: false
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    var params = "";
    var header = "";
    var callback = function (data) {
      console.log("data",data)
     };
    httpclient.post(config.host + '/praise/v1', params, header, callback)
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
  onShareAppMessage: function () {

  },
  showinput() {
    console.log(1)
    this.setData({
      inputbox: true
    })
  },
  close() {
    this.setData({
      inputbox: false
    })
  }
})