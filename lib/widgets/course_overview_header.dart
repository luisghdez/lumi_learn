// lib/widgets/header_widget.dart

import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/utils/course_delete_helper.dart';
import 'package:lumi_learn_app/widgets/course_options_dialog.dart';

class CourseOverviewHeader extends StatelessWidget {
  final Function onBack;
  final String courseTitle;
  final String courseId;
  final double progress;
  final VoidCallback onViewFlashcards;
  final VoidCallback onViewNotes;
  final VoidCallback onViewLumiTutor;
  final VoidCallback onViewPodcast;
  final bool isOpeningTutor;

  const CourseOverviewHeader({
    Key? key,
    required this.onBack,
    required this.courseTitle,
    required this.courseId,
    required this.progress,
    required this.onViewFlashcards,
    required this.onViewNotes,
    required this.onViewLumiTutor,
    required this.onViewPodcast,
    this.isOpeningTutor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onBack(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        courseTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Transform.translate(
                        offset: const Offset(0, -2),
                        child: IconButton(
                          iconSize: 20,
                          icon: const Icon(Icons.more_horiz),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showCourseOptionsDialog(
                              context: context,
                              courseId: courseId,
                              courseTitle: courseTitle,
                              onDelete: () async {
                                Navigator.of(context).pop();

                                final success =
                                    await CourseDeleteHelper
                                        .showDeleteConfirmationAndDelete(
                                  context: context,
                                  courseId: courseId,
                                  courseTitle: courseTitle,
                                );

                                if (success) {
                                  onBack();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
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
                      // Fixed: Use flexible layout for 4 buttons
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
                              label: 'Cards',
                              onTap: onViewFlashcards,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _HeaderButton(
                              icon: Icons.chat_bubble_outline,
                              label: 'Tutor',
                              onTap: onViewLumiTutor,
                              isLoading: isOpeningTutor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _HeaderButton(
                              icon: Icons.podcasts,
                              label: 'Cast',
                              onTap: onViewPodcast,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(140, 0, 0, 0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(height: 4),
            ] else ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}