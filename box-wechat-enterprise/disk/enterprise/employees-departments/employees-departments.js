var enterpriseClient = require("../../module/enterprise.js");
var config = require("../../config.js");

var deptName = "";
var currentDeptId = 0;
var deptName = "";


Page({

    /**
     * 页面的初始数据
     */
    data: {
        datas: [{
            icon: "/disk/images/department-avatar.png",
            name: "成都分公司",
            departmentCount: 20,
            employeeCount: 120,
            showPopup: false,//添加部门弹窗控制参数 
            showLeftPopup: false, 
            showRightPopup: false,
            showTopPopup: false,
            showBottomPopup: false
        }],

    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        var page = this;

        currentDeptId = options.parentId;
        deptName = options.deptName;
        if (currentDeptId == undefined){
            currentDeptId = 0;
            deptName = getApp().globalData.enterpriseName;
        }
        page.setData({
            currentDeptId: currentDeptId
        });
        var deptCrumbs = [];
        if (currentDeptId == 0){
            var crumb = {"parentId": 0, "name": getApp().globalData.enterpriseName}
            deptCrumbs.push(crumb);
            getApp().globalData.deptCrumbs = deptCrumbs;
        }else{
            deptCrumbs = getApp().globalData.deptCrumbs;
            var crumb = { "parentId": currentDeptId, "name": deptName };
            deptCrumbs.push(crumb);
            getApp().globalData.deptCrumbs = deptCrumbs;
        }
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
        var page = this;
        wx.setNavigationBarTitle({
            title: deptName
        });
        getDeptAndEmployees(currentDeptId, page);
    },

    //新增部门弹窗
    togglePopup() {
        this.setData({
            showPopup: !this.data.showPopup
        });
    },
    onUnload: function(e){
        var page = this;
        var deptCrumbs = getApp().globalData.deptCrumbs;
        if (deptCrumbs != undefined && deptCrumbs.length > 1){
            deptCrumbs.splice(deptCrumbs.length - 1, 1);
            getApp().globalData.deptCrumbs = deptCrumbs;
            currentDeptId = deptCrumbs[deptCrumbs.length - 1].parentId;
            deptName = deptCrumbs[deptCrumbs.length - 1].name;
            page.setData({
                currentDeptId: currentDeptId
            });
        }
    },
    //恢复左滑
    scrollToLeft: function (e) {
        var page = this;
        var scollId = e.currentTarget.dataset.id;
        var item = e.currentTarget.dataset.item;
    },

    setModalStatus: function (e) {
        console.log("设置显示状态，1显示0不显示", e.currentTarget.dataset.status);
        var page = this;
        var department = e.currentTarget.dataset.department;
        if (department != undefined){
            page.setData({
                department: department
            });
        }

        var animation = wx.createAnimation({
            duration: 200,
            timingFunction: "linear",
            delay: 0
        })
        this.animation = animation
        animation.translateY(300).step()
        this.setData({
            animationData: animation.export()
        })
        if (e.currentTarget.dataset.status == 1) {
            this.setData({
                showModalStatus: true
            });
        }
        setTimeout(function () {
            animation.translateY(0).step()
            this.setData({
                animationData: animation
            })
            if (e.currentTarget.dataset.status == 0) {
                this.setData({
                    showModalStatus: false
                });
            }
        }.bind(this), 200)
    },
    inputChange: function (e) {
        deptName = e.detail.value;
    },
    onCreateFolderCancel: function () {
        deptName = "";
        this.setData({
            deptName: "",
            showPopup: false
        })
    },
    onCreateFolderConfirm: function () {
        var page = this;
        deptName = deptName.trim();
        if (deptName == "") {
            wx.showToast({
                title: '部门名称不能为空',
                icon: 'none'
            })
            return;
        }

        var regEn = /[\/:*"?<>|\\]/im;
        for (var i = 0; i < deptName.length; i++) {
            var deptNameChar = deptName.charAt(i);
            if (regEn.test(deptNameChar)) {
                wx.showToast({
                    title: '部门名称不能包含特殊符号',
                    icon: 'none'
                });
                return;
            }
        }
        var data = {
            parentId: currentDeptId,
            name: deptName
        };
        enterpriseClient.createDept(data, function () {
            page.onCreateFolderCancel();
            getDeptAndEmployees(data.parentId, page);
        });
    },
    onClickDept: function(e){
        var page = this;
        var deptInfo = e.currentTarget.dataset.deptInfo;
        wx.navigateTo({
            url: '/disk/enterprise/employees-departments/employees-departments?parentId=' + deptInfo.userId + "&deptName=" + deptInfo.name
        });
    },
    onClickDeptMore: function(e){
        var page = this;
        page.setData({

        });
    },
    onDeleteDeptOrEmploye: function(e){
        var page = this;
        var item = e.currentTarget.dataset.item;
        var deptOrEmploy = item.type == 'department' ? '部门 ' : '员工 ';
        wx.showModal({
            cancelText: "取消",
            confirmText: "确认",
            title: '提示',
            content: '确认将' + deptOrEmploy + item.name + ' 从企业中删除吗？',
            success: function (res) {
                if (res.confirm) {
                    if (item.type == "department") {
                        var deptId = item.userId;
                        enterpriseClient.deleteDept(deptId, function(){
                            wx.showToast({
                                title: '删除部门成功！',
                                duration:1000
                            });
                            page.onShow();
                        });
                    } else {
                        var userId = item.userId;
                        enterpriseClient.deleteEmploy(userId, function(){
                            wx.showToast({
                                title: '删除员工成功！',
                                duration: 1000
                            });
                            page.onShow();
                        });
                    }
                    
                } else if (res.cancel) {
                    page.setData({
                        scrollLeft: 0
                    })
                }
            }
        })
    },
    onSetDocumentAudit: function(e){
        var deptId = e.currentTarget.dataset.deptId;
        var approve = e.currentTarget.dataset.approve;
        if (deptId == undefined || approve == undefined || typeof(approve) != "boolean"){
            wx.showToast({
                title: '设置失败！',
                icon: 'none',
                duration: 1000
            });
            return;
        }
        if (approve){
            approve = false;
        }else{
            approve = true;
        }
        enterpriseClient.setDocumentAudit(deptId, approve, function(){
            wx.showToast({
                title: '设置成功！'
            });
        });
    },
    onClickSetDeptManager: function(e){
        var deptId = e.currentTarget.dataset.deptId;
        if(deptId == undefined){
            wx.showToast({
                title: '获取部门ID失败！',
                icon: 'none',
                duration: 1000
            });
            return;
        }
        wx.navigateTo({
            url: '/disk/enterprise/employees-departments/department/manager?deptId=' + deptId
        });
    },
    onClickSetDeptKnowledgerManager: function (e) {
        var deptId =  e.currentTarget.dataset.deptId;
        if (deptId == undefined) {
            wx.showToast({
                title: '获取部门ID失败！',
                icon: 'none',
                duration: 1000
            });
            return;
        }
        wx.navigateTo({
            url: '/disk/enterprise/employees-departments/department/knowledger?deptId=' + deptId
        });
    },
    onClickMoveEmploye: function(e){
        var employeId = e.currentTarget.dataset.employeId;
        wx.navigateTo({
            url: "/disk/enterprise/template/selectEmploye?employeId=" + employeId
        });
    }
})

//刷新页面数据
function getDeptAndEmployees(parentId, page){
    var depts = [];
    var employees = [];
    enterpriseClient.getDeptAndEmployees(parentId, function (data) {
        for (var i = 0; i < data.length; i++) {
            if (data[i].type == 'department') {
                data[i].icon = "/disk/images/department-avatar.png";
                depts.push(data[i]);
            } else {
                data[i].icon = config.host + "/ecm/api/v2/users/getAuthUserImage/" + data[i].id + "?authorization=" + getApp().globalData.token;
                employees.push(data[i]);
            }
        }
        page.setData({
            depts: depts,
            employees: employees
        });
    });
}