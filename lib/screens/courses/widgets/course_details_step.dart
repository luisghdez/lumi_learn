import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_details_card.dart';
import 'package:lumi_learn_app/screens/courses/widgets/summary_card.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

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
    required this.selectedFiles,
    required this.selectedImages,
    required this.text,
    this.dueDate,
    this.classId,
  }) : super(key: key);

  bool get _canCreateCourse {
    return courseTitle.trim().isNotEmpty &&
        courseSubject.trim().isNotEmpty &&
        language.isNotEmpty &&
        visibility.isNotEmpty;
  }

  int get totalItems =>
      selectedFiles.length +
      selectedImages.length +
      (text.trim().isNotEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Step 3: Course Details",
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
        if (totalItems > 0)
          Column(
            children: [
              SummaryCard(
                totalItems: totalItems,
                fileCount: selectedFiles.length,
                imageCount: selectedImages.length,
                hasText: text.trim().isNotEmpty,
              ),
              const SizedBox(height: 24),
            ],
          ),

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

        // Create Course Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _canCreateCourse ? () => _createCourse(context) : null,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              "Create Course",
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createCourse(BuildContext context) {
    onSubmittedChanged();

    if (!_canCreateCourse) {
      Get.snackbar("Missing Information",
          "Please fill all required fields in Course Details.");
      return;
    }

    final courseController = Get.find<CourseController>();

    // Create a temporary ID for the placeholder course.
    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";

    // Add a placeholder course with a loading flag to the controller.
    courseController.addPlaceholderCourse({
      "id": tempId,
      "title": courseTitle,
      "description": courseSubject,
      "loading": true,
      "hasEmbeddings": true, // Default to false for placeholder
    });

    // Navigate immediately back to the HomeScreen.
    Get.offAll(() => MainScreen());

    // Initiate the createCourse request in the background.
    courseController
        .createCourse(
      title: courseTitle,
      description: courseSubject,
      files: [...selectedFiles, ...selectedImages],
      dueDate: dueDate,
      classId: classId,
      content: text,
      language: language,
      visibility: visibility,
    )
        .then((result) {
      courseController.removePlaceholderCourse(tempId);
      courseController.updatePlaceholderCourse(tempId, {
        "id": result['courseId'],
        'totalLessons': result['lessonCount'],
        "loading": false,
        "hasEmbeddings": result['hasEmbeddings'] ?? true,
      });
    }).catchError((error) {
      courseController.removePlaceholderCourse(tempId);
      Get.snackbar("Error", "Failed to create course");
    });
  }
}
