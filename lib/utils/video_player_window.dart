/// Controls how many network-backed video players may stay alive around a
/// vertically paged video experience.
///
/// Keeping this policy independent of Flutter makes it easy to test and keeps
/// feed and profile playback behavior consistent.
class VideoPlayerWindow {
  const VideoPlayerWindow({
    required this.initializeRadius,
    required this.keepAliveRadius,
  })  : assert(initializeRadius >= 0),
        assert(keepAliveRadius >= initializeRadius);

  /// Pages in this radius should begin initializing so the next swipe is warm.
  final int initializeRadius;

  /// Pages outside this radius should release their decoder and network buffer.
  final int keepAliveRadius;

  bool shouldInitialize({required int pageIndex, required int currentIndex}) =>
      (pageIndex - currentIndex).abs() <= initializeRadius;

  bool shouldKeepAlive({required int pageIndex, required int currentIndex}) =>
      (pageIndex - currentIndex).abs() <= keepAliveRadius;
}
