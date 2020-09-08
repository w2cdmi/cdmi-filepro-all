// disk/shares/entryMode.js
var config = require('../config.js');
var session = require("../../session.js");

Page({

  /**
   * 页面的初始数据
   */
  data: {
      enterpriseName:''
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    this.setData({
        enterpriseName: getApp().globalData.enterpriseName
    });
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

  touristLogn: function () {
      wx.showLoading({
          title: '创建匿名账号',
          mask: true
      })
      wx.login({
          success: function (res) {
              var code = res.code;
              if (code) {
                  //获取用户信息
                  wx.getUserInfo({
                      success: function (res) {
                          var userInfo = res.userInfo;
                          var data = {
                              code: code,
                              encryptedData: res.encryptedData,
                              iv: res.iv,
                              enterpriseId: getApp().globalData.enterpriseId,
                              appId: config.appId
                          };

                          //请求后台，创建账号
                          wx.request({
                              url: config.host + '/ecm/api/v2/wxOauth2/openWxMpAccount',
                              method: "POST",
                              data: data,
                              header: {
                                  'content-type': 'application/json',
                                  'x-device-sn': '123', //能否获取手机相关信息？
                                  'x-device-type': 'web',
                                  'x-device-os': 'mp',
                                  'x-device-name': 'mp',
                                  'x-client-version': 'v0.1'
                              },
                              success: function (result) {
                                  session.login({
                                      enterpriseId: getApp().globalData.enterpriseId
                                  });
                                  //返回主页
                                  wx.navigateBack({
                                      delta: 1
                                  });
                              }
                          })
                      }
                  });
              } else {
                  console.log('获取用户登录态失败！' + res.errMsg)
              }
          }
      });
  },
  gotoBindAccount: function () {
      wx.redirectTo({
          url: '../enterprise/bindAccount',
      })
  }
})