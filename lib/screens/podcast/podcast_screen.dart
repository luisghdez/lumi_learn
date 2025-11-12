// lib/screens/podcast/podcast_screen.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';
import 'package:lumi_learn_app/screens/podcast/podcast_ui.dart';

class PodcastScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String token;

  const PodcastScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.token,
  }) : super(key: key);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  late final PodcastController controller;

  @override
  void initState() {
    super.initState();
    controller = PodcastController(
      courseId: widget.courseId,
      courseTitle: widget.courseTitle,
      token: widget.token,
      context: context,
    );
    controller.init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return PodcastUI(controller: controller);
      },
    );
  }
}
