import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';

/// Helper class for course deletion functionality
/// Provides reusable delete logic for both RegularCategoryCard and CategoryCard
class CourseDeleteHelper {
  /// Shows confirmation dialog and handles course deletion
  /// Returns true if deletion was successful, false otherwise
  static Future<bool> showDeleteConfirmationAndDelete({
    required BuildContext context,
    required String courseId,
    required String courseTitle,
  }) async {
    // Show confirmation dialog
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove "$courseTitle" from your saved courses?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    // Try both controllers and use the one that succeeds
    bool deleteSuccess = false;

    // Try CourseController first (for home screen)
    try {
      final courseController = Get.find<CourseController>();
      print('CourseDeleteHelper: Using CourseController for deletion');
      deleteSuccess = await courseController.deleteSavedCourse(courseId);

      // If successful with CourseController, refresh the home courses
      if (deleteSuccess) {
        print(
            'CourseDeleteHelper: Deletion successful, refreshing home courses');
        await courseController.refreshHomeCourses();
        print('CourseDeleteHelper: Home courses refresh completed');
        return true;
      }
    } catch (e) {
      print('CourseController not available or failed: $e');
    }

    // If CourseController failed, try SearchController (for search screen)
    try {
      final searchController = Get.find<LumiSearchController>();
      deleteSuccess = await searchController.deleteSavedCourse(courseId);

      // If successful with SearchController, refresh the current page
      if (deleteSuccess) {
        await searchController.refreshCurrentPage();
        return true;
      }
    } catch (e2) {
      print('SearchController not available or failed: $e2');
    }

    // If both controllers failed
    if (!deleteSuccess) {
      Get.snackbar(
        "Error",
        "Failed to delete course. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    return deleteSuccess;
  }
}
