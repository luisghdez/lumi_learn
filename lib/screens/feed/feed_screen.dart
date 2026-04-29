import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const int _feedNavIndex = 0;

  final PageController _pageController = PageController();
  final NavigationController _navigationController = Get.find();
  late final List<VideoPlayerController> _videoControllers;
  late final Worker _navIndexWorker;
  int _currentIndex = 0;

  static const List<_FeedVideo> _videos = [
    _FeedVideo(
      assetPath: 'assets/videos/onboardingVideo.mp4',
      creator: '@lumi',
      title: 'Photosynthesis in 30 seconds',
      description:
          'Plants turn sunlight, water, and carbon dioxide into energy.',
      subject: 'Biology',
      likes: '12.8K',
      saves: '2.1K',
    ),
    _FeedVideo(
      assetPath: 'assets/videos/onboardingvideo1.1.mp4',
      creator: '@studybits',
      title: 'Why gravity bends light',
      description:
          'A quick visual intuition for spacetime curvature and lenses.',
      subject: 'Physics',
      likes: '8.4K',
      saves: '1.7K',
    ),
    _FeedVideo(
      assetPath: 'assets/videos/onboardingVideo.mp4',
      creator: '@mathspark',
      title: 'The trick behind slope',
      description: 'Rise over run is just a rate of change you can see.',
      subject: 'Algebra',
      likes: '15.3K',
      saves: '3.6K',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _videoControllers = _videos
        .map((video) => VideoPlayerController.asset(video.assetPath))
        .toList();
    _navIndexWorker = ever<int>(
      _navigationController.currentIndex,
      _handleNavIndexChanged,
    );
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    for (var i = 0; i < _videoControllers.length; i++) {
      final controller = _videoControllers[i];
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) return;

      if (i == _currentIndex && _isFeedActive) {
        await controller.play();
      }

      setState(() {});
    }
  }

  void _handlePageChanged(int index) {
    _videoControllers[_currentIndex].pause();
    _currentIndex = index;

    final controller = _videoControllers[index];
    if (_isFeedActive && controller.value.isInitialized) {
      controller.play();
    }

    setState(() {});
  }

  void _handleNavIndexChanged(int index) {
    if (index == _feedNavIndex) {
      final controller = _videoControllers[_currentIndex];
      if (controller.value.isInitialized) {
        controller.play();
      }
    } else {
      for (final controller in _videoControllers) {
        controller.pause();
      }
    }
  }

  void _togglePlayback() {
    if (!_isFeedActive) return;

    final controller = _videoControllers[_currentIndex];
    if (!controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _navIndexWorker.dispose();
    _pageController.dispose();
    for (final controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isFeedActive =>
      _navigationController.currentIndex.value == _feedNavIndex;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) {
          return _FeedVideoPage(
            video: _videos[index],
            controller: _videoControllers[index],
            isCurrent: index == _currentIndex,
            onTap: _togglePlayback,
          );
        },
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
  });

  final _FeedVideo video;
  final VideoPlayerController controller;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _VideoBackdrop(controller: controller),
          const _FeedGradientOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FeedHeader(),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _VideoDetails(video: video)),
                      const SizedBox(width: 20),
                      _ActionRail(video: video),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrent &&
              controller.value.isInitialized &&
              !controller.value.isPlaying)
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

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
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
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
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
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
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
        Text(
          'Swipe up',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VideoDetails extends StatelessWidget {
  const _VideoDetails({required this.video});

  final _FeedVideo video;

  @override
  Widget build(BuildContext context) {
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
            video.subject,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          video.creator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          video.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          video.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.84),
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.video});

  final _FeedVideo video;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FeedActionButton(
          icon: Icons.favorite_border,
          label: video.likes,
        ),
        const SizedBox(height: 18),
        _FeedActionButton(
          icon: Icons.bookmark_border,
          label: video.saves,
        ),
        const SizedBox(height: 18),
        const _FeedActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
        ),
      ],
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 27),
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
    );
  }
}

class _FeedVideo {
  const _FeedVideo({
    required this.assetPath,
    required this.creator,
    required this.title,
    required this.description,
    required this.subject,
    required this.likes,
    required this.saves,
  });

  final String assetPath;
  final String creator;
  final String title;
  final String description;
  final String subject;
  final String likes;
  final String saves;
}
