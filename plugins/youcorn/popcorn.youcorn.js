(function(global) {
  var undef;

  global.Youcorn = function(video) {
    this.video = video;
    this.readyState = 4;
    this.duration = this.video.getDuration();
    this.eventListeners = {};
    this.timeUpdater = null;
    this.currentTime = 0;
  };

  Youcorn.p = global.Youcorn.prototype = Youcorn.prototype;

  Youcorn.p.play = function() {
    this.video.playVideo();
    startTimeUpdater(this);
  };

  Youcorn.p.load = function() {
    // nothing is done for now
  };

  Youcorn.p.pause = function() {
    this.video.pauseVideo();
    stopTimeUpdater(this);
  };

  Youcorn.p.mute = function() {
    this.video.mute();
  };

  Youcorn.p.volume = function(vol) {
    if (vol == undef) {
      return this.video.getVolume();
    }
    this.video.setVolume(vol);
  };

  Youcorn.p.addEventListener = function(eventName, func) {
    if (!this.eventListeners[eventName]) {
      this.eventListeners[eventName] = [];
    }
    this.eventListeners[eventName].push(func);
  };

  function updateTime(youcorn) {
    youcorn.currentTime = youcorn.video.getCurrentTime();
    if (!youcorn.eventListeners['timeupdate']) {
      return;
    }
    for (var i in youcorn.eventListeners['timeupdate']) {
      youcorn.eventListeners['timeupdate'][i].call(youcorn, null);
    }
  }

  function startTimeUpdater(youcorn) {
    youcorn.timeUpdater = setInterval(function() {
      updateTime(youcorn);
    }, 20);
  }

  function stopTimeUpdater(youcorn) {
    clearInterval(youcorn.timeUpdater);
  }

})(window);
