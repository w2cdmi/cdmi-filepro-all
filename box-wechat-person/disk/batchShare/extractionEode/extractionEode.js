// disk/batchShare/extractionEode/extractionEode.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
        errorTip:true
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        this.setData({
            params: options
        })
    },
    //当输入框有输入动作
    inputChange: function (e) {
        var code = e.detail.value;
        if (code.length >= 6) {
            this.setData({
                inputCode: code
            })
        }
    },
    //点击提取按钮
    takeResources: function () {
        var params = this.data.params;
        var datas = this.data;
        if (datas.inputCode != params.plainAccessCode) {
            this.setData({
                errorTip:false
            });
        } else {
            wx.redirectTo({
                url: '/disk/shares/sharefile?forwardId=' + params.forWardId + "&linkCode=" + params.linkCode,
            })
        }
    }
})

function getPageInfo() {
    prototype
    var page = new Page();
};