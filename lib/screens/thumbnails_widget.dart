import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videotask/res/video_clips.dart';

class VideoThumbnailsWidget extends StatefulWidget {
  final List<VideoClip>? playList;

  const VideoThumbnailsWidget({Key? key, this.playList}) : super(key: key);

  @override
  State<VideoThumbnailsWidget> createState() => _VideoThumbnailsWidgetState();
}

class _VideoThumbnailsWidgetState extends State<VideoThumbnailsWidget> {
  List<VideoClip> playList = [];
  List<Uint8List> thumbnails = [];
  @override
  void initState() {
    super.initState();
    if (widget.playList != null) {
      playList = widget.playList!;
    }
    _initThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    return _mainWidget();
  }

  Widget _mainWidget() {
    return SizedBox(
      height: 60,
      child: Row(
          children: List.generate(
              10, (index) => Expanded(child: thumbnailItem(index)))),
    );
  }

  Widget thumbnailItem(int index) {
    return SizedBox(
        height: 60,
        child: Image.memory(
          thumbnails[index],
          fit: BoxFit.fitHeight,
        ));
  }

  void _initThumbnail() {
    int playListLength = playList.length;
    if (playListLength == 1) {
      thumbnails = playList.first.thumbnails;
    } else if (playListLength == 2) {
      for (int i = 0; i < 5; i++) {
        thumbnails.add(playList.first.thumbnails[i]);
      }
      for (int i = 0; i < 5; i++) {
        thumbnails.add(playList[1].thumbnails[i]);
      }
    } else if (playListLength == 3) {
      for (int i = 0; i < 3; i++) {
        thumbnails.add(playList.first.thumbnails[i]);
      }
      for (int i = 0; i < 3; i++) {
        thumbnails.add(playList[1].thumbnails[i]);
      }
      for (int i = 0; i < 4; i++) {
        thumbnails.add(playList[2].thumbnails[i]);
      }
    } else {
      for (int i = 0; i < 2; i++) {
        thumbnails.add(playList.first.thumbnails[i]);
      }
      for (int i = 0; i < 3; i++) {
        thumbnails.add(playList[1].thumbnails[i]);
      }
      for (int i = 0; i < 2; i++) {
        thumbnails.add(playList[2].thumbnails[i]);
      }
      for (int i = 0; i < 3; i++) {
        thumbnails.add(playList[3].thumbnails[i]);
      }
    }
  }
}
