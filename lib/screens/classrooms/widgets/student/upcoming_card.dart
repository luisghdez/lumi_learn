import 'dart:ui';
import 'package:flutter/material.dart';
class UpcomingCard extends StatelessWidget {
  final String eventTitle;
  final String className;
  final DateTime dueAt; // 🆕 Real DateTime
  final Color sideColor;

  const UpcomingCard({
    Key? key,
    required this.eventTitle,
    required this.className,
    required this.dueAt, // 🆕
    required this.sideColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double titleFontSize = isTablet ? 20 : 18;
    final double subtitleFontSize = isTablet ? 16 : 14;
    final double badgeFontSize = isTablet ? 14 : 12;
    final double daysLeftFontSize = isTablet ? 14 : 12;

    final now = DateTime.now();
    final int daysLeft = dueAt.difference(now).inDays;
    final String dueDateText = _formatDueDate(dueAt);
    final String daysLeftText = _formatDaysLeft(daysLeft);

    return GestureDetector(
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

                // Class Name
                Text(
                  className,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Event Title
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

  String _formatDueDate(DateTime dueDate) {
    // Example: "Due Apr 27"
    return "Due ${_monthName(dueDate.month)} ${dueDate.day}";
  }

  String _formatDaysLeft(int daysLeft) {
    if (daysLeft == 0) {
      return "Today";
    } else if (daysLeft == 1) {
      return "Tomorrow";
    } else {
      return "$daysLeft days left";
    }
  }

  String _monthName(int monthNumber) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[monthNumber - 1];
  }
}
