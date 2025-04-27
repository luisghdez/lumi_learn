import 'dart:ui'; // For glass effect
import 'package:flutter/material.dart';

class EmptyClassroomCard extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyClassroomCard({Key? key, required this.onCreate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return GestureDetector(
      onTap: onCreate,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isTabletOrBigger ? 32 : 24,
              vertical: isTabletOrBigger ? 36 : 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white70,
                  size: isTabletOrBigger ? 60 : 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Create your first classroom!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTabletOrBigger ? 22 : 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start by creating a new classroom and invite your students.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isTabletOrBigger ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
