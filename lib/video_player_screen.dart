import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:wyb_task/helpers/page_transformer.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  VideoPlayerController? _controller;
  int _currentIndex = 0;
  bool _isTransitioning = false;
  double _progress = 0.0;

  final List<String> _videoPaths = [
    'https://videos.pexels.com/video-files/5586712/5586712-hd_1080_1920_25fps.mp4',
    'https://videos.pexels.com/video-files/6077689/6077689-sd_360_640_25fps.mp4',
    'https://videos.pexels.com/video-files/2791956/2791956-sd_360_640_25fps.mp4',
    'https://videos.pexels.com/video-files/5445273/5445273-sd_360_640_25fps.mp4',
  ];

  final List<String> _names = ['Alice', 'Bob', 'Charlie', 'Diana'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializeAndPlay(_currentIndex);
  }

  void _initializeAndPlay(int index) async {
    setState(() {
      _isTransitioning = true;
    });

    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
    }

    final videoPath = _videoPaths[index];
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath))
      ..initialize().then((_) {
        setState(() {
          _isTransitioning = false;
          _updateProgress();
        });
        _controller?.play();
      });

    _controller?.addListener(() {
      if (_controller!.value.isPlaying) {
        _updateProgress();
      }
    });
  }

  void _updateProgress() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _progress = _controller!.value.position.inMilliseconds /
            _controller!.value.duration.inMilliseconds;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _videoPaths.length,
            onPageChanged: (index) {
              if (_currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
                _initializeAndPlay(index);
              }
            },
            itemBuilder: (context, index) {
              return CylindricalPageTransformer(
                page: AnimatedOpacity(
                  opacity: _isTransitioning ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: ScreenUtil().screenWidth,
                      height: ScreenUtil().screenHeight,
                      child: _controller != null && _controller!.value.isInitialized
                          ? VideoPlayer(_controller!)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                offset: (_pageController.hasClients) ? _pageController.page! - index.toDouble() : 0.0,
              );
            },
          ),
          // Adjusted Top Profile, Dots, and Close Button
          Positioned(
            top: 50.h, // Moved down
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage:
                          AssetImage('assets/profile$_currentIndex.jpeg'),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      _names[_currentIndex],
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.more_horiz, color: Colors.white),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Top Progress Bar
          Positioned(
            top: 30.h, // Moved the progress bar a bit downward as well
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.withOpacity(1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 2.h,
            ),
          ),
          // Show only current profile at bottom
          Positioned(
            bottom: 50.h, // Adjusted position
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundImage: AssetImage('assets/profile$_currentIndex.jpeg'),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
          // Bottom Text (Instagram Story-Like Text)
          Positioned(
            bottom: 20.h, // Moved this upward to create space for profile indicators
            left: 20.w,
            right: 20.w,
            child: Text(
              'Some description or caption for the story ...',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
