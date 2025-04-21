// lib/widgets/header_widget.dart

import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';

class CourseOverviewHeader extends StatelessWidget {
  final Function onBack;
  final String courseTitle;
  final double progress;
  final VoidCallback onViewFlashcards;

  const CourseOverviewHeader({
    Key? key,
    required this.onBack,
    required this.courseTitle,
    required this.progress,
    required this.onViewFlashcards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(140, 0, 0, 0),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Back button positioned to the left
                      Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 30,
                            height: 20,
                            child: IconButton(
                              iconSize: 20,
                              icon:
                                  const Icon(Icons.arrow_back_ios_new_rounded),
                              padding:
                                  EdgeInsets.zero, // Remove default padding
                              constraints:
                                  const BoxConstraints(), // Remove default minimum size
                              onPressed: () => onBack(),
                            ),
                          )),
                      // Centered text
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: courseTitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Course Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 5,
                              width: double.infinity,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, animatedProgress, child) {
                                  return LinearProgressIndicator(
                                    value: animatedProgress,
                                    backgroundColor: const Color.fromARGB(
                                        113, 158, 158, 158),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onViewFlashcards();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(140, 0, 0, 0),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'View Flashcards',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // potential Next Lesson button
                          // const SizedBox(width: 8),
                          // Expanded(
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       gradient: const LinearGradient(
                          //         colors: [
                          //           Color.fromARGB(255, 0, 0, 31),
                          //           Color.fromARGB(255, 12, 0, 22)
                          //         ],
                          //         begin: Alignment.centerLeft,
                          //         end: Alignment.centerRight,
                          //       ),
                          //       borderRadius: BorderRadius.circular(12),
                          //       border: Border.all(
                          //         color: Colors.white.withOpacity(0.2),
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: ElevatedButton(
                          //       onPressed: () {},
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors
                          //             .transparent, // Make button background transparent
                          //         shadowColor:
                          //             Colors.transparent, // Remove shadow
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(
                          //               12), // Same radius as container
                          //         ),
                          //       ),
                          //       child: const Text(
                          //         'Next Lesson',
                          //         style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 14,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
