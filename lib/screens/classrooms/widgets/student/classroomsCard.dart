import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/screens/ClassroomDetails.dart';

class StudentClassroomCard extends StatelessWidget {
  final Classroom classroomData;
  final VoidCallback onTap;

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      // Same day
      return "Today, ${_formatTime(dueDate)}";
    } else if (difference.inDays == 1) {
      return "Tomorrow, ${_formatTime(dueDate)}";
    } else {
      return "${dueDate.month}/${dueDate.day}, ${_formatTime(dueDate)}";
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  const StudentClassroomCard({
    Key? key,
    required this.classroomData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    final double titleFontSize = isTabletOrBigger ? 24 : 20;
    final double subtitleFontSize = isTabletOrBigger ? 18 : 14;
    final double infoFontSize = isTabletOrBigger ? 16 : 12;
    final double buttonFontSize = isTabletOrBigger ? 16 : 14;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(isTabletOrBigger ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and subtitle
              Text(
                classroomData.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                classroomData.subtitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: subtitleFontSize,
                ),
              ),
              const SizedBox(height: 16),

              // Students and Courses
              Row(
                children: [
                  _InfoIconText(
                    icon: Icons.group,
                    text: "${classroomData.studentsCount} Students",
                    fontSize: infoFontSize,
                  ),
                  const SizedBox(width: 16),
                  _InfoIconText(
                    icon: Icons.book,
                    text:
                        "${classroomData.coursesCount} courses", // Static for now, you can change
                    fontSize: infoFontSize,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: (classroomData.totalCourses > 0
                                ? (classroomData.completedCourses /
                                    classroomData.totalCourses)
                                : 0) *
                            MediaQuery.of(context).size.width *
                            0.6, // 60% of screen width
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      classroomData.totalCourses > 0
                          ? "${((classroomData.completedCourses / classroomData.totalCourses) * 100).toStringAsFixed(0)}%"
                          : "0%",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Next lesson
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white54, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    classroomData.nextDueAt != null
                        ? "Next Lesson Due ${_formatDueDate(classroomData.nextDueAt!)}"
                        : "No upcoming lessons",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Enter Classroom Button
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Enter Classroom",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: buttonFontSize,
                      ),
                    ),
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

class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double fontSize;

  const _InfoIconText({
    Key? key,
    required this.icon,
    required this.text,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: fontSize + 6),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white60,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
