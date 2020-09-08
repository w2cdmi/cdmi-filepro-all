var config = require("../config.js");

function getRobotStatus(data, callback) {
    var header = {
        Authorization: getApp().globalData.token,
    };

    wx.request({
        url: config.host + "/ecm/api/v2/wx/robot/checkRobotStatus",
        method: 'GET',
        header: {
            'content-type': 'application/json',
            'Authorization': getApp().globalData.token
        },
        success: function (data) {
            if (typeof (callback) == 'function'){
                callback(data);
            }
        },
        fail: function (res) {
            console.log("get robot state fail");
        }
    });
}

function openRobotCheck(){
    if(!getApp().globalData.isOpenRobotCheck){
        //循环获取机器人状态
        setInterval(function () {
            getRobotStatus({}, function (data) {
                if (data.data) {
                    getApp().globalData.isOpenRobot = true;
                } else {
                    getApp().globalData.isOpenRobot = false;
                }
            });
        }, 30000);
        getApp().globalData.isOpenRobotCheck = true;
    }
}

module.exports = {
    openRobotCheck,
};