import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videotask/Screens/play_videos.dart';
import 'package:videotask/providers/home_provider.dart';
import 'package:videotask/res/colors.dart';
import 'package:videotask/res/video_clips.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeProvider? _homeProvider;
  @override
  Widget build(BuildContext context) {
    _homeProvider = Provider.of<HomeProvider>(context);
    return _mainWidget();
  }

  @override
  void initState() {
    super.initState();
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _init();
  }

  Widget _mainWidget() {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black87,
        title: const Text("Select Videos"),
      ),
      body: _homeProvider!.loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(
                    child: CircularProgressIndicator(
                  color: AppColors.orangeColor,
                )),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please wait..",
                  style: TextStyle(color: AppColors.orangeColor, fontSize: 18),
                )
              ],
            )
          : Column(
              children: [
                _videoGrid(),
              ],
            ),
      bottomNavigationBar: nextButton(),
    );
  }

  _videoGrid() {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: VideoClip.clips.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //childAspectRatio: 1.5,
                crossAxisCount: 3,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0),
            itemBuilder: (BuildContext context, int index) {
              return videoItem(VideoClip.clips[index]);
            },
          )),
    );
  }

  videoItem(VideoClip localClip) {
    return InkWell(
      onTap: () {
        if (localClip.selected) {
          // unselect video
          _homeProvider!.removeFromPlayList(localClip);
        } else {
          // select video
          _homeProvider!.addToPlayList(localClip);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orange, width: localClip.selected ? 3 : 0),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Image.memory(
          localClip.thumbnails.first,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
      child: GestureDetector(
        onTap: () => _handleNextButtonTap(),
        child: Container(
            height: 55,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: _homeProvider!.loading
                    ? AppColors.grey.withOpacity(0.5)
                    : AppColors.orangeColor),
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                "Next",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                    fontSize: 18),
              )),
            )),
      ),
      /* child: ElevatedButton(
          onPressed: _handleNextButtonTap,
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Next"),
          )),*/
    );
  }

  void _handleNextButtonTap() {
    if (_homeProvider!.playList.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayVideos(
                    playList: _homeProvider!.playList,
                  ))).then((value) => _homeProvider!.clearPlayList());
    }
  }

  void _init() async {
    await _homeProvider!.setInitThumbnails(VideoClip.clips, count: 1);
  }
}
