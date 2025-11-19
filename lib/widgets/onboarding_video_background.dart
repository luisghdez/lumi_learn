import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Shared video background component for onboarding screens
/// This ensures the video plays continuously across different onboarding steps
class OnboardingVideoBackground extends StatelessWidget {
  final VideoPlayerController videoController;
  final Widget child;

  const OnboardingVideoBackground({
    super.key,
    required this.videoController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Background
        if (videoController.value.isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: VideoPlayer(videoController),
              ),
            ),
          )
        else
          // Fallback background if video not initialized
          Positioned.fill(
            child: Image.asset(
              'assets/galaxies/galaxy1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

        // Semi-transparent overlay to make content readable
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}
