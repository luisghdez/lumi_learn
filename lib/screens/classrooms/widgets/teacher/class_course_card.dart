import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';

class ClassroomCardBox extends StatelessWidget {
  final Classroom classroomData;

  const ClassroomCardBox({Key? key, required this.classroomData})
      : super(key: key);

  void _showShareClassCode(BuildContext context, String code) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          backgroundColor: Colors.transparent, // transparent shell
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Classroom Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Share this code with students to join your classroom!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double titleFontSize = isTablet ? 26 : 22;
    final double subtitleFontSize = isTablet ? 18 : 14;
    final double infoFontSize = isTablet ? 16 : 12;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored top line
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: classroomData.sideColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                          text: "${classroomData.studentsCount} Students",
                          fontSize: infoFontSize,
                        ),
                        const SizedBox(width: 16),
                        _InfoIconText(
                          icon: Icons.book,
                          text: "${classroomData.coursesCount} Courses",
                          fontSize: infoFontSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              backgroundColor: Colors.white.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Get.to(() => const CourseCreation(),
                                  transition: Transition.fadeIn);
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              "New Course",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              backgroundColor: Colors.white.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              _showShareClassCode(
                                  context, classroomData.inviteCode);
                            },
                            icon: const Icon(Icons.share, color: Colors.white),
                            label: const Text(
                              "Share Code",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget
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
