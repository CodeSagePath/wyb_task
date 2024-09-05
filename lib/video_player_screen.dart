import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  VideoPlayerController? _controller;
  int _currentIndex = 0;
  bool _isTransitioning = false;

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

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_videoPaths[index]))
          ..initialize().then((_) {
            setState(() {
              _isTransitioning = false;
            });
            _controller?.play();
          });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color.fromRGBO(158, 158, 158, 1),
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
                duration: Duration(milliseconds: 500),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller?.value.size.width ?? 0,
                    height: _controller?.value.size.height ?? 0,
                    child:
                        _controller != null && _controller!.value.isInitialized
                            ? VideoPlayer(_controller!)
                            : Center(child: CircularProgressIndicator()),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_videoPaths.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _initializeAndPlay(index);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _currentIndex == index ? 80.0 : 60.0,
                      height: _currentIndex == index ? 80.0 : 60.0,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/profile$index.jpg'),
                        child: _currentIndex == index
                            ? Container(
                                decoration: BoxDecoration(
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
