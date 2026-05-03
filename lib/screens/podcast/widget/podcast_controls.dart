// lib/screens/podcast/widget/podcast_controls.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastControls extends StatelessWidget {
  final PodcastController controller;

  const PodcastControls({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            size: 32,
            enabled: controller.currentSegmentIndex > 0,
            onPressed: controller.currentSegmentIndex > 0
                ? controller.previousSegment
                : null,
          ),
          
          const SizedBox(width: 20),
          
          // Play/Pause Button
          _buildPlayPauseButton(),
          
          const SizedBox(width: 20),
          
          // Next Button
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            size: 32,
            enabled: controller.currentSegmentIndex < controller.segments.length - 1,
            onPressed: controller.currentSegmentIndex < controller.segments.length - 1
                ? controller.nextSegment
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00012D).withOpacity(0.9),
            const Color(0xFF3A005A).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.5), // Added border!
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A005A).withOpacity(0.6),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Colors.white,
        ),
        onPressed: controller.segments.isNotEmpty && !controller.isGenerating
            ? controller.togglePlayback
            : null,
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.4),
        ),
        onPressed: onPressed,
      ),
    );
  }
}