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
    return SizedBox(
      height: 60,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(140, 0, 0, 0),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button positioned to the left
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    iconSize: 20,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color.fromARGB(131, 255, 255, 255),
                    ),
                    onPressed: () => onBack(),
                  ),
                ),
                // Centered text
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: lessonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w100,
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
