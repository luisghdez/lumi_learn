import 'package:flutter/material.dart';

class GalaxyHeader extends StatelessWidget {
  final bool isEditing;

  const GalaxyHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌌 Fullscreen Galaxy Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/black_moons_lighter.png',
            fit: BoxFit.cover,
          ),
        ),

        // Add other widgets over the background here if needed
      ],
    );
  }
}
