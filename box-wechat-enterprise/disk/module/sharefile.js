var config = require("../config.js");
var httpclient = require("httpclient.js");
var utils = require("utils.js");
var musicServicce = require("music.js");

var obj = {
  host: config.host,
  endpoint: {
    // 获取最新浏览的文件
    listLastReadFile: config.host + '/wxwork/folders/',
    // 获取我分享出去的文件以及文件夹
    listMySharetTo: config.host + '/wxwork/myShares/list',
    // 获取外链信息
    getLinkInfo: config.host + '/ufm/api/v2/links/node',
  },
};
const HOST = config.hostname;
console.log("HOST", HOST)
// 点赞 / test / 为某条信息进行点赞
function comments(params, callback) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  params = params || {}
  return httpclient.post(HOST + '/praise/v1/test', params, header, callback);
};
//点赞 / 取消点赞
function removeprise(options) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  // /prise/v1/{id}?user_id={user_id}
  return httpclient.remove(HOST + '/praise/v1/' + options.id + "?user_id=" + options.user_id, null, header, options.callback);
}
// 点赞 / 判断当前用户是否对指定文件点赞


// 点赞 / 获取某个信息所获得的点赞数
function countpraise(target_id, target_type, callback) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  return httpclient.get(HOST + '/praise/v1/' + target_id + "/amount?type=" + target_type, null, header, callback);
}

// 点赞 / 判断当前用户是否对指定文件点赞
function ispraise(userid, target_id, target_type, callback) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  // /praise/v1/users/{userid}/praised/{target_id}?type={target_type}
  return httpclient.get(HOST + '/praise/v1/users/' + userid + "/praised/" + target_id + "?type=" + target_type, null, header, callback);
}
// 点赞 / 获取某个信息所获得的点赞人员列表
function praiselist(target_id, target_type, cursor, maxcount, callback) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  return httpclient.get(HOST + '/praise/v1/' + target_id + "/praiser?type=" + target_type + "&cursor=" + cursor + "&maxcount=" + maxcount, null, header, callback);
}
function comments_count(target_id, target_type, callback) {
  // 评论 / 获取某个信息所获得的评论数
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  // /comments/v1/{target_id}/amount?type={target_type}
  return httpclient.get(HOST + '/comments/v1/' + target_id + "/amount?type=" + target_type, null, header, callback);
}
function comments_lists(options) {
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  // /comments/v1/{target_id}/comment?type={target_type}&cursor={cursor}&maxcount={maxcount}
  return httpclient.get(HOST + '/comments/v1/' + options.target_id + "/comment?type=" + options.target_type + "&cursor=" + options.cursor + "&maxcount=" + options.maxcount, null, header, options.callback);

}
function comments_msg(options) {
  // /comments/v1/test 评论 / test/对某个信息进行评论
  var header = {
    Authorization: getApp().globalData.token,
    'content-type': 'application/json'
  }
  options.data = options.data || {}
  return httpclient.post(HOST + '/comments/v1/test', options.data, header, options.callback);
}
module.exports = {
  comments,
  countpraise,
  ispraise,
  praiselist,
  comments_count,
  comments_lists,
  comments_msg,
  removeprise

}