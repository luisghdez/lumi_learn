// lib/widgets/header_widget.dart

import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';

class CourseOverviewHeader extends StatelessWidget {
  final Function onBack;
  final String lessonTitle;

  const CourseOverviewHeader({
    Key? key,
    required this.onBack,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Rounds all corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          // Add padding to account for status bar and provide spacing.
          decoration: BoxDecoration(
            color: const Color.fromARGB(140, 0, 0, 0),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2), // Light border color.
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color.fromARGB(131, 255, 255, 255),
                ),
                onPressed: () {
                  onBack();
                },
              ),
              const SizedBox(width: 16),
              // Lesson title and bold "Math Galaxy"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 14.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: lessonTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w100),
                      children: const [
                        TextSpan(
                          text: ' Galaxy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
