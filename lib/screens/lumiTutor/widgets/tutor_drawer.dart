import 'dart:ui';
import 'package:flutter/material.dart';

class LumiDrawer extends StatelessWidget {
  const LumiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          // Drawer content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tutor Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Saved Courses',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(3, (i) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Course Title Placeholder',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Navigate to course detail or show modal
                      },
                    );
                  }),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 10),
                  const Text(
                    'Chat History',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(3, (i) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Chat Session Placeholder',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Load previous chat
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
