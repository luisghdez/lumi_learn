import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/models/feed_scope.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/utils/profile_picture_image.dart';
import 'package:lumi_learn_app/routing/app_route_observer.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart'
    show feedVideoOverlayBottomPadding, floatingNavbarBottomReserve;

/// Human-facing share URL (`/video/:id`, singular).
///
/// **404 in the browser** usually means this hostname hits your **API** (e.g.
/// Fastify): the REST app exposes `GET /videos/:id` with auth, not public
/// `GET /video/:id`, so the server returns JSON "Route … not found". Fix by
/// serving `/video/*` from a **web** stack (static HTML + Universal Links / app
/// URL) or by registering a dedicated share/redirect route — not by changing
/// this path alone. In-app opens use the same host/path in `DeepLinkHandler`.
String shareableVideoUrl(VideoPost video) {
  return 'https://www.lumilearnapp.com/video/${video.id}';
}

Future<void> shareFeedVideo(VideoPost video) async {
  final link = shareableVideoUrl(video);
  final cap = video.caption.trim();
  final preview =
      cap.isEmpty ? '' : (cap.length > 100 ? '${cap.substring(0, 100)}…' : cap);
  final body = preview.isEmpty
      ? 'Check out @${video.ownerName} on Lumi.\n$link'
      : '@${video.ownerName}: $preview\n$link';
  await Share.share(body, subject: 'Lumi video');
}

VideoFormat? _formatHintForPlaybackUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  if (path.endsWith('.m3u8')) return VideoFormat.hls;
  if (path.endsWith('.mpd')) return VideoFormat.dash;
  if (path.contains('/manifest') || path.endsWith('.ism')) {
    return VideoFormat.ss;
  }
  return null;
}

/// Full-feed canvas (video loading state + area under the floating nav) so
/// there is no solid black band at the bottom.
const BoxDecoration _kFeedCanvasDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF180B33),
      Color(0xFF050505),
      Color(0xFF17263D),
    ],
  ),
);

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with RouteAware {
  static const int _feedNavIndex = 1;

  final PageController _pageController = PageController();
  final NavigationController _navigationController = Get.find();
  final VideoController _videoController = Get.find();
  final Map<String, VideoPlayerController> _videoPlayers = {};
  final Map<String, String> _videoPlayerUrls = {};

  late final Worker _navIndexWorker;
  late final Worker _videosWorker;
  late final Worker _pendingFeedScrollWorker;
  Worker? _createFlowVisibilityWorker;
  int _currentIndex = 0;
  PageRoute<void>? _boundListRoute;
  bool _obscuredByChildRoute = false;

  @override
  void initState() {
    super.initState();
    _navIndexWorker = ever<int>(
      _navigationController.currentIndex,
      _handleNavIndexChanged,
    );
    _videosWorker = ever<List<VideoPost>>(
      _videoController.videos,
      (_) => _syncVideoControllers(),
    );
    if (_videoController.videos.isEmpty) {
      _videoController.fetchFeed(refresh: true);
    } else {
      _syncVideoControllers();
    }
    _pendingFeedScrollWorker =
        ever<String?>(_videoController.pendingScrollFeedToVideoId, (id) {
      if (id == null || id.isEmpty || !mounted) return;
      void scrollTo() {
        if (!mounted) return;
        final list = _videoController.videos;
        final idx = list.indexWhere((v) => v.id == id);
        if (idx < 0) return;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(idx);
        }
        setState(() => _currentIndex = idx);
        _videoController.pendingScrollFeedToVideoId.value = null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => scrollTo());
    });
    if (Get.isRegistered<CreateFlowController>()) {
      final createFlow = Get.find<CreateFlowController>();
      _createFlowVisibilityWorker = ever(createFlow.visible, (_) {
        if (!mounted) return;
        if (createFlow.visible.value) {
          _pauseAllFeedVideoPlayers();
        } else if (_isFeedActive && !_obscuredByChildRoute) {
          final currentVideo = _currentVideo;
          final controller =
              currentVideo == null ? null : _videoPlayers[currentVideo.id];
          if (controller?.value.isInitialized == true) {
            controller?.play();
          }
        }
        setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void> && route != _boundListRoute) {
      if (_boundListRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _boundListRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    _obscuredByChildRoute = true;
    _pauseAllFeedVideoPlayers();
    setState(() {});
  }

  @override
  void didPopNext() {
    _obscuredByChildRoute = false;
    setState(() {});
    if (_feedPlaybackAllowed) {
      final currentVideo = _currentVideo;
      final controller =
          currentVideo == null ? null : _videoPlayers[currentVideo.id];
      if (controller?.value.isInitialized == true) {
        controller?.play();
      }
    }
  }

  void _pauseAllFeedVideoPlayers() {
    for (final controller in _videoPlayers.values) {
      controller.pause();
    }
  }

  Future<void> _syncVideoControllers() async {
    final videos = _videoController.videos;
    final activeIds = videos.map((video) => video.id).toSet();
    final staleIds = _videoPlayers.keys
        .where((id) => !activeIds.contains(id))
        .toList(growable: false);

    for (final id in staleIds) {
      await _videoPlayers.remove(id)?.dispose();
      _videoPlayerUrls.remove(id);
    }

    if (_currentIndex >= videos.length && videos.isNotEmpty) {
      _currentIndex = videos.length - 1;
    }

    for (final video in videos) {
      if (video.isSlideshow) continue;
      final playbackUrl = video.playbackUrl;
      if (playbackUrl == null || playbackUrl.isEmpty) continue;

      // Preserve any existing controller for this video — even if the
      // signed playback URL has changed (e.g. after a re-fetch). Tearing
      // down a controller mid-playback restarts the video and overrides
      // the user's pause state, which feels broken.
      if (_videoPlayers.containsKey(video.id)) continue;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(playbackUrl),
        formatHint: _formatHintForPlaybackUrl(playbackUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _videoPlayers[video.id] = controller;
      _videoPlayerUrls[video.id] = playbackUrl;
      _initializeVideoController(video, controller);
    }

    if (mounted) setState(() {});
  }

  Future<void> _initializeVideoController(
    VideoPost video,
    VideoPlayerController controller,
  ) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) return;

      final currentVideo = _currentVideo;
      if (_feedPlaybackAllowed && currentVideo?.id == video.id) {
        await controller.play();
      }
      setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  VideoPost? get _currentVideo {
    final videos = _videoController.videos;
    if (videos.isEmpty || _currentIndex >= videos.length) return null;
    return videos[_currentIndex];
  }

  bool get _isFeedActive =>
      _navigationController.currentIndex.value == _feedNavIndex;

  bool get _createHubOpen =>
      Get.isRegistered<CreateFlowController>() &&
      Get.find<CreateFlowController>().visible.value;

  /// Feed tab selected, no pushed route, and create hub not covering playback.
  bool get _feedPlaybackAllowed =>
      _isFeedActive && !_obscuredByChildRoute && !_createHubOpen;

  void _handlePageChanged(int index) {
    final previousVideo = _currentVideo;
    if (previousVideo != null) {
      _videoPlayers[previousVideo.id]?.pause();
    }

    _currentIndex = index;
    final currentVideo = _currentVideo;
    if (currentVideo != null) {
      final controller = _videoPlayers[currentVideo.id];
      if (_feedPlaybackAllowed && controller?.value.isInitialized == true) {
        controller?.play();
      }
    }

    if (index >= _videoController.videos.length - 2 &&
        _videoController.hasMoreFeed) {
      _videoController.fetchFeed();
    }

    setState(() {});
  }

  void _handleNavIndexChanged(int index) {
    if (index == _feedNavIndex) {
      if (!_feedPlaybackAllowed) return;
      final currentVideo = _currentVideo;
      final controller =
          currentVideo == null ? null : _videoPlayers[currentVideo.id];
      if (controller?.value.isInitialized == true) {
        controller?.play();
      }
    } else {
      _pauseAllFeedVideoPlayers();
    }
  }

  void _togglePlayback() {
    if (!_feedPlaybackAllowed) return;

    final currentVideo = _currentVideo;
    final controller =
        currentVideo == null ? null : _videoPlayers[currentVideo.id];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  Future<void> _refreshFeed() async {
    _pauseAllFeedVideoPlayers();
    _currentIndex = 0;
    await _videoController.fetchFeed(refresh: true);
    _jumpToFirstVideo();
  }

  void _jumpToFirstVideo() {
    if (!mounted) return;
    setState(() => _currentIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  Future<void> _switchFeedScope(FeedScope scope) async {
    await _videoController.setFeedScope(scope);
    if (!mounted) return;
    _pauseAllFeedVideoPlayers();
    _jumpToFirstVideo();
  }

  Future<void> _openFeedSubjectPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => const _FeedSubjectPickerSheet(),
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    await _videoController.setFeedScope(FeedScope.subject, subject: picked);
    if (!mounted) return;
    _pauseAllFeedVideoPlayers();
    _jumpToFirstVideo();
  }

  Future<void> _openComments(VideoPost video) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        controller: _videoController,
        video: video,
      ),
    );
  }

  Future<void> _openUserProfile(VideoPost video) async {
    if (video.ownerId.isEmpty) return;
    if (video.ownerId == _videoController.currentUserId) {
      _navigationController.updateIndex(2);
      return;
    }
    final friendsController = Get.find<FriendsController>();
    await friendsController.setActiveFriend(video.ownerId);
    if (!mounted) return;
    if (friendsController.activeFriend.value != null) {
      await Get.to<void>(
        () => const FriendProfile(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestFriendFromFeed(VideoPost video) async {
    if (video.ownerId.isEmpty ||
        video.ownerId == _videoController.currentUserId) {
      return;
    }
    final friendsController = Get.find<FriendsController>();
    if (!friendsController.canSendFriendRequestTo(video.ownerId)) {
      if (friendsController.isFriend(video.ownerId)) {
        Get.snackbar(
          'Friends',
          "You're already friends with ${video.ownerName}.",
        );
      } else if (friendsController.recievedRequestsIds
          .contains(video.ownerId)) {
        Get.snackbar(
          'Friend request',
          'Check the Friends tab — ${video.ownerName} already sent you a request.',
        );
      } else {
        Get.snackbar('Pending', 'A request is already in progress.');
      }
      return;
    }
    await friendsController.sendFriendRequest(video.ownerId);
  }

  @override
  void dispose() {
    if (_boundListRoute != null) {
      appRouteObserver.unsubscribe(this);
    }
    _navIndexWorker.dispose();
    _videosWorker.dispose();
    _pendingFeedScrollWorker.dispose();
    _createFlowVisibilityWorker?.dispose();
    _pageController.dispose();
    for (final controller in _videoPlayers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _kFeedCanvasDecoration,
      child: Obx(() {
        final bottomOverlayPad =
            _navigationController.isNavBarVisible.value
                ? floatingNavbarBottomReserve(context)
                : feedVideoOverlayBottomPadding(context);

        final videos = _videoController.videos;
        final isLoading = _videoController.isLoadingFeed.value ||
            _videoController.isRefreshingFeed.value;
        final scope = _videoController.feedScope.value;
        final subject = _videoController.feedSubject.value;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: videos.isEmpty
                  ? _FeedEmptyState(
                      isLoading: isLoading,
                      error: _videoController.feedError.value,
                      onRetry: _refreshFeed,
                      scope: scope,
                      activeSubject: subject,
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: videos.length,
                          onPageChanged: _handlePageChanged,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            final controller = _videoPlayers[video.id];
                            return _FeedVideoPage(
                              video: video,
                              controller: controller,
                              isCurrent: index == _currentIndex &&
                                  _feedPlaybackAllowed,
                              bottomOverlayPadding: bottomOverlayPad,
                              onTap: _togglePlayback,
                              onDoubleTapLike: () =>
                                  _videoController.toggleLike(video),
                              onLike: () => _videoController.toggleLike(video),
                              onComment: () => _openComments(video),
                              onUserTap: () => _openUserProfile(video),
                              onRequestFriend: () =>
                                  _requestFriendFromFeed(video),
                              onShare: () => shareFeedVideo(video),
                            );
                          },
                        ),
                        if (isLoading)
                          const SafeArea(
                            bottom: false,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                minHeight: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _FeedScopeBar(
                onForYou: () {
                  HapticFeedback.selectionClick();
                  unawaited(_switchFeedScope(FeedScope.forYou));
                },
                onFriends: () {
                  HapticFeedback.selectionClick();
                  unawaited(_switchFeedScope(FeedScope.friends));
                },
                onSubject: () {
                  HapticFeedback.selectionClick();
                  unawaited(_openFeedSubjectPicker());
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FeedVideoPage extends StatelessWidget {
  const _FeedVideoPage({
    required this.video,
    required this.controller,
    required this.isCurrent,
    required this.bottomOverlayPadding,
    required this.onTap,
    required this.onDoubleTapLike,
    required this.onLike,
    required this.onComment,
    required this.onUserTap,
    required this.onRequestFriend,
    required this.onShare,
  });

  final VideoPost video;
  final VideoPlayerController? controller;
  final bool isCurrent;

  /// Extra bottom inset under caption / rail (nav reserve or compact).
  final double bottomOverlayPadding;
  final VoidCallback onTap;
  final VoidCallback onDoubleTapLike;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onUserTap;
  final VoidCallback onRequestFriend;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final playbackController = controller;
    final isPaused = !video.isSlideshow &&
        isCurrent &&
        playbackController?.value.isInitialized == true &&
        playbackController?.value.isPlaying == false;

    final backdrop = video.isSlideshow
        ? GestureDetector(
            onDoubleTap: onDoubleTapLike,
            behavior: HitTestBehavior.deferToChild,
            child: _SlideshowBackdrop(video: video, isActive: isCurrent),
          )
        : GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTapLike,
            behavior: HitTestBehavior.deferToChild,
            child: _VideoBackdrop(controller: playbackController),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        backdrop,
        const IgnorePointer(child: _FeedGradientOverlay()),
        SafeArea(
          bottom: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            padding:
                EdgeInsets.fromLTRB(20, 12, 20, 14 + bottomOverlayPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: IgnorePointer(
                    child: SizedBox.expand(),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: GestureDetector(
                    onDoubleTap: onDoubleTapLike,
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _VideoDetails(
                            video: video,
                            onUserTap: onUserTap,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _ActionRail(
                          video: video,
                          onLike: onLike,
                          onComment: onComment,
                          onUserTap: onUserTap,
                          onRequestFriend: onRequestFriend,
                          onShare: onShare,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isPaused)
          const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 86,
            ),
          ),
      ],
    );
  }
}

class _VideoBackdrop extends StatelessWidget {
  const _VideoBackdrop({required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final playbackController = controller;
    if (playbackController == null || !playbackController.value.isInitialized) {
      return const DecoratedBox(
        decoration: _kFeedCanvasDecoration,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: playbackController.value.size.width,
        height: playbackController.value.size.height,
        child: VideoPlayer(playbackController),
      ),
    );
  }
}

/// Horizontal slideshow: full-frame [BoxFit.contain] images, manual swipe,
/// timed advance (pauses while the user is dragging horizontally).
class _SlideshowBackdrop extends StatefulWidget {
  const _SlideshowBackdrop({
    required this.video,
    required this.isActive,
  });

  final VideoPost video;
  final bool isActive;

  @override
  State<_SlideshowBackdrop> createState() => _SlideshowBackdropState();
}

class _SlideshowBackdropState extends State<_SlideshowBackdrop> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 0;

  List<VideoSlide> get _slides => widget.video.slides;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.isActive) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _restartAutoAdvance());
    }
  }

  @override
  void didUpdateWidget(covariant _SlideshowBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _restartAutoAdvance();
    } else if (!widget.isActive && oldWidget.isActive) {
      _cancelTimer();
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    _pageController.dispose();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _restartAutoAdvance() {
    _cancelTimer();
    if (!widget.isActive || _slides.isEmpty) return;
    _armTimer();
  }

  void _armTimer() {
    if (!widget.isActive || _slides.isEmpty) return;
    final safeIndex = _page.clamp(0, _slides.length - 1);
    final ms = _slides[safeIndex].durationMs ?? 3400;
    _timer = Timer(Duration(milliseconds: ms), () {
      if (!mounted || !widget.isActive) return;
      final next = (_page + 1) % _slides.length;
      setState(() => _page = next);
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
      _armTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return const DecoratedBox(
        decoration: _kFeedCanvasDecoration,
        child: Center(
          child: Icon(Icons.collections, color: Colors.white54, size: 48),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n.metrics.axis != Axis.horizontal) return false;
              if (n is UserScrollNotification) {
                _cancelTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _page = i);
                _restartAutoAdvance();
              },
              itemCount: _slides.length,
              itemBuilder: (context, i) {
                final url = _slides[i].url;
                return SizedBox.expand(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFB388FF),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white38, size: 48),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: floatingNavbarBottomReserve(context) + 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final on = i == _page;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: on ? 9 : 7,
                  height: on ? 9 : 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.62),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.35),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: on
                            ? Colors.black.withValues(alpha: 0.55)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: on ? 8 : 5,
                        spreadRadius: on ? 0.5 : 0,
                      ),
                      if (on)
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.45),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedGradientOverlay extends StatelessWidget {
  const _FeedGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.78),
          ],
          stops: const [0, 0.42, 1],
        ),
      ),
    );
  }
}

class _VideoDetails extends StatelessWidget {
  const _VideoDetails({
    required this.video,
    required this.onUserTap,
  });

  final VideoPost video;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final caption = video.caption.isEmpty
        ? 'No caption yet. Open comments to start the discussion.'
        : video.caption;
    final hasSubject = video.subject.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSubject) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              video.subject,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: onUserTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '@${video.ownerName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 13,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onUserTap,
    required this.onRequestFriend,
    required this.onShare,
  });

  final VideoPost video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onUserTap;
  final VoidCallback onRequestFriend;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final videoController = Get.find<VideoController>();
    final friendsController = Get.find<FriendsController>();

    return Obx(() {
      final selfId = videoController.currentUserId;
      final uid = video.ownerId;
      final showAdd = uid.isNotEmpty &&
          uid != selfId &&
          friendsController.canSendFriendRequestTo(uid);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FeedOwnerAvatarChip(
            image: profilePictureProvider(video.ownerProfilePicture),
            onTap: onUserTap,
            showAddBadge: showAdd,
            onAddFriend: showAdd ? onRequestFriend : null,
          ),
          const SizedBox(height: 12),
          _LiquidGlassAction(
            icon: video.likedByMe
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            label: _formatCount(video.likeCount),
            onTap: onLike,
            isActive: video.likedByMe,
            activeTint: const Color(0xFFFF4D6D),
          ),
          const SizedBox(height: 14),
          _LiquidGlassAction(
            icon: Icons.mode_comment_outlined,
            label: _formatCount(video.commentCount),
            onTap: onComment,
          ),
          const SizedBox(height: 14),
          _LiquidGlassAction(
            icon: Icons.more_horiz_rounded,
            label: '',
            onTap: onShare,
            showLabel: false,
            iconSize: 26,
          ),
        ],
      );
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _FeedOwnerAvatarChip extends StatelessWidget {
  const _FeedOwnerAvatarChip({
    required this.image,
    required this.onTap,
    this.showAddBadge = false,
    this.onAddFriend,
  });

  final ImageProvider image;
  final VoidCallback onTap;
  final bool showAddBadge;
  final VoidCallback? onAddFriend;

  static const double _d = 46;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _d + 4,
      height: _d + 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: _d,
              height: _d,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image(
                image: image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/pfp/pfp28.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (showAddBadge && onAddFriend != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: () {
                  onAddFriend!();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB388FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.85),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// iOS-inspired liquid glass action button. Uses a true backdrop blur, a
/// vertical specular gradient (top-bright → bottom-soft), and a hairline
/// border. Activating swaps the glass tint to [activeTint] while keeping the
/// glassy quality.
class _LiquidGlassAction extends StatelessWidget {
  const _LiquidGlassAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeTint,
    this.showLabel = true,
    this.iconSize = 24,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeTint;
  final bool showLabel;
  final double iconSize;

  static const double _size = 50;

  @override
  Widget build(BuildContext context) {
    final tint = isActive ? (activeTint ?? Colors.white) : Colors.white;
    final highlightAlpha = isActive ? 0.55 : 0.22;
    final lowlightAlpha = isActive ? 0.18 : 0.06;
    final borderAlpha = isActive ? 0.65 : 0.28;
    final iconColor = isActive ? Colors.white : Colors.white;
    final glowAlpha = isActive ? 0.35 : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: glowAlpha),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tint.withValues(alpha: highlightAlpha),
                        tint.withValues(alpha: lowlightAlpha),
                      ],
                    ),
                    border: Border.all(
                      color: tint.withValues(alpha: borderAlpha),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isActive ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: Icon(icon, color: iconColor, size: iconSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.controller,
    required this.video,
  });

  final VideoController controller;
  final VideoPost video;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _textController = TextEditingController();
  String? _replyParentId;
  String? _replyParentName;
  /// Root comment ids whose reply lists are expanded in the sheet.
  final Set<String> _expandedThreadRootIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchComments(widget.video.id, refresh: true);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startReply(VideoComment c) {
    setState(() {
      _replyParentId = c.id;
      _replyParentName = c.authorName;
    });
  }

  void _clearReply() {
    setState(() {
      _replyParentId = null;
      _replyParentName = null;
    });
  }

  void _toggleThreadReplies(String rootCommentId) {
    setState(() {
      if (_expandedThreadRootIds.contains(rootCommentId)) {
        _expandedThreadRootIds.remove(rootCommentId);
      } else {
        _expandedThreadRootIds.add(rootCommentId);
      }
    });
  }

  bool _canDeleteComment(VideoComment c) =>
      c.authorId == widget.controller.currentUserId ||
      widget.video.ownerId == widget.controller.currentUserId;

  Future<void> _submitComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final parent = _replyParentId;
    _textController.clear();
    final ok = await widget.controller.createComment(
      video: widget.video,
      text: text,
      parentCommentId: parent,
    );
    if (ok) {
      _clearReply();
    } else {
      _textController.text = text;
    }
  }

  Future<void> _openCommenterProfile(String userId) async {
    if (userId.isEmpty) return;
    if (userId == widget.controller.currentUserId) {
      if (mounted) Navigator.of(context).pop();
      Get.find<NavigationController>().updateIndex(2);
      return;
    }
    final friendsController = Get.find<FriendsController>();
    await friendsController.setActiveFriend(userId);
    if (!mounted) return;
    if (friendsController.activeFriend.value == null) return;
    Navigator.of(context).pop();
    await Get.to<void>(
      () => const FriendProfile(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: screenHeight * 0.78,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CommentsHeader(
                    controller: widget.controller,
                    videoId: widget.video.id,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      final comments = widget
                              .controller.commentsByVideoId[widget.video.id] ??
                          <VideoComment>[];
                      final isLoading = widget.controller
                              .loadingCommentsByVideoId[widget.video.id] ==
                          true;

                      if (isLoading && comments.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFB79CFF),
                          ),
                        );
                      }

                      if (comments.isEmpty) {
                        return const _EmptyCommentsState();
                      }

                      final groups = groupVideoCommentsForFeed(comments);
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final expanded =
                              _expandedThreadRootIds.contains(group.root.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommentThreadCard(
                              key: ValueKey(group.root.id),
                              group: group,
                              expanded: expanded,
                              onToggleReplies: () =>
                                  _toggleThreadReplies(group.root.id),
                              video: widget.video,
                              controller: widget.controller,
                              onOpenProfile: _openCommenterProfile,
                              onStartReply: _startReply,
                              canDeleteComment: _canDeleteComment,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  _CommentInputBar(
                    controller: _textController,
                    replyingToName: _replyParentName,
                    onCancelReply:
                        _replyParentName != null ? _clearReply : null,
                    onSubmit: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader({
    required this.controller,
    required this.videoId,
  });

  final VideoController controller;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final count = controller.commentsByVideoId[videoId]?.length ?? 0;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(count),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.mode_comment_outlined,
              color: Colors.white.withValues(alpha: 0.55),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No comments yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to start the conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentAuthorAvatar extends StatelessWidget {
  const _CommentAuthorAvatar({required this.comment});

  final VideoComment comment;

  @override
  Widget build(BuildContext context) {
    final videoController = Get.find<VideoController>();
    final selfId = videoController.currentUserId;
    final isSelf =
        selfId != null && selfId.isNotEmpty && comment.authorId == selfId;

    Widget avatar(String raw) {
      return ClipOval(
        child: Image(
          image: profilePictureProvider(raw),
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/pfp/pfp28.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (!isSelf) {
      return avatar(comment.authorProfilePicture);
    }

    return Obx(() {
      final live = Get.find<AuthController>()
              .firebaseUser
              .value
              ?.photoURL
              ?.trim() ??
          '';
      final raw = live.isNotEmpty ? live : comment.authorProfilePicture;
      return avatar(raw);
    });
  }
}

/// One root comment; replies render inside when expanded (no per-reply cards).
class _CommentThreadCard extends StatelessWidget {
  const _CommentThreadCard({
    super.key,
    required this.group,
    required this.expanded,
    required this.onToggleReplies,
    required this.video,
    required this.controller,
    required this.onOpenProfile,
    required this.onStartReply,
    required this.canDeleteComment,
  });

  final VideoCommentThreadGroup group;
  final bool expanded;
  final VoidCallback onToggleReplies;
  final VideoPost video;
  final VideoController controller;
  final void Function(String userId) onOpenProfile;
  final void Function(VideoComment c) onStartReply;
  final bool Function(VideoComment c) canDeleteComment;

  @override
  Widget build(BuildContext context) {
    final replies = group.replies;
    final n = replies.length;
    final muted = Colors.white.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CommentBody(
          comment: group.root,
          dense: false,
          canDelete: canDeleteComment(group.root),
          onProfileTap: () => onOpenProfile(group.root.authorId),
          onReply: () => onStartReply(group.root),
          onLike: () => controller.toggleCommentLike(
            video: video,
            comment: group.root,
          ),
          onDelete: () => controller.deleteComment(
            video: video,
            comment: group.root,
          ),
        ),
        if (n > 0) ...[
          const SizedBox(height: 2),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleReplies,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 22,
                      color: muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      expanded
                          ? 'Hide replies'
                          : (n == 1 ? 'View 1 reply' : 'View $n replies'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < replies.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              _CommentBody(
                                comment: replies[i],
                                dense: true,
                                canDelete: canDeleteComment(replies[i]),
                                onProfileTap: () =>
                                    onOpenProfile(replies[i].authorId),
                                onReply: () => onStartReply(replies[i]),
                                onLike: () => controller.toggleCommentLike(
                                  video: video,
                                  comment: replies[i],
                                ),
                                onDelete: () => controller.deleteComment(
                                  video: video,
                                  comment: replies[i],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

class _CommentBody extends StatelessWidget {
  const _CommentBody({
    required this.comment,
    required this.dense,
    required this.canDelete,
    required this.onProfileTap,
    required this.onReply,
    required this.onLike,
    required this.onDelete,
  });

  final VideoComment comment;
  final bool dense;
  final bool canDelete;
  final VoidCallback onProfileTap;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final v = dense ? 6.0 : 8.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: v),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: _CommentAuthorAvatar(comment: comment),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    comment.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onReply,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onLike,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.likedByMe
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: comment.likedByMe
                                ? const Color(0xFFFF4D6D)
                                : Colors.white.withValues(alpha: 0.55),
                          ),
                          if (comment.likeCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, top: 2),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatefulWidget {
  const _CommentInputBar({
    required this.controller,
    required this.onSubmit,
    this.replyingToName,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final Future<void> Function() onSubmit;
  final String? replyingToName;
  final VoidCallback? onCancelReply;

  @override
  State<_CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<_CommentInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) {
    final replying = widget.replyingToName;
    final hint = replying != null ? 'Add a reply…' : 'Add a comment…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (replying != null && widget.onCancelReply != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onCancelReply,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Replying to @$replying',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          hintText: hint,
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onSubmitted: (_) => _hasText ? widget.onSubmit() : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _hasText
                              ? const [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFE4E4E4),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.06),
                                ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: _hasText ? 0.85 : 0.18,
                          ),
                          width: 1,
                        ),
                        boxShadow: _hasText
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: GestureDetector(
                        onTap: _hasText ? () => widget.onSubmit() : null,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: _hasText
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.45),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedScopeBar extends StatelessWidget {
  const _FeedScopeBar({
    required this.onForYou,
    required this.onFriends,
    required this.onSubject,
  });

  final VoidCallback onForYou;
  final VoidCallback onFriends;
  final VoidCallback onSubject;

  @override
  Widget build(BuildContext context) {
    final vc = Get.find<VideoController>();
    final topInset = MediaQuery.paddingOf(context).top;
    // Tall enough for notch + tabs; fade reads on video without a separate “strip”.
    final barHeight = topInset + 52;
    return SizedBox(
      height: barHeight,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                  ],
                  stops: [0, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Obx(() {
                  final scope = vc.feedScope.value;
                  final sub = vc.feedSubject.value;
                  final subjectLabel = sub.isEmpty
                      ? 'Subject'
                      : (sub.length > 14 ? '${sub.substring(0, 12)}…' : sub);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeedScopeSegment(
                        label: 'For you',
                        selected: scope == FeedScope.forYou,
                        onTap: onForYou,
                      ),
                      const SizedBox(width: 4),
                      _FeedScopeSegment(
                        label: 'Friends',
                        selected: scope == FeedScope.friends,
                        onTap: onFriends,
                      ),
                      const SizedBox(width: 4),
                      _FeedScopeSegment(
                        label: subjectLabel,
                        selected: scope == FeedScope.subject,
                        onTap: onSubject,
                      ),
                    ],
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

class _FeedScopeSegment extends StatelessWidget {
  const _FeedScopeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: selected ? 1 : 0.52),
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  shadows: const [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black45,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 2.5,
                width: selected ? 22 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black38,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedSubjectPickerSheet extends StatefulWidget {
  const _FeedSubjectPickerSheet();

  @override
  State<_FeedSubjectPickerSheet> createState() =>
      _FeedSubjectPickerSheetState();
}

class _FeedSubjectPickerSheetState extends State<_FeedSubjectPickerSheet> {
  final TextEditingController _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final q = _q.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? allSubjects
        : allSubjects.where((s) => s.toLowerCase().contains(q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.58,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: Colors.black.withValues(alpha: 0.72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Text(
                        'Subject feed',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _q,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search subjects…',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No matches',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final t = filtered[i];
                                return ListTile(
                                  title: Text(
                                    t,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () => Navigator.pop(context, t),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.scope,
    required this.activeSubject,
  });

  final bool isLoading;
  final String error;
  final Future<void> Function() onRetry;
  final FeedScope scope;
  final String activeSubject;

  String get _headline {
    if (isLoading) return 'Loading…';
    switch (scope) {
      case FeedScope.friends:
        return 'No friend posts here';
      case FeedScope.subject:
        return activeSubject.isEmpty
            ? 'Pick a subject'
            : 'Nothing for this subject yet';
      case FeedScope.forYou:
        return 'No videos yet';
    }
  }

  String get _hint {
    if (error.isNotEmpty) return error;
    switch (scope) {
      case FeedScope.friends:
        return 'Add friends or switch to For you to see more posts in your area.';
      case FeedScope.subject:
        if (activeSubject.isEmpty) {
          return 'Tap Subject above and choose a class — your feed will match that tag.';
        }
        return 'Try another subject, or go back to For you for the full mix.';
      case FeedScope.forYou:
        return 'Pull to refresh, or upload a clip from Create.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: Color(0xFFB79CFF))
              else
                Icon(
                  scope == FeedScope.friends
                      ? Icons.group_outlined
                      : scope == FeedScope.subject
                          ? Icons.school_outlined
                          : Icons.video_library_outlined,
                  color: const Color(0xFFB79CFF),
                  size: 58,
                ),
              const SizedBox(height: 18),
              Text(
                _headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: isLoading ? null : onRetry,
                child: const Text('Refresh feed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen vertical pager for a user's profile videos (same UI as feed).
class ProfileUserVideoFeedScreen extends StatefulWidget {
  const ProfileUserVideoFeedScreen({
    super.key,
    required this.userId,
    required this.initialVideoId,
    required this.initialIndex,
  });

  final String userId;
  final String initialVideoId;
  final int initialIndex;

  @override
  State<ProfileUserVideoFeedScreen> createState() =>
      _ProfileUserVideoFeedScreenState();
}

class _ProfileUserVideoFeedScreenState extends State<ProfileUserVideoFeedScreen> {
  late final PageController _pageController;
  final VideoController _videoController = Get.find();
  final NavigationController _navigationController = Get.find();
  final Map<String, VideoPlayerController> _videoPlayers = {};
  late final Worker _videosWorker;
  int _currentIndex = 0;

  List<VideoPost> _videosForUser() =>
      _videoController.userVideosByUserId[widget.userId] ?? <VideoPost>[];

  int _resolveStartIndex(List<VideoPost> videos) {
    if (videos.isEmpty) return 0;
    final idx = widget.initialIndex;
    if (idx >= 0 &&
        idx < videos.length &&
        videos[idx].id == widget.initialVideoId) {
      return idx;
    }
    final found = videos.indexWhere((v) => v.id == widget.initialVideoId);
    return found >= 0 ? found : 0;
  }

  @override
  void initState() {
    super.initState();
    final videos = _videosForUser();
    _currentIndex = _resolveStartIndex(videos);
    _pageController = PageController(initialPage: _currentIndex);

    _videosWorker = ever(
      _videoController.userVideosByUserId,
      (_) => _syncVideoControllers(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncVideoControllers();
      final v = _currentVideo;
      if (v != null && !v.isSlideshow) {
        final c = _videoPlayers[v.id];
        if (c?.value.isInitialized == true) {
          c!.play();
        }
      }
    });
  }

  Future<void> _syncVideoControllers() async {
    final videos = _videosForUser();
    final activeIds = videos.map((v) => v.id).toSet();
    final staleIds = _videoPlayers.keys
        .where((id) => !activeIds.contains(id))
        .toList(growable: false);

    for (final id in staleIds) {
      await _videoPlayers.remove(id)?.dispose();
    }

    if (_currentIndex >= videos.length && videos.isNotEmpty) {
      _currentIndex = videos.length - 1;
    }

    for (final video in videos) {
      if (video.isSlideshow) continue;
      final playbackUrl = video.playbackUrl;
      if (playbackUrl == null || playbackUrl.isEmpty) continue;
      if (_videoPlayers.containsKey(video.id)) continue;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(playbackUrl),
        formatHint: _formatHintForPlaybackUrl(playbackUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _videoPlayers[video.id] = controller;
      _initializeVideoController(video, controller);
    }

    if (mounted) setState(() {});
  }

  Future<void> _initializeVideoController(
    VideoPost video,
    VideoPlayerController controller,
  ) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) return;

      final currentVideo = _currentVideo;
      if (currentVideo?.id == video.id) {
        await controller.play();
      }
      setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  VideoPost? get _currentVideo {
    final videos = _videosForUser();
    if (videos.isEmpty || _currentIndex >= videos.length) return null;
    return videos[_currentIndex];
  }

  void _handlePageChanged(int index) {
    final previousVideo = _currentVideo;
    if (previousVideo != null) {
      _videoPlayers[previousVideo.id]?.pause();
    }

    _currentIndex = index;
    final currentVideo = _currentVideo;
    if (currentVideo != null) {
      final controller = _videoPlayers[currentVideo.id];
      if (controller?.value.isInitialized == true) {
        controller?.play();
      }
    }

    final videos = _videosForUser();
    if (index >= videos.length - 2 &&
        _videoController.hasMoreUserVideos(widget.userId)) {
      _videoController.fetchUserVideos(widget.userId, refresh: false);
    }

    setState(() {});
  }

  void _togglePlayback() {
    final currentVideo = _currentVideo;
    final controller =
        currentVideo == null ? null : _videoPlayers[currentVideo.id];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  Future<void> _openComments(VideoPost video) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        controller: _videoController,
        video: video,
      ),
    );
  }

  Future<void> _openUserProfile(VideoPost video) async {
    if (video.ownerId.isEmpty) return;
    if (video.ownerId == _videoController.currentUserId) {
      Get.back<void>();
      _navigationController.updateIndex(2);
      return;
    }
    final friendsController = Get.find<FriendsController>();
    await friendsController.setActiveFriend(video.ownerId);
    if (!mounted) return;
    if (friendsController.activeFriend.value != null) {
      await Get.to<void>(
        () => const FriendProfile(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestFriendFromFeed(VideoPost video) async {
    if (video.ownerId.isEmpty ||
        video.ownerId == _videoController.currentUserId) {
      return;
    }
    final friendsController = Get.find<FriendsController>();
    if (!friendsController.canSendFriendRequestTo(video.ownerId)) {
      if (friendsController.isFriend(video.ownerId)) {
        Get.snackbar(
          'Friends',
          "You're already friends with ${video.ownerName}.",
        );
      } else if (friendsController.recievedRequestsIds
          .contains(video.ownerId)) {
        Get.snackbar(
          'Friend request',
          'Check the Friends tab — ${video.ownerName} already sent you a request.',
        );
      } else {
        Get.snackbar('Pending', 'A request is already in progress.');
      }
      return;
    }
    await friendsController.sendFriendRequest(video.ownerId);
  }

  @override
  void dispose() {
    _videosWorker.dispose();
    _pageController.dispose();
    for (final controller in _videoPlayers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomOverlayPad = feedVideoOverlayBottomPadding(context);

    return DecoratedBox(
      decoration: _kFeedCanvasDecoration,
      child: Obx(() {
        final videos = _videosForUser();
        final isLoading =
            _videoController.loadingUserVideosByUserId[widget.userId] == true;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (videos.isEmpty)
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Color(0xFFB79CFF))
                      : Text(
                          'No videos',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )
              else
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final controller = _videoPlayers[video.id];
                    return _FeedVideoPage(
                      video: video,
                      controller: controller,
                      isCurrent: index == _currentIndex,
                      bottomOverlayPadding: bottomOverlayPad,
                      onTap: _togglePlayback,
                      onDoubleTapLike: () => _videoController.toggleLike(video),
                      onLike: () => _videoController.toggleLike(video),
                      onComment: () => _openComments(video),
                      onUserTap: () => _openUserProfile(video),
                      onRequestFriend: () => _requestFriendFromFeed(video),
                      onShare: () => shareFeedVideo(video),
                    );
                  },
                ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () => Get.back<void>(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Back',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
