import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart' show kFlushNavbarHeight;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const int _feedNavIndex = 0;

  final PageController _pageController = PageController();
  final NavigationController _navigationController = Get.find();
  final VideoController _videoController = Get.find();
  final Map<String, VideoPlayerController> _videoPlayers = {};
  final Map<String, String> _videoPlayerUrls = {};

  late final Worker _navIndexWorker;
  late final Worker _videosWorker;
  int _currentIndex = 0;

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
      final playbackUrl = video.playbackUrl;
      if (playbackUrl == null || playbackUrl.isEmpty) continue;

      // Preserve any existing controller for this video — even if the
      // signed playback URL has changed (e.g. after a re-fetch). Tearing
      // down a controller mid-playback restarts the video and overrides
      // the user's pause state, which feels broken.
      if (_videoPlayers.containsKey(video.id)) continue;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(playbackUrl),
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
      if (_isFeedActive && currentVideo?.id == video.id) {
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

  void _handlePageChanged(int index) {
    final previousVideo = _currentVideo;
    if (previousVideo != null) {
      _videoPlayers[previousVideo.id]?.pause();
    }

    _currentIndex = index;
    final currentVideo = _currentVideo;
    if (currentVideo != null) {
      final controller = _videoPlayers[currentVideo.id];
      if (_isFeedActive && controller?.value.isInitialized == true) {
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
      final currentVideo = _currentVideo;
      final controller =
          currentVideo == null ? null : _videoPlayers[currentVideo.id];
      if (controller?.value.isInitialized == true) {
        controller?.play();
      }
    } else {
      for (final controller in _videoPlayers.values) {
        controller.pause();
      }
    }
  }

  void _togglePlayback() {
    if (!_isFeedActive) return;

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
    for (final controller in _videoPlayers.values) {
      controller.pause();
    }
    _currentIndex = 0;
    await _videoController.fetchFeed(refresh: true);
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

  void _openUserProfile(VideoPost video) {
    // For now, only the current user's profile screen exists. Tapping any
    // username jumps to the profile tab so the affordance always reacts —
    // future work: dedicated public profile route per ownerId.
    if (video.ownerId == _videoController.currentUserId) {
      _navigationController.updateIndex(2);
    }
  }

  @override
  void dispose() {
    _navIndexWorker.dispose();
    _videosWorker.dispose();
    _pageController.dispose();
    for (final controller in _videoPlayers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reserve the same vertical space the flush navbar occupies (its 52px
    // body plus the device's bottom safe-area inset) so the video and all
    // overlays end exactly at the navbar's top edge.
    final navbarReserved = kFlushNavbarHeight + MediaQuery.of(context).padding.bottom;

    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(bottom: navbarReserved),
        child: Obx(() {
          final videos = _videoController.videos;
          final isLoading = _videoController.isLoadingFeed.value ||
              _videoController.isRefreshingFeed.value;

          if (videos.isEmpty) {
            return _FeedEmptyState(
              isLoading: isLoading,
              error: _videoController.feedError.value,
              onRetry: _refreshFeed,
            );
          }

          return Stack(
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
                    isCurrent: index == _currentIndex,
                    onTap: _togglePlayback,
                    onLike: () => _videoController.toggleLike(video),
                    onComment: () => _openComments(video),
                    onUserTap: () => _openUserProfile(video),
                  );
                },
              ),
              if (isLoading)
                const SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(color: Color(0xFFB79CFF)),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}


class _FeedVideoPage extends StatelessWidget {
  const _FeedVideoPage({
    required this.video,
    required this.controller,
    required this.isCurrent,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onUserTap,
  });

  final VideoPost video;
  final VideoPlayerController? controller;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final playbackController = controller;
    final isPaused = isCurrent &&
        playbackController?.value.isInitialized == true &&
        playbackController?.value.isPlaying == false;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _VideoBackdrop(controller: playbackController),
          const _FeedGradientOverlay(),
          SafeArea(
            // Bottom safe-area is consumed by the navbar reservation in the
            // parent, so the page edges already stop above it.
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Row(
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
                      ),
                    ],
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
      ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF180B33),
              Color(0xFF050505),
              Color(0xFF17263D),
            ],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: playbackController.value.size.width,
        height: playbackController.value.size.height,
        child: VideoPlayer(playbackController),
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
        const SizedBox(height: 4),
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
  });

  final VideoPost video;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeTint;

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
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  Future<void> _submitComment() async {
    final text = _textController.text;
    _textController.clear();
    await widget.controller.createComment(video: widget.video, text: text);
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

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final canDelete = comment.authorId ==
                                  widget.controller.currentUserId ||
                              widget.video.ownerId ==
                                  widget.controller.currentUserId;

                          // Per-item slide+fade fires once per mount —
                          // perfect for the initial cascade and for new
                          // comments inserted at index 0. Existing items
                          // don't re-animate when the list updates.
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(comment.id),
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 260 + (index * 35).clamp(0, 200),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, t, child) {
                              return Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - t) * 10),
                                  child: child,
                                ),
                              );
                            },
                            child: _CommentTile(
                              comment: comment,
                              canDelete: canDelete,
                              onDelete: () => widget.controller.deleteComment(
                                video: widget.video,
                                comment: comment,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  _CommentInputBar(
                    controller: _textController,
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
            final count =
                controller.commentsByVideoId[videoId]?.length ?? 0;
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

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  final VideoComment comment;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initial = comment.authorName.isNotEmpty
        ? comment.authorName.characters.first.toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.1,
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
              ],
            ),
          ),
          if (canDelete) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatefulWidget {
  const _CommentInputBar({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final Future<void> Function() onSubmit;

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ClipRRect(
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
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) =>
                        _hasText ? widget.onSubmit() : null,
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
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String error;
  final Future<void> Function() onRetry;

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
                const Icon(
                  Icons.video_library_outlined,
                  color: Color(0xFFB79CFF),
                  size: 58,
                ),
              const SizedBox(height: 18),
              Text(
                isLoading ? 'Loading videos...' : 'No videos yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.isNotEmpty
                    ? error
                    : 'Upload a short lesson video to test the new feed routes.',
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
