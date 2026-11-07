import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/screens/ap_catalog/ap_course_overview_screen.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';

class ApCatalogController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  final RxList<ApSubject> subjects = <ApSubject>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxBool isStartingCourse = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCatalog();
  }

  /// Saves the AP course (if not already saved), loads its lessons into
  /// [CourseController], then navigates to [ApCourseOverviewScreen].
  Future<void> startCourse(ApSubject subject) async {
    if (isStartingCourse.value) return;
    isStartingCourse.value = true;
    final courseController = Get.find<CourseController>();
    try {
      final saved = courseController.courses.any((c) => c['id'] == subject.courseId) ||
          await courseController.saveSharedCourse(subject.courseId, subject.title);
      if (!saved) throw StateError('Could not save course');
      final loaded = await courseController.setSelectedCourseId(subject.courseId, subject.title);
      if (!loaded || courseController.lessons.isEmpty) {
        throw StateError('Could not load course');
      }
      Get.to(
        () => const ApCourseOverviewScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (_) {
      Get.snackbar('Could not start course', 'Please check your connection and try again.',
          backgroundColor: Colors.black87, colorText: Colors.white);
    } finally {
      isStartingCourse.value = false;
    }
  }

  Future<void> fetchCatalog() async {
    isLoading.value = true;
    error.value = '';

    try {
      final token = await _auth.getIdToken();
      if (token == null) {
        error.value = 'Not authenticated';
        return;
      }

      final response = await ApiService().getApCatalogCourses(token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (data['courses'] as List<dynamic>? ?? []);
        subjects.value = raw
            .map((c) => apSubjectFromApiCourse(c as Map<String, dynamic>))
            .toList();
      } else {
        error.value = 'Failed to load catalog (${response.statusCode})';
      }
    } catch (e) {
      error.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
