// lib/widgets/header_widget.dart

import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';

class CourseOverviewHeader extends StatelessWidget {
  final Function onBack;
  final String courseTitle;
  final double progress;
  final VoidCallback onViewFlashcards;
  final VoidCallback onViewNotes;
  final VoidCallback onViewLumiTutor;
  final bool isOpeningTutor;

  const CourseOverviewHeader({
    Key? key,
    required this.onBack,
    required this.courseTitle,
    required this.progress,
    required this.onViewFlashcards,
    required this.onViewNotes,
    required this.onViewLumiTutor,
    this.isOpeningTutor = false,
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                        children: [
                          Expanded(
                            child: _HeaderButton(
                              icon: Icons.note_alt_outlined,
                              label: 'Note',
                              onTap: onViewNotes,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _HeaderButton(
                              icon: Icons.menu_book_outlined,
                              label: 'Flashcards',
                              onTap: onViewFlashcards,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _HeaderButton(
                              icon: Icons.chat_bubble_outline,
                              label: 'LumiTutor',
                              onTap: onViewLumiTutor,
                              isLoading: isOpeningTutor,
                            ),
                          ),
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

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        alignment: Alignment.center, // center the Row
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(140, 0, 0, 0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // center contents
          children: [
            if (!isLoading) ...[
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 8),
            ] else ...[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
