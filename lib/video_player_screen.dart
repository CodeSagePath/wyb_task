import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:video_player/video_player.dart';
import 'package:wyb_task/video_cache_manager.dart';

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
    final cacheManager = VideoCacheManager();
    final file = await cacheManager.getSingleFile(videoPath);

    _controller = VideoPlayerController.file(file)
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
    // Initialize ScreenUtil
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shadowColor: const Color.fromRGBO(158, 158, 158, 0.1),
        toolbarHeight: 0, // kTextHeightNone doesn't exist in newer versions
      ),
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
              return AnimatedOpacity(
                opacity: _isTransitioning ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: ScreenUtil().screenWidth, // Using ScreenUtil for width
                    height: ScreenUtil().screenHeight, // Using ScreenUtil for height
                    child:
                        _controller != null && _controller!.value.isInitialized
                            ? VideoPlayer(_controller!)
                            : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              );
            },
          ),
          // Progress Bar
          Positioned(
            bottom: 40.h, // Use .h for height scaling
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.black.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          // Profile Circle Icon
          Positioned(
            top: 30.h, // Use .h for vertical scaling
            left: 20.w, // Use .w for horizontal scaling
            child: CircleAvatar(
              radius: 20.r, // Use .r for radius scaling
              backgroundImage: AssetImage('assets/profile$_currentIndex.jpg'),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Bottom Profile Indicators
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100.h, // Adjusted height with ScreenUtil
              padding: EdgeInsets.only(bottom: 20.h), // Use .h for padding scaling
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_videoPaths.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _initializeAndPlay(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _currentIndex == index ? 80.w : 60.w, // Use .w for width scaling
                      height: _currentIndex == index ? 80.h : 60.h, // Use .h for height scaling
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/profile$index.jpg'),
                        child: _currentIndex == index
                            ? Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
