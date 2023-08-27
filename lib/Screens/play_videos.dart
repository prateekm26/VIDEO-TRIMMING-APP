import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:videotask/Screens/video_frames.dart';
import 'package:videotask/providers/video_player_provider.dart';
import 'package:videotask/res/colors.dart';
import 'package:videotask/res/video_clips.dart';

class PlayVideos extends StatefulWidget {
  final List<VideoClip>? playList;
  const PlayVideos({Key? key, this.playList}) : super(key: key);

  @override
  State<PlayVideos> createState() => _PlayVideosState();
}

class _PlayVideosState extends State<PlayVideos> {
  List<VideoClip> playList = [];
  VideoPlayerProvider? _playerProvider;
  VideoPlayerController? _controller;
  var _playingIndex = -1;
  var _disposed = false;
  var _isEndOfClip = false;
  var _updateProgressInterval = 0.0;
  Duration? _duration;
  Duration? _position;
  double _globalPosition = 0.0;

  @override
  void dispose() {
    _disposed = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _playerProvider = Provider.of<VideoPlayerProvider>(context, listen: false);
    if (widget.playList != null) {
      playList = widget.playList!;
    }
    _playerProvider!.rangeValues = RangeValues(0, getMaxDuration());
    _initPlayer(0);
  }

  void _initPlayer(int index, {bool seek = false}) async {
    print("_initializeAndPlay ---------> $index");
    final clip = playList[index];
    final controller = VideoPlayerController.asset(clip.videoPath());
    final old = _controller;
    _controller = controller;
    if (old != null) {
      old.removeListener(_onControllerUpdated);
      old.pause();
      debugPrint("---- old contoller paused.");
    }
    debugPrint("---- controller changed.");
    _playerProvider!.refreshState();
    controller.initialize().then((_) {
      debugPrint("---- controller initialized");
      old?.dispose();
      _playingIndex = index;
      _duration = null;
      _position = null;
      controller.addListener(_onControllerUpdated);
      if (seek) {
        /*getPositionOnSeek() == 0
            ? _initPlayer(_playingIndex + 1)
            :*/
        controller.seekTo(Duration(seconds: getPositionOnSeek()));
      }
      controller.play();
      _playerProvider!.refreshState();
    });
  }

  void _onControllerUpdated() async {
    if (_disposed) return;
    // blocking too many updation
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 500.0;

    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;
    _duration ??= _controller!.value.duration;
    var duration = _duration;
    if (duration == null) return;
    var position = await controller.position;
    _position = position!;
    print("position: $_position");
    final playing = controller.value.isPlaying;
    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inSeconds + 1 >= duration.inSeconds;
    if (isEndOfClip) {
      // update global position
      _globalPosition = _progress /*_globalPosition + _position!.inSeconds*/;
    }
    if (playing) {
      // handle progress indicator
      if (_disposed) return;
      print(
          "progress### $_progress , end-- ${_playerProvider!.rangeValues.end}");

      if (_progress >= _playerProvider!.rangeValues.end) {
        controller.pause();
      }
    }
    _playerProvider!.refreshState();
    // handle clip end
    if (_playerProvider!.isPlaying != playing || _isEndOfClip != isEndOfClip) {
      _playerProvider!.isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndOfClip=$isEndOfClip");
      if (isEndOfClip && playing) {
        /// one clip completed handle next clip
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == playList.length - 1;
        if (isComplete) {
          print("played all!!");
        } else {
          print("playNext");
          _initPlayer(_playingIndex + 1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _playerProvider = Provider.of<VideoPlayerProvider>(context);
    return _mainWidget();
  }

  Widget _mainWidget() {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _videoPreview(),
            _durationText(),
            progressBar(),
            frameRangeSlider()
          ],
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.black87,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        icon: const Icon(Icons.close),
      ),
      title: const Text("Adjust Clip"),
    );
  }

  _videoPreview() {
    return Container(
      height: MediaQuery.of(context).size.height - 180,
      // width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: _videoPlayer(),
    );
  }

  Widget _videoPlayer() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: AspectRatio(
          //aspectRatio: controller.value.aspectRatio,
          aspectRatio: 9 / 16,
          child: GestureDetector(
            onTap: _onTapVideo,
            child: VideoPlayer(controller),
          ),
        ),
      );
    } else {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.orange,
        )),
      );
    }
  }

  /// play/pause video
  void _onTapVideo() {
    if (_playerProvider!.isPlaying) {
      _controller?.pause();
      _playerProvider!.isPlaying = false;
    } else {
      _controller?.play();
      _playerProvider!.isPlaying = true;
    }
  }

  _durationText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "${(_playerProvider!.rangeValues.end - _playerProvider!.rangeValues.start).round()}s",
            style: TextStyle(color: AppColors.whiteColor),
          ),
        ],
      ),
    );
  }

// progress bar widget
  Widget progressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: LinearProgressIndicator(
        value: _position == null
            ? 0.0
            : (_progress * 1000000) / (1000000 * getMaxDuration()),
        minHeight: 3,
        backgroundColor: Colors.transparent,
        color: Colors.orange,
      ),
    );
  }

// frame slider and thumbnails
  Widget frameRangeSlider() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: VideoFrames(playList: playList),
        ),
        SliderTheme(
          data: SliderThemeData(
              minThumbSeparation: 0,
              thumbColor: AppColors.orangeColor,
              trackHeight: 60,
              inactiveTrackColor: Colors.transparent,
              activeTrackColor: AppColors.orangeColor.withOpacity(0.25)),
          child: RangeSlider(
            min: 0,
            max: getMaxDuration(),
            values: _playerProvider!.rangeValues,
            onChanged: (values) {
              if (values.end - values.start >= 5) {
                _playerProvider!.rangeValues = values;
              }
            },
            onChangeStart: (startVal) {
              _controller?.pause();
              _position = Duration(seconds: 0);
              _globalPosition = 0.0;
            },
            onChangeEnd: (endVal) {
              _initPlayer(getPlayIndexOnSeek(), seek: true);
            },
          ),
        ),
      ],
    );
  }

  /// returns total duration of playlist
  double getMaxDuration() {
    double duration = 0.0;
    for (int i = 0; i < playList.length; i++) {
      duration += playList[i].duration;
    }
    return duration;
  }

  /// returns combined video progress in sec
  double get _progress => _globalPosition + _position!.inSeconds;

  /// returns video index at particular duration
  int getPlayIndexOnSeek() {
    int index = 0;
    double progress = _playerProvider!.rangeValues.start;
    List<int> durationList = [];
    int totalDuration = 0;
    for (int i = 0; i < playList.length; i++) {
      totalDuration += playList[i].duration;
      durationList.add(totalDuration);
    }
    for (int i = 0; i < durationList.length; i++) {
      if (durationList[i] >= progress) {
        print("index ##### $i");
        return i;
      }
    }
    return index;
  }

  /// returns video position on seek
  int getPositionOnSeek() {
    int pos = 0;
    int index = getPlayIndexOnSeek();
    double progress = _playerProvider!.rangeValues.start;
    List<int> durationList = [];
    int totalDuration = 0;
    for (int i = 0; i < playList.length; i++) {
      totalDuration += playList[i].duration;
      durationList.add(totalDuration);
    }
    pos =
        index == 0 ? progress.round() : durationList[index] - progress.round();
    print("pos ##### $pos");
    return pos;
  }
}