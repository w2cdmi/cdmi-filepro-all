/**
 * 小程序配置文件
 */

// 此处主机域名修改成腾讯云解决方案分配的域名
// var host = 'https://www.jmapi.cn';
var hostname = "https://www.jmapi.cn/msm";
// var appId = "StorBox";
// var host = 'https://www.storbox.cn';
// var appId = "StorBox";
var host = 'https://www.filepro.cn';
var appId = "FilePro";
var IMAppkey = '1142bd9f252d48459d0f014f6a4789ce';
var storageIMSessionsName = "IMSessions";
var storageIMMessageName = "IMMessage";
var storageAvatarUrlsName = "IMAvatarUrls";
var storageObjectNicksName = "IMObjectNicks";
var teamAvatarUrl = '../images/icon/message-active.png';
var sessionTopsKey = 'sessionTops';
var defaultPageSize = 20;
var defaultOrderStyle = "time";
var defaultOrderSort = "desc";
var mon6Rebate = 0.9;       //6个月会员优惠
var mon12Rebate = 0.8;      //12个月优惠

var config = {
  // 下面的地址配合云端工作
  service: {
    host,
    // 登录地址，用于建立会话
    loginUrl: '${host}/weapp/login',
    // 测试的请求地址，用于测试会话
    requestUrl: '${host}/weapp/user',
    // 测试的信道服务地址
    tunnelUrl: '${host}/weapp/tunnel',
    // 上传图片接口
    uploadUrl: '${host}/weapp/upload'
  }
};

// 当超过本地存储存储限制时，清除早期的信息,从90%清除到50%
function checkLocalStorage() {
  wx.getStorageInfo({
    success: function (res) {
      console.log(res.keys)
      if (res.currentSize > res.limitSize * 0.9) {
        //开始循环清除数据
        var done = false;
        var i = 1; //循环删除的次数
        do {
          done = clearStorage(keys, i, 3600); //删除的最小间隔时长为1小时
          i++;
        } while (done);
      }
    }
  })
}

// 内部方法，循环清除本地缓存数据
function clearStorage(keys, cycle_times, min_interval) {
  var interval = 3600 * 24 * 60;
  if (cycle_times == 2) {
    interval = 3600 * 24 * 30;
  } else if (cycle_times == 3) {
    interval = 3600 * 24 * 7;
  } else if (cycle_times == 4) {
    interval = 3600 * 24;
  } else if (cycle_times == 5) {
    interval = 3600 * 12;
  } else if (cycle_times == 6) {
    interval = 3600 * 8;
  } else if (cycle_times == 7) {
    interval = 3600 * 4;
  } else if (cycle_times == 8) {
    interval = 3600 * 2;
  } else if (cycle_times > 8) {
    interval = 3600;
  } else {
    wx.showToast({
      title: '清除缓存失败,请等待一个小时后再进行尝试',
      icon: 'fail',
      duration: 3000
    });
    return true;//终止清除
  }
  for (var i = 0; i < keys.length; i++) {
    wx.getStorage({
      key: keys[i],
      success: function (list) {
        var json = list.data;
        if (json.lastUpdateTime > new Date() + interval) {
          wx.removeStorage({
            key: key,
            success: function (res) {
            },
          })
        }
      }
    })
  }
  // 检查删除后的空间是否达标
  wx.getStorageInfo({
    success: function (res) {
      if (res.currentSize < res.limitSize * 0.5) {
        return true;
      }
    },
    fail: function (res) {
      wx.showToast({
        title: '清除缓存失败',
        icon: 'fail',
        duration: 3000
      });
      return true;//终止清除
    }
  })
}


module.exports = {
  hostname,
  host,
  appId,
  IMAppkey,
  storageIMSessionsName,
  storageIMMessageName,
  storageAvatarUrlsName,
  storageObjectNicksName,
  sessionTopsKey,
  mon6Rebate,
  mon12Rebate
};
