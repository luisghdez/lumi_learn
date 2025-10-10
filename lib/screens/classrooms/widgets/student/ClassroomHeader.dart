import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';

class ClassroomHeaderCard extends StatelessWidget {
  final Classroom classroom;

  const ClassroomHeaderCard({Key? key, required this.classroom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final double titleFontSize = isTablet ? 24 : 20;
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
              // Colored top line (just like ClassroomCardBox)
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: classroom.sideColor,
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
                      classroom.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      classroom.subtitle,
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
                          text: "${classroom.studentsCount} students",
                          fontSize: infoFontSize,
                        ),
                        const SizedBox(width: 16),
                        _InfoIconText(
                          icon: Icons.book,
                          text: "${classroom.coursesCount} courses",
                          fontSize: infoFontSize,
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
