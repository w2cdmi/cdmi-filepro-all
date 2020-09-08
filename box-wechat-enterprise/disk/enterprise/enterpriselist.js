// disk/enterpriselist.js
var session = require("../../session.js");

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
        wx.setNavigationBarTitle({title: '选择账号'})
        var enterpriseList = getApp().globalData.enterpriseList;
        if (typeof (enterpriseList) != 'undefined' && enterpriseList.length == 0){
            wx.showModal({
                title: '提示',
                content: '登录服务器失败，请稍后重试！',
                showCancel: false
            });
            return;
        }
        
        var page = this;
        var enterpriseId = getApp().globalData.enterpriseId;
        setPageData(enterpriseList, enterpriseId, page);

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
        getApp().globalData.isJumpEenterpriseListPage = true;
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
     * 选择企业登录
     */
    enterpriseListClick: function (e) {
        var enterpriseId = e.currentTarget.dataset.enterprise.id;
        var page = this;
        var enterpriseList = getApp().globalData.enterpriseList;
        setPageData(enterpriseList, enterpriseId, page);

        wx.showModal({
            title: "提示",
            content: "你确定使用该账号登录吗?",
            success: function (msg) {
                if (msg.confirm) {
                    //不切换企业
                    if (enterpriseId == getApp().globalData.enterpriseId && getApp().globalData.token != ''){
                        wx.navigateBack({
                            delta: 1
                        });
                        return;
                    }
                    
                    initGlobalData();
                    wx.showLoading({
                        title: '登录中...',
                        mask: true
                    });
                    //携带参数登录
                    session.login({
                        enterpriseId: enterpriseId
                    });
                    //等待登录成功后，执行
                    session.invokeAfterLogin(function () {
                        wx.hideLoading();
                        wx.navigateBack({
                            delta: 1,
                        })
                    });
                }
            }
        })
    },
    addEnterprise: function(e){
        wx.navigateTo({
            url: '/disk/enterprise/registered/registered',
        })
    }
})

function setPageData(enterpriseList, enterpriseId, page){
    var tempEnterpriseList = [];
    for (var i = 0; i < enterpriseList.length; i++) {
        if(enterpriseList[i].id == 0){
            continue;
        }
        if (enterpriseList[i].id == enterpriseId) {
            enterpriseList[i].class = "pitchOn";
        } else {
            enterpriseList[i].class = "";
        }
        tempEnterpriseList.push(enterpriseList[i]);
    }
    page.setData({
        enterpriseList: tempEnterpriseList
    });
}

//注意：在登录前设置，不初始化企业列表。
function initGlobalData() {
    if (getApp().globalData.innerAudioContext != ''){
        var innerAudioContext = getApp().globalData.innerAudioContext;
        innerAudioContext.destroy();
    }
    var globalData = {
        token: '', //
        enterpriseId: 0, //当前企业ID
        enterpriseName: '',//当前登录的企业名称
        userId: '', //当前登录用户ID
        userName: '',   //用户名字
        acountType: '',  //账号类型
        cloudUserId: '', //当前登录用户的CloudUserId
        expire: 0, //会话到期时间
        refreshToken: '',//
        enterpriseList: getApp().globalData.enterpriseList, //多个企业时，选择列表
        IMAccount: '', //IM账号
        IMToken: '',  //im用户token
        avatarUrl: '',   //微信头像
        imgUrls: [],   //目录下图片数组
        musicList: '',   //音乐列表
        musicIndex: -1,   //当前音乐播放索引
        innerAudioContext: '',  //音乐播放器对象
        isShowMusicPanel: false,  //是否显示音乐播放器
        indexParam: getApp().globalData.indexParam,   // 1：最近浏览，2：我的分享，3：他人分享
        isOpenRobotCheck: getApp().globalData.isOpenRobotCheck, //  false：未启动巡检，true：已经启动巡检
        isOpenRobot: false,  //  false：未启动，true：已经启动
        isShowChatButton: false,   //是否显示聊天菜单按钮
        isJumpEenterpriseListPage: true,
        tempFiles: [],       //上传图片临时路径集合
        tempFile: {},        //上传视频临时路径
        crumbs: [],          //记录选择的面包屑
        isAdmin: false,         //是否为企业管理员
        deptCrumbs: [],     //部门面包屑
        systemName: '文件宝-'
    }
    
    getApp().globalData = globalData;
}