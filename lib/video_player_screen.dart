import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

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
    'https://videos.pexels.com/video-files/6077689/6077689-sd_360_640_25fps.mp4',
    'https://videos.pexels.com/video-files/5445273/5445273-sd_360_640_25fps.mp4',
  ];

  final List<String> _names = ['Robert', 'Chase', 'House', 'Cameron', 'Kutner'];

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
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: AssetImage('assets/profile${_currentIndex + 1}.jpeg'),
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
                    const Icon(Icons.more_horiz, color: Colors.white),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.withOpacity(1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 2.h,
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundImage: AssetImage('assets/profile${_currentIndex + 1}.jpeg'),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
          Positioned(
            bottom: 20.h,
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

class CylindricalPageTransformer extends StatelessWidget {
  final Widget page;
  final double offset;

  const CylindricalPageTransformer({super.key, required this.page, required this.offset});

  @override
  Widget build(BuildContext context) {
    final double rotation = offset * 0.2;
    final double translation = offset * MediaQuery.of(context).size.width * 0.7;

    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(rotation)
      ..translate(translation, 0.0, 0.0);

    final double opacity = (1 - offset.abs()).clamp(0.0, 1.0);

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: page,
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:wyb_task/helpers/page_transformer.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   const VideoPlayerScreen({super.key});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late PageController _pageController;
//   VideoPlayerController? _controller;
//   int _currentIndex = 0;
//   bool _isTransitioning = false;
//   double _progress = 0.0;

//   final List<String> _videoPaths = [
//     'https://videos.pexels.com/video-files/5586712/5586712-hd_1080_1920_25fps.mp4',
//     'https://videos.pexels.com/video-files/6077689/6077689-sd_360_640_25fps.mp4',
//     'https://videos.pexels.com/video-files/2791956/2791956-sd_360_640_25fps.mp4',
//     'https://videos.pexels.com/video-files/6077689/6077689-sd_360_640_25fps.mp4',
//     'https://videos.pexels.com/video-files/5445273/5445273-sd_360_640_25fps.mp4',
//   ];

//   final List<String> _names = ['Robert', 'Chase', 'House', 'Cameron', 'Kutner'];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentIndex);
//     _initializeAndPlay(_currentIndex);
//   }

//   void _initializeAndPlay(int index) async {
//     setState(() {
//       _isTransitioning = true;
//     });

//     if (_controller != null) {
//       await _controller!.pause();
//       await _controller!.dispose();
//     }

//     final videoPath = _videoPaths[index];
//     _controller = VideoPlayerController.network(videoPath)
//       ..initialize().then((_) {
//         setState(() {
//           _isTransitioning = false;
//           _updateProgress();
//         });
//         _controller?.play();
//       });

//     _controller?.addListener(() {
//       if (_controller!.value.isPlaying) {
//         _updateProgress();
//       }
//     });
//   }

//   void _updateProgress() {
//     if (_controller != null && _controller!.value.isInitialized) {
//       setState(() {
//         _progress = _controller!.value.position.inMilliseconds /
//             _controller!.value.duration.inMilliseconds;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: _videoPaths.length,
//             onPageChanged: (index) {
//               if (_currentIndex != index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//                 _initializeAndPlay(index);
//               }
//             },
//             itemBuilder: (context, index) {
//               return Stack(
//                 children: [
//                   // Video Content with 3D effect
//                   CylindricalPageTransformer(
//                     page: AnimatedOpacity(
//                       opacity: _isTransitioning ? 0.0 : 1.0,
//                       duration: const Duration(milliseconds: 250),
//                       child: FittedBox(
//                         fit: BoxFit.cover,
//                         child: SizedBox(
//                           width: ScreenUtil().screenWidth,
//                           height: ScreenUtil().screenHeight,
//                           child: _controller != null &&
//                                   _controller!.value.isInitialized
//                               ? VideoPlayer(_controller!)
//                               : const Center(child: CircularProgressIndicator()),
//                         ),
//                       ),
//                     ),
//                     offset: (_pageController.hasClients)
//                         ? _pageController.page! - index.toDouble()
//                         : 0.0,
//                   ),
//                   // Bottom Profile Icon
//                   Positioned(
//                     bottom: 50.h,
//                     left: 0,
//                     right: 0,
//                     child: CylindricalPageTransformer(
//                       page: CircleAvatar(
//                         radius: 50.r,
//                         backgroundImage:
//                             AssetImage('assets/profile$_currentIndex.jpeg'),
//                         backgroundColor: Colors.transparent,
//                       ),
//                       offset: (_pageController.hasClients)
//                           ? _pageController.page! - index.toDouble()
//                           : 0.0,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           // Top Progress Bar
//           Positioned(
//             top: 30.h,
//             left: 0,
//             right: 0,
//             child: LinearProgressIndicator(
//               value: _progress,
//               backgroundColor: Colors.grey.withOpacity(1),
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//               minHeight: 2.h,
//             ),
//           ),
//           // Top Profile, Name, and Close Button (Static)
//           Positioned(
//             top: 50.h, // Adjusted position
//             left: 20.w,
//             right: 20.w,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 20.r,
//                       backgroundImage:
//                           AssetImage('assets/profile$_currentIndex.jpeg'),
//                       backgroundColor: Colors.transparent,
//                     ),
//                     SizedBox(width: 10.w),
//                     Text(
//                       _names[_currentIndex],
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         color: Colors.white,
//                         fontSize: 16.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.more_horiz, color: Colors.white),
//                     SizedBox(width: 10.w),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Icon(Icons.close, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Static Caption (Instagram-like)
//           Positioned(
//             bottom: 20.h,
//             left: 20.w,
//             right: 20.w,
//             child: Text(
//               'Some description or caption for the story ...',
//               style: TextStyle(
//                 fontFamily: 'Roboto',
//                 color: Colors.white,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
