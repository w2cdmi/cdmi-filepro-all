var isAutoCloseMusic = false;

Page({
    data: {
        path: '',    //视频播放路径
    },
    onLoad: function (options) {
        var page = this;
        var res = wx.getSystemInfoSync();
        var isCache = false;
        if (res.platform == 'ios') {
            isCache = true;
        }
        page.setData({
            isCache: isCache
        });

        isAutoCloseMusic = false;
        if (getApp().globalData.innerAudioContext != undefined && getApp().globalData.innerAudioContext != ''){
            var innerAudioContext = getApp().globalData.innerAudioContext;
            var isStop = innerAudioContext.paused;
            if (!isStop){
                isAutoCloseMusic = true;
                innerAudioContext.pause();
            }
        }

        var path = options.path;

        page.setData({
            path: path,
            directionSize: 0
        });

        var videoContext = wx.createVideoContext('video');
        videoContext.requestFullScreen();

        setDirection(videoContext, page);
    },
    onReady: function (res) {
    },
    inputValue: '',
    bindInputBlur: function (e) {
        this.inputValue = e.detail.value
    },
    bindSendDanmu: function () {
        this.videoContext.sendDanmu({
            text: this.inputValue,
            color: getRandomColor()
        })
    },
    onHide: function () {
        
    },
    onUnload: function(){
        if (isAutoCloseMusic) {
            var innerAudioContext = getApp().globalData.innerAudioContext;
            innerAudioContext.play();
        }
    }
})

function getRandomColor() {
    let rgb = []
    for (let i = 0; i < 3; ++i) {
        let color = Math.floor(Math.random() * 256).toString(16)
        color = color.length == 1 ? '0' + color : color
        rgb.push(color)
    }
    return '#' + rgb.join('')
}

function setDirection(videoContext, page){
    // 0为竖屏，1为横屏
    let lastState = 0;
    let lastTime = Date.now();

    wx.startAccelerometer();

    wx.onAccelerometerChange((res) => {
        const now = Date.now();

        // 500ms检测一次
        if (now - lastTime < 500) {
            return;
        }
        lastTime = now;

        let nowState;

        // 57.3 = 180 / Math.PI
        const Roll = Math.atan2(-res.x, Math.sqrt(res.y * res.y + res.z * res.z)) * 57.3;
        const Pitch = Math.atan2(res.y, res.z) * 57.3;

        // 横屏状态
        if (Roll > 50) {
            if ((Pitch > -180 && Pitch < -60) || (Pitch > 130)) {
                nowState = 1;
            } else {
                nowState = lastState;
            }

        } else if ((Roll > 0 && Roll < 30) || (Roll < 0 && Roll > -30)) {
            let absPitch = Math.abs(Pitch);

            // 如果手机平躺，保持原状态不变，40容错率
            if ((absPitch > 140 || absPitch < 40)) {
                nowState = lastState;
            } else if (Pitch < 0) { /*收集竖向正立的情况*/
                nowState = 0;
            } else {
                nowState = lastState;
            }
        } else {
            nowState = lastState;
        }

        // 状态变化时，触发
        if (nowState !== lastState) {
            lastState = nowState;
            if (nowState === 0) {
                page.setData({
                    directionSize: 0
                })
            } else {
                page.setData({
                    directionSize: 90
                })
            }
            setTimeout(function () {
                videoContext.exitFullScreen();
                videoContext.requestFullScreen();
            }, 200);
        }
    });
}