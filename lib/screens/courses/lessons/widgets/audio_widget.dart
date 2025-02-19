import 'package:flutter/material.dart';

class AudioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Realistic Waveform Visualization
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RealisticAudioWaveform(),
            ),
          ),
          // Microphone Icon Button
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24, // Light circle behind mic icon
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white, size: 50),
              onPressed: () {
                // TODO: Handle microphone tap
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Realistic Waveform Widget
class RealisticAudioWaveform extends StatelessWidget {
  final List<double> waveHeights = [
    10,
    20,
    35,
    25,
    40,
    60,
    45,
    30,
    50,
    20,
    15,
    10,
    25,
    35,
    45,
    40,
    30,
    20,
    10,
    10,
    20,
    35,
    25,
    40,
    60,
    45,
    30,
    50,
    20,
    15,
    10,
    25,
    35,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: waveHeights.map((height) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4, // Bar width
          height: height, // Varying heights to simulate a waveform
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}
