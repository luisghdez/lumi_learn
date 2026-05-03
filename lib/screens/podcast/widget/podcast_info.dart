// lib/screens/podcast/widget/podcast_info.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastInfo extends StatelessWidget {
  final PodcastController controller;

  const PodcastInfo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Changed to white
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hosted by Lumi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7), // Changed to white with opacity
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (controller.currentSegmentTopic.isEmpty ||
        controller.currentSegmentTopic == 'Loading...' ||
        controller.currentSegmentTopic.toLowerCase().startsWith('segment')) {
      return 'Tech Horizons';
    }
    return controller.currentSegmentTopic;
  }
}