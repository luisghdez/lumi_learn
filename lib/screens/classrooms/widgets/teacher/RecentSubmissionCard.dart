import 'dart:ui';
import 'package:flutter/material.dart';

class RecentSubmissionCard extends StatelessWidget {
  final String submissionTitle;
  final String studentName;
  final String className;
  final String timeAgo;
  final Color sideColor;
  final VoidCallback? onTap;

  const RecentSubmissionCard({
    super.key,
    required this.submissionTitle,
    required this.studentName,
    required this.className,
    required this.timeAgo,
    required this.sideColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;
    final double titleFontSize = isTabletOrBigger ? 22 : 18;
    final double subtitleFontSize = isTabletOrBigger ? 16 : 14;
    final double timeFontSize = isTabletOrBigger ? 14 : 12;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isTabletOrBigger ? 24 : 20,
              horizontal: isTabletOrBigger ? 24 : 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored side bar
                Container(
                  width: isTabletOrBigger ? 8 : 6,
                  height: isTabletOrBigger ? 120 : 100,
                  decoration: BoxDecoration(
                    color: sideColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),

                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submissionTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$studentName • $className',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: timeFontSize,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: isTabletOrBigger ? 28 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
