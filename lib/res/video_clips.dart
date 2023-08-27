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
    VideoClip("Song1", "song1.mp4", 29, "assets/videos/", []),
    VideoClip("Song2", "song2.mp4", 41, "assets/videos/", []),
    VideoClip("Song3", "song3.mp4", 31, "assets/videos/", []),
    VideoClip("Song4", "song4.mp4", 30, "assets/videos/", []),
    VideoClip("Song5", "song5.mp4", 30, "assets/videos/", [])
  ];
}
