import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:lumi_learn_app/screens/feed/feed_screen.dart';

/// Same 3-column video grid as the account profile; works for any [userId].
class ProfileVideosGrid extends StatefulWidget {
  const ProfileVideosGrid({
    super.key,
    required this.userId,
    this.showPendingUploadSlot = false,
    this.scrollController,
  });

  final String userId;
  final bool showPendingUploadSlot;
  final ScrollController? scrollController;

  @override
  State<ProfileVideosGrid> createState() => _ProfileVideosGridState();
}

class _ProfileVideosGridState extends State<ProfileVideosGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Get.isRegistered<VideoController>()) {
        Get.find<VideoController>().fetchUserVideos(widget.userId, refresh: true);
      }
    });
    widget.scrollController?.addListener(_onScrollLoadMore);
  }

  @override
  void didUpdateWidget(covariant ProfileVideosGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScrollLoadMore);
      widget.scrollController?.addListener(_onScrollLoadMore);
    }
    if (oldWidget.userId != widget.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.find<VideoController>().fetchUserVideos(widget.userId, refresh: true);
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScrollLoadMore);
    super.dispose();
  }

  void _onScrollLoadMore() {
    final c = widget.scrollController;
    if (c == null || !c.hasClients) return;
    if (c.position.extentAfter > 520) return;

    final videoController = Get.find<VideoController>();
    final uid = widget.userId;
    final isLoading = videoController.loadingUserVideosByUserId[uid] == true;
    if (isLoading || !videoController.hasMoreUserVideos(uid)) return;

    videoController.fetchUserVideos(uid, refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoController = Get.find<VideoController>();
    final uid = widget.userId;

    return Obx(() {
      final videos = videoController.userVideosByUserId[uid] ?? [];
      final isLoading = videoController.loadingUserVideosByUserId[uid] == true;
      final hasPending =
          widget.showPendingUploadSlot && videoController.hasPendingVideoPost;
      final hasMoreVideos = videoController.hasMoreUserVideos(uid);
      final tileCount = videos.length + (hasPending ? 1 : 0);

      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (videos.isEmpty && isLoading && !hasPending)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Color(0xFFB388FF),
                    ),
                  ),
                ),
              )
            else if (videos.isEmpty && !hasPending)
              const _EmptyProfileVideos()
            else
              Column(
                children: [
                  GridView.builder(
                    itemCount: tileCount,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 8),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      childAspectRatio: 9 / 14,
                    ),
                    itemBuilder: (context, index) {
                      if (hasPending && index == 0) {
                        return const _UploadingVideoTile();
                      }
                      final videoIndex = hasPending ? index - 1 : index;
                      return _ProfileVideoTile(
                        profileUserId: uid,
                        video: videos[videoIndex],
                        videoIndex: videoIndex,
                      );
                    },
                  ),
                  if (isLoading && hasMoreVideos)
                    const Padding(
                      padding: EdgeInsets.only(top: 18, bottom: 2),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFB388FF),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
    });
  }
}

class _UploadingVideoTile extends StatelessWidget {
  const _UploadingVideoTile();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.white.withValues(alpha: 0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _VideoTileFallback(),
            ColoredBox(color: Colors.black.withValues(alpha: 0.46)),
            const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFFB388FF),
                ),
              ),
            ),
            const Positioned(
              left: 6,
              right: 6,
              bottom: 8,
              child: Text(
                'Posting...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _posterImageUrl(VideoPost video) {
  final t = video.thumbnailUrl;
  if (t != null && t.isNotEmpty) return t;
  if (video.isSlideshow && video.slides.isNotEmpty) {
    return video.slides.first.url;
  }
  return null;
}

class _ProfileVideoTile extends StatelessWidget {
  const _ProfileVideoTile({
    required this.profileUserId,
    required this.video,
    required this.videoIndex,
  });

  final String profileUserId;
  final VideoPost video;
  final int videoIndex;

  @override
  Widget build(BuildContext context) {
    final poster = _posterImageUrl(video);
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProfileUserVideoFeedScreen(
            userId: profileUserId,
            initialVideoId: video.id,
            initialIndex: videoIndex,
          ),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 250),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (poster != null)
              Image.network(
                poster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _VideoTileVideoFrame(video: video),
              )
            else
              _VideoTileVideoFrame(video: video),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                video.isSlideshow
                    ? Icons.collections_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            if (video.subject.isNotEmpty)
              Positioned(
                left: 6,
                right: 6,
                top: 6,
                child: Text(
                  video.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    video.likeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTileFallback extends StatelessWidget {
  const _VideoTileFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A174B),
            Color(0xFF0B0B0B),
            Color(0xFF1E2F4A),
          ],
        ),
      ),
    );
  }
}

class _VideoTileVideoFrame extends StatefulWidget {
  const _VideoTileVideoFrame({required this.video});

  final VideoPost video;

  @override
  State<_VideoTileVideoFrame> createState() => _VideoTileVideoFrameState();
}

class _VideoTileVideoFrameState extends State<_VideoTileVideoFrame> {
  VideoPlayerController? _controller;
  bool _failedToLoadFrame = false;

  @override
  void initState() {
    super.initState();
    if (widget.video.isSlideshow && widget.video.slides.isNotEmpty) {
      return;
    }
    final playbackUrl = widget.video.playbackUrl;
    if (playbackUrl == null || playbackUrl.isEmpty) {
      _failedToLoadFrame = true;
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(playbackUrl));
    _controller = controller;
    controller.initialize().then((_) async {
      if (!mounted) return;
      await controller.seekTo(Duration.zero);
      await controller.pause();
      if (!mounted) return;
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      debugPrint('Unable to load profile video frame: $error');
      setState(() => _failedToLoadFrame = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.video.isSlideshow && widget.video.slides.isNotEmpty) {
      return Image.network(
        widget.video.slides.first.url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _VideoTileFallback(),
      );
    }
    final controller = _controller;
    if (_failedToLoadFrame ||
        controller == null ||
        !controller.value.isInitialized) {
      return const _VideoTileFallback();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _EmptyProfileVideos extends StatelessWidget {
  const _EmptyProfileVideos();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white.withValues(alpha: 0.72),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No videos yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Published videos will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

