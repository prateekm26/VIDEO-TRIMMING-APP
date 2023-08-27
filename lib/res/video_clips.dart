import 'dart:typed_data';

class VideoClip {
  final String title;
  final String fileName;
  int duration;
  final String baseDir;
  List<Uint8List> thumbnails = [];
  bool selected;

  VideoClip(
      this.title, this.fileName, this.duration, this.baseDir, this.thumbnails,
      {this.selected = false});

  String videoPath() {
    return "$baseDir$fileName";
  }

  static List<VideoClip> clips = [
    VideoClip("Summer", "song1.mp4", 29, "assets/videos/", []),
    VideoClip("Summer", "song2.mp4", 41, "assets/videos/", []),
    VideoClip("Summer", "song3.mp4", 31, "assets/videos/", []),
    VideoClip("Summer", "song4.mp4", 30, "assets/videos/", []),
    VideoClip("Summer", "song5.mp4", 30, "assets/videos/", [])
  ];
}
