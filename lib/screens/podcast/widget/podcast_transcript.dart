// lib/screens/podcast/widget/podcast_transcript.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastTranscript extends StatelessWidget {
  final PodcastController controller;

  const PodcastTranscript({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.currentDialogue.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 73, 73, 73).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ...controller.currentDialogue.asMap().entries.map((entry) {
            return _buildTranscriptLine(
              index: entry.key,
              line: entry.value,
              isCurrentLine: entry.key == controller.currentLineIndex,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6B5B95).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.subtitles_rounded,
            color: Color(0xFF9B8FD7),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Transcript',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptLine({
    required int index,
    required dynamic line,
    required bool isCurrentLine,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentLine 
            ? const Color(0xFF6B5B95).withOpacity(0.3) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentLine 
              ? const Color(0xFF9B8FD7) 
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: line.speaker.contains('A')
                        ? [const Color(0xFF7B6BA8), const Color(0xFF6B5B95)]
                        : [const Color(0xFF5B9FD7), const Color(0xFF4A8FC7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    line.speaker.contains('A') ? 'A' : 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                line.speaker,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrentLine 
                      ? const Color(0xFF9B8FD7) 
                      : Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            line.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isCurrentLine 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}