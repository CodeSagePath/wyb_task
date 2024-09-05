import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager extends CacheManager {
  static const key = "videoCache";

  VideoCacheManager() : super(Config(key));
}
