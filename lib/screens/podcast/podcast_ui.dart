// lib/screens/podcast/podcast_ui.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_top_bar.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_card.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_info.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_progress_bar.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_controls.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_call_in_button.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_transcript.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_loading_overlay.dart';

class PodcastUI extends StatelessWidget {
  final PodcastController controller;

  const PodcastUI({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show loading overlay if needed
    if (controller.isLoading || controller.isGenerating) {
      return Stack(
        children: [
          _buildMainContent(context),
          PodcastLoadingOverlay(controller: controller),
        ],
      );
    }
    
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/black_moons_lighter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              PodcastTopBar(controller: controller),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      PodcastCard(controller: controller),
                      const SizedBox(height: 24),
                      PodcastInfo(controller: controller),
                      const SizedBox(height: 20),
                      PodcastProgressBar(controller: controller),
                      const SizedBox(height: 24),
                      PodcastControls(controller: controller),
                      const SizedBox(height: 20),
                      PodcastCallInButton(controller: controller),
                      const SizedBox(height: 32),
                      
                      // Transcript with fixed height
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
                        child: PodcastTranscript(controller: controller),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}