// PLUGIN: YOUTUBE

(function (Popcorn) {

  var undef;

  /**
   * Youtube popcorn plug-in
   * Unlike other plug-ins, this plug-in adds capability for Popcorn.js to deal
   * with Youtube videos. This plug-in also doesn't use Popcorn's plugin() API
   * and instead hacks directly into Popcorn's core.
   *
   * To use this plug-in, onYouTubePlayerReady() event handler needs to be
   * called by the Youtube video player, before videos can be registered. Once
   * videos are registered, calls to them can be made the same way as regular
   * Popcorn objects. Also note that enablejsapi=1 needs to be added to the
   * embed code, in order for Youtube's JavaScript API to work.
   */  

  var YOUTUBE_URL_PATTERN = /^http:\/\/www\.youtube\.com\//;

  /**
   * Overrides Popcorn's constructor with Youtube-related setup.
   */
  var oldInit = Popcorn.p.init;
  Popcorn.p.init = function(entity) {
    var popcorn = new oldInit(entity);
    
    // Detect popcorn video.
    popcorn.data.youtube = false;
    if (popcorn.video && isYoutubeVideo(popcorn.video)) {
      popcorn.data.youtube = true;
    }

    function isYoutubeVideo(element) {
      if (!(element instanceof HTMLObjectElement)) {
        return false;
      }
      var params = element.getElementsByTagName('param');
      for (var i in params) {
        if (!params[i].attributes) {
          continue;
        }
        var name = params[i].attributes.getNamedItem('name');
        if (name && name.value == 'movie') {
          var value = params[i].attributes.getNamedItem('value');
          if (value && value.value.match(YOUTUBE_URL_PATTERN)) {
            return true;
          }
          return false;
        }
      }
      return false;
    }
    
    // Add additional data fields.
    popcorn.data.youtubeStatusUpdater = null;

    return popcorn;
  };
  
  /**
   * Poll Youtube video's current status.
   */
  function updateStatus(popcorn) {
    // Fire timeupdate events.
    if (popcorn.data.events['timeupdate']) {
      for (var key in popcorn.data.events['timeupdate']) {
        var func = popcorn.data.events['timeupdate'][key];
        func.call(popcorn, null);
      }
    }
  }

  function startStatusUpdater(popcorn) {
    popcorn.data.youtubeStatusUpdater = setInterval(function(){
      updateStatus(popcorn);
    }, 1);
  }
  
  function stopStatusUpdater(popcorn) {
    clearInterval(popcorn.data.youtubeStatusUpdater);
  }

  /**
   * Play this video.
   */
  var oldPlay = Popcorn.p.play;
  Popcorn.p.play = function() {
    if (!this.data.youtube) {
      return oldPlay();
    }
    this.video.playVideo();
    startStatusUpdater(this);
    return this;
  };

  /**
   * Load this video.
   */
  var oldLoad = Popcorn.p.load;
  Popcorn.p.load = function() {
    if (!this.data.youtube) {
      return oldLoad();
    }

    // not sure if there is a Youtube equivalent...
    // nothing is done for now
    return this;
  };

  /**
   * Pause this video.
   */
  var oldPause = Popcorn.p.pause;
  Popcorn.p.pause = function() {
    if (!this.data.youtube) {
      return oldPause();
    }

    this.video.pauseVideo();
    stopStatusUpdater(this);
    return this;
  };

  /**
   * Mute this video.
   */
  var oldMute = Popcorn.p.mute;
  Popcorn.p.mute = function() {
    if (!this.data.youtube) {
      return oldMute();
    }

    this.video.mute();
    return this;
  };

  /**
   * Gets or sets the volume. Takes an integer from 0 to 100.
   */
  var oldVolume = Popcorn.p.volume;
  Popcorn.p.volume = function(vol) {
    if (!this.data.youtube) {
      return oldVolume(vol);
    }
    if (vol == undef) {
      return this.video.getVolume();
    }
    this.video.setVolume(vol);
    return this;
  };

  /**
   * Gets the duration.
   */
  var oldDuration = Popcorn.p.duration;
  Popcorn.p.duration = function() {
    if (!this.data.youtube) {
      return oldDuration();
    }

    return this.video.getDuration();
  };

  /**
   * Gets or sets the current time. Time is in seconds.
   */
  var oldCurrentTime = Popcorn.p.currentTime;
  Popcorn.p.currentTime = function(time) {
    if (!this.data.youtube) {
      return oldCurrentTime(time);
    }
    if (time == undef) {
      return this.video.getCurrentTime();
    }
    this.video.seekTo(time, true);
    return this;
  };
})(Popcorn);
