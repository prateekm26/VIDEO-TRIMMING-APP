import 'package:flutter/material.dart';
import 'package:videotask/providers/home_provider.dart';

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
}
