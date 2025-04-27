import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart'; // Import your Classroom model
import 'package:lumi_learn_app/screens/classrooms/screens/ClassroomDetails.dart';


class ClassroomCard extends StatelessWidget {
  final Classroom classroomData;
  final VoidCallback onTap;

  const ClassroomCard({
    Key? key,
    required this.classroomData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive design
    final bool isTabletOrBigger = screenWidth > 600;
    final double titleFontSize = isTabletOrBigger ? 26 : 20;
    final double subtitleFontSize = isTabletOrBigger ? 18 : 14;
    final double infoFontSize = isTabletOrBigger ? 16 : 12;
    final double viewButtonFontSize = isTabletOrBigger ? 14 : 12;
    final double paddingSize = isTabletOrBigger ? 24 : 16;
    final double coloredBarWidth = isTabletOrBigger ? 10 : 8;
    final double coloredBarHeight = isTabletOrBigger ? 160 : 140;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(paddingSize),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colored side bar
                  Container(
                    width: coloredBarWidth,
                    height: coloredBarHeight,
                    decoration: BoxDecoration(
                      color: classroomData.sideColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Row(
                          children: [
                            _InfoIconText(
                              icon: Icons.group,
                              text: "${classroomData.studentsCount} students",
                              fontSize: infoFontSize,
                            ),
                            const SizedBox(width: 16),
                            _InfoIconText(
                              icon: Icons.book,
                              text: "${classroomData.coursesCount} courses",
                              fontSize: infoFontSize,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                        onTap: () {
                          Get.to(() => ClassroomDetailsPage(classroomData: classroomData));
                        },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "View Classroom",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: viewButtonFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
