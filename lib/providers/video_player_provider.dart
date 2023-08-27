import 'package:flutter/material.dart';
import 'package:videotask/providers/home_provider.dart';
import 'package:videotask/res/video_clips.dart';

class VideoPlayerProvider extends HomeProvider {
  RangeValues _rangeValues = const RangeValues(0, 0);
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  RangeValues get rangeValues => _rangeValues;

  set rangeValues(RangeValues value) {
    _rangeValues = value;
    notifyListeners();
  }

  void refreshState() {
    notifyListeners();
  }

  /// set thumbnails in playlist
  Future<void> setThumbnails(List<VideoClip> clips, {int count = 10}) async {
    loading = true;
    notifyListeners();
    for (int i = 0; i < clips.length; i++) {
      /*  if (clips[i].thumbnails.length > 1) {
        continue;
      }*/
      //clips[i].thumbnails.clear();
      for (int j = 0; j < count; j++) {
        final byte = await generateThumbnails(
            videoPath: clips[i].videoPath(), timeMs: 100000000 * (j + 10));
        clips[i].thumbnails[j] = byte!;
      }
    }
    loading = false;
    notifyListeners();
  }
}
