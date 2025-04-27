import 'dart:ui';
import 'package:flutter/material.dart';

class UpcomingCard extends StatelessWidget {
  final String eventTitle;
  final String className;
  final String dueDateText; // Example: "Due Apr 27"
  final String daysLeftText; // Example: "3 days left"
  final Color sideColor;
  final VoidCallback onTap;

  const UpcomingCard({
    Key? key,
    required this.eventTitle,
    required this.className,
    required this.dueDateText,
    required this.daysLeftText,
    required this.sideColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double titleFontSize = isTablet ? 20 : 18;
    final double subtitleFontSize = isTablet ? 16 : 14;
    final double badgeFontSize = isTablet ? 14 : 12;
    final double daysLeftFontSize = isTablet ? 14 : 12;

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top line color indicator
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: sideColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Event Title
                Text(
                  className,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Event Subtitle
                Text(
                  eventTitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Due Date and Days Left Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dueDateText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      daysLeftText,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: daysLeftFontSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
