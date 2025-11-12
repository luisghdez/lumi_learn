// lib/screens/podcast/widget/podcast_call_in_button.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastCallInButton extends StatelessWidget {
  final PodcastController controller;

  const PodcastCallInButton({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading || controller.isGenerating || controller.segments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: controller.handleCallIn,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: controller.isRecording
                ? LinearGradient(
                    colors: [
                      const Color(0xFFE85D75).withOpacity(0.9),
                      const Color(0xFFD84B63).withOpacity(0.9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF00012D).withOpacity(0.8), // More transparent
                      const Color(0xFF3A005A).withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // Add border for brightness
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (controller.isRecording
                        ? const Color(0xFFE85D75)
                        : const Color(0xFF3A005A))
                    .withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                controller.isRecording ? 'Stop Recording' : 'Call In',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}