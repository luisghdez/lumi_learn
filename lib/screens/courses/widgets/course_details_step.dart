import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_details_card.dart';
import 'package:lumi_learn_app/screens/courses/widgets/summary_card.dart';

class CourseDetailsStep extends StatelessWidget {
  final String courseTitle;
  final String courseSubject;
  final String language;
  final String visibility;
  final bool submitted;
  final Function(String) onTitleChanged;
  final Function(String) onSubjectChanged;
  final Function(String) onLanguageChanged;
  final Function(String) onVisibilityChanged;
  final Function() onSubmittedChanged;
  final VoidCallback onCreateCourse;
  final List<File> selectedFiles;
  final List<File> selectedImages;
  final String text;
  final DateTime? dueDate;
  final String? classId;

  const CourseDetailsStep({
    Key? key,
    required this.courseTitle,
    required this.courseSubject,
    required this.language,
    required this.visibility,
    required this.submitted,
    required this.onTitleChanged,
    required this.onSubjectChanged,
    required this.onLanguageChanged,
    required this.onVisibilityChanged,
    required this.onSubmittedChanged,
    required this.onCreateCourse,
    required this.selectedFiles,
    required this.selectedImages,
    required this.text,
    this.dueDate,
    this.classId,
  }) : super(key: key);

  int get totalItems =>
      selectedFiles.length +
      selectedImages.length +
      (text.trim().isNotEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Course Details",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Fill in the course information",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        /// CONTENT SUMMARY
        // if (totalItems > 0)
        //   Column(
        //     children: [
        //       SummaryCard(
        //         totalItems: totalItems,
        //         fileCount: selectedFiles.length,
        //         imageCount: selectedImages.length,
        //         hasText: text.trim().isNotEmpty,
        //       ),
        //       const SizedBox(height: 24),
        //     ],
        //   ),

        // Course Details Section
        CourseDetailsCard(
          title: courseTitle,
          subject: courseSubject,
          onTitleChanged: onTitleChanged,
          onSubjectChanged: onSubjectChanged,
          language: language,
          visibility: visibility,
          onLanguageChanged: onLanguageChanged,
          onVisibilityChanged: onVisibilityChanged,
          titleError: submitted && courseTitle.trim().isEmpty,
          subjectError: submitted && courseSubject.trim().isEmpty,
          languageError: submitted && language.isEmpty,
          visibilityError: submitted && visibility.isEmpty,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
