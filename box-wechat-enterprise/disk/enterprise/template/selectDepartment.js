// disk/enterprise/template/selectDepartment.js
var employId = 0;
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
        employId = options.employId;
        this.setData({
            listHeight: wx.getSystemInfoSync().windowHeight - 200
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
    onCancelMoveEmploye: function(){

    },
    onConfirmMove: function(e){

    }
})