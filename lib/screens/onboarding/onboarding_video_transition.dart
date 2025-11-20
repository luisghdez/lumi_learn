import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingVideoTransition extends StatefulWidget {
  final VideoPlayerController videoController;
  final VoidCallback onComplete;

  const OnboardingVideoTransition({
    super.key,
    required this.videoController,
    required this.onComplete,
  });

  @override
  State<OnboardingVideoTransition> createState() =>
      _OnboardingVideoTransitionState();
}

class _OnboardingVideoTransitionState extends State<OnboardingVideoTransition> {
  bool _hasCompleted = false;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _playVideo();
  }

  void _playVideo() async {
    try {
      // Ensure video is initialized
      if (!widget.videoController.value.isInitialized) {
        await widget.videoController.initialize();
      }

      // Reset video to beginning and set full volume
      await widget.videoController.seekTo(Duration.zero);
      await widget.videoController.setVolume(1.0);

      // Small delay to ensure seek completes
      await Future.delayed(const Duration(milliseconds: 100));

      // Listen for video completion BEFORE playing
      widget.videoController.addListener(_videoListener);

      // Play the video
      await widget.videoController.play();

      // Force a rebuild to show the playing video
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error playing video: $e');
      // If there's an error, just complete immediately
      if (!_hasCompleted) {
        _hasCompleted = true;
        widget.onComplete();
      }
    }
  }

  void _videoListener() {
    if (!mounted || _hasCompleted) return;

    final position = widget.videoController.value.position;
    final duration = widget.videoController.value.duration;

    // Start fading out audio 3 seconds before the end
    if (duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 3000 &&
        !_isFadingOut) {
      _isFadingOut = true;
      _fadeOutAudio();
    }

    // Navigate to next screen 2 seconds before video ends
    // This allows the next screen to fade in while the video is still playing
    if (duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 2500 &&
        !_hasCompleted) {
      _hasCompleted = true;
      // We don't wait for video to stop or finish. We just hand off.
      if (mounted) {
        widget.onComplete();
      }
    }
  }

  void _fadeOutAudio() async {
    // Fade out over 2 seconds
    const steps = 20;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = steps; i >= 0; i--) {
      if (!mounted || _hasCompleted) break;

      final volume = i / steps;
      await widget.videoController.setVolume(volume);
      await Future.delayed(stepDuration);
    }
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen video
          if (widget.videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.videoController.value.size.width,
                  height: widget.videoController.value.size.height,
                  child: VideoPlayer(widget.videoController),
                ),
              ),
            )
          else
            // Black screen while video prepares
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
