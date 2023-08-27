import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:videotask/res/video_clips.dart';

class HomeProvider extends ChangeNotifier {
  final List<VideoClip> _playList = [];
  bool _loading = false;
  //add video in play list
  void addToPlayList(VideoClip videoClip) {
    if (_playList.length < 4) {
      videoClip.selected = true;
      _playList.add(videoClip);
    }
    notifyListeners();
  }

  //remove video from play list
  void removeFromPlayList(VideoClip videoClip) {
    _playList.remove(videoClip);
    videoClip.selected = false;
    notifyListeners();
  }

  void clearPlayList() {
    _playList.clear();
    for (int i = 0; i < VideoClip.clips.length; i++) {
      VideoClip.clips[i].selected = false;
    }
    notifyListeners();
  }

  /// set thumbnails in playlist
  Future<void> setInitThumbnails(List<VideoClip> clips,
      {int count = 10}) async {
    _loading = true;
    notifyListeners();
    for (int i = 0; i < clips.length; i++) {
      final byte = await generateThumbnails(
          videoPath: clips[i].videoPath(), timeMs: 100000000 * (i + 10));
      for (int j = 0; j < 10; j++) {
        clips[i].thumbnails.add(byte!);
      }
    }
    _loading = false;
    notifyListeners();
  }

  /// generates thumbnails
  Future<Uint8List?> generateThumbnails(
      {required String videoPath, int timeMs = 1000}) async {
    final byteData = await rootBundle.load(videoPath);
    Directory tempDir = await getTemporaryDirectory();

    File tempVideo = File("${tempDir.path}$videoPath")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final result = await VideoThumbnail.thumbnailData(
        video: tempVideo.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 150,
        quality: 25,
        timeMs: timeMs);

    //log("result----$result");
    return result;
  }

  List<VideoClip> get playList => _playList;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
