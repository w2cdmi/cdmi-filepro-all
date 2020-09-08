// disk/find/index.js
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
  
  },

  onShowMenu: function () {
      this.setData({
          isShowMenu: "true"
      })
  },

  onUploadImage: function (e) {
      var page = this;
      console.log("不能上传");
  },
  onUploadVideo: function (e) {
      var page = this;
      var tempFile = e.detail;

      getApp().globalData.tempFile = tempFile;
      wx.navigateTo({
          url: '/disk/widget/selectFolder?jumpType=' + "uploadVideo",
      })
  },
  showCreateFolder: function () {
      wx.showToast({
          title: '请您进入文件目录创建文件夹！',
          icon: 'none'
      })
  }
})