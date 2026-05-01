import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';

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

      final existingUrl = _videoPlayerUrls[video.id];
      if (_videoPlayers.containsKey(video.id) && existingUrl == playbackUrl) {
        continue;
      }

      await _videoPlayers.remove(video.id)?.dispose();
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

  Future<void> _confirmDeleteVideo(VideoPost video) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151515),
          title: const Text('Delete video?'),
          content: const Text(
            'This removes the video from the feed and deletes the stored file.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    await _videoController.deleteVideo(video);
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
    return ColoredBox(
      color: Colors.black,
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
                  isOwner: video.ownerId == _videoController.currentUserId,
                  onTap: _togglePlayback,
                  onRefresh: _refreshFeed,
                  onLike: () => _videoController.toggleLike(video),
                  onComment: () => _openComments(video),
                  onDelete: () => _confirmDeleteVideo(video),
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
    );
  }
}

class _FeedVideoPage extends StatelessWidget {
  const _FeedVideoPage({
    required this.video,
    required this.controller,
    required this.isCurrent,
    required this.isOwner,
    required this.onTap,
    required this.onRefresh,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
  });

  final VideoPost video;
  final VideoPlayerController? controller;
  final bool isCurrent;
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onDelete;

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeedHeader(onRefresh: onRefresh),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _VideoDetails(video: video)),
                      const SizedBox(width: 20),
                      _ActionRail(
                        video: video,
                        isOwner: isOwner,
                        onLike: onLike,
                        onComment: onComment,
                        onDelete: onDelete,
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

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Learn Feed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _VideoDetails extends StatelessWidget {
  const _VideoDetails({required this.video});

  final VideoPost video;

  @override
  Widget build(BuildContext context) {
    final caption = video.caption.isEmpty
        ? 'No caption yet. Open comments to start the discussion.'
        : video.caption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            video.subject.isEmpty ? video.visibility : video.subject,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '@${video.ownerName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            height: 1.14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.video,
    required this.isOwner,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
  });

  final VideoPost video;
  final bool isOwner;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FeedActionButton(
          icon: video.likedByMe ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(video.likeCount),
          color: video.likedByMe ? Colors.redAccent : Colors.white,
          onTap: onLike,
        ),
        const SizedBox(height: 18),
        _FeedActionButton(
          icon: Icons.mode_comment_outlined,
          label: _formatCount(video.commentCount),
          onTap: onComment,
        ),
        if (isOwner) ...[
          const SizedBox(height: 18),
          _FeedActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: onDelete,
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => widget.controller.fetchComments(
                  widget.video.id,
                  refresh: true,
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              final comments =
                  widget.controller.commentsByVideoId[widget.video.id] ??
                      <VideoComment>[];
              final isLoading =
                  widget.controller.loadingCommentsByVideoId[widget.video.id] ==
                      true;

              if (isLoading && comments.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB79CFF)),
                );
              }

              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'No comments yet. Start the conversation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: comments.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final canDelete = comment.authorId ==
                          widget.controller.currentUserId ||
                      widget.video.ownerId == widget.controller.currentUserId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      comment.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      comment.text,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    trailing: canDelete
                        ? IconButton(
                            onPressed: () => widget.controller.deleteComment(
                              video: widget.video,
                              comment: comment,
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white70,
                            ),
                          )
                        : null,
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.44),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _submitComment,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFB79CFF),
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
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
