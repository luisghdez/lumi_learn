import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/data/home_subject_catalog.dart';

// Re-export so existing imports of this controller keep seeing `Subject`.
export 'package:lumi_learn_app/data/home_subject_catalog.dart'
    show Subject, CourseCollection, courseCollections, generalSubjects, apSubjects;

class LumiSearchController extends GetxController {
  // State variables
  final Rx<Subject?> selectedSubject = Rx<Subject?>(null);
  final RxBool showSavedOnly = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> allCourses = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> savedCourses =
      <Map<String, dynamic>>[].obs; // Separate list for saved courses
  final RxBool isLoading = false.obs;
  final RxBool isPaginating =
      false.obs; // Separate loading state for pagination

  // Pagination state for all courses
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasNextPage = false.obs;
  var hasPreviousPage = false.obs;
  var totalCount = 0.obs;

  // Pagination state for saved courses
  var savedCurrentPage = 1.obs;
  var savedTotalPages = 1.obs;
  var savedHasNextPage = false.obs;
  var savedHasPreviousPage = false.obs;
  var savedTotalCount = 0.obs;

  // Dependencies
  final AuthController authController = Get.find();
  final ApiService apiService = ApiService();

  // Available subjects organized by categories (centralized in
  // home_subject_catalog.dart so they can be added/removed in one place).
  final List<Subject> subjects = generalSubjects;

  @override
  void onInit() {
    super.onInit();
    // Default to 'All Subjects' (first item)
    selectedSubject.value = subjects.first;
    // Fetch all courses when controller initializes
    fetchAllCourses(page: 1, limit: 10);
  }

  // Method to fetch all courses with optional subject filtering and pagination
  Future<void> fetchAllCourses(
      {String? subject,
      int page = 1,
      int limit = 10,
      bool isPagination = false}) async {
    if (showSavedOnly.value) {
      // Don't fetch all courses when showing saved only
      return;
    }

    // Use appropriate loading state based on operation type
    if (isPagination) {
      isPaginating.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        if (isPagination) {
          isPaginating.value = false;
        } else {
          isLoading.value = false;
        }
        return;
      }

      final response = await apiService.getAllCourses(
        token: token,
        subject: subject,
        page: page,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        allCourses.value =
            List<Map<String, dynamic>>.from(data['courses'] ?? []);

        // Update pagination state
        final pagination = data['pagination'];
        if (pagination != null) {
          currentPage.value = pagination['page'] ?? 1;
          totalPages.value = pagination['totalPages'] ?? 1;
          hasNextPage.value = pagination['hasNextPage'] ?? false;
          hasPreviousPage.value = pagination['hasPreviousPage'] ?? false;
          totalCount.value = pagination['totalCount'] ?? 0;
        }

        print(
            'Fetched ${allCourses.length} courses (page $currentPage of $totalPages)');
      } else {
        print('Failed to fetch all courses: ${response.statusCode}');
        Get.snackbar("Error", "Failed to fetch courses.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching all courses: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      // Reset appropriate loading state
      if (isPagination) {
        isPaginating.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Method to fetch saved courses with pagination (separate from home screen)
  Future<void> fetchSavedCourses({
    String? subject,
    int page = 1,
    int limit = 10,
    bool isPagination = false,
  }) async {
    print(
        'Fetching saved courses for search... page: $page, limit: $limit${subject != null ? ', subject: $subject' : ''}');

    // Use appropriate loading state based on operation type
    if (isPagination) {
      isPaginating.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        if (isPagination) {
          isPaginating.value = false;
        } else {
          isLoading.value = false;
        }
        return;
      }

      final response = await apiService.getCourses(
        token: token,
        page: page,
        limit: limit,
        subject: subject,
      );

      if (response.statusCode == 200) {
        // Parse the JSON response and store the courses
        final data = jsonDecode(response.body);
        savedCourses.value = List<Map<String, dynamic>>.from(data['courses']);

        // Update pagination state for saved courses
        final pagination = data['pagination'];
        if (pagination != null) {
          savedCurrentPage.value = pagination['page'] ?? 1;
          savedTotalPages.value = pagination['totalPages'] ?? 1;
          savedHasNextPage.value = pagination['hasNextPage'] ?? false;
          savedHasPreviousPage.value = pagination['hasPreviousPage'] ?? false;
          savedTotalCount.value = pagination['totalCount'] ?? 0;
        }

        print(
            'Fetched ${savedCourses.length} saved courses (page $savedCurrentPage of $savedTotalPages)');
      } else {
        print('Failed to fetch saved courses: ${response.statusCode}');
        Get.snackbar("Error", "Failed to fetch saved courses.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching saved courses: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      // Reset appropriate loading state
      if (isPagination) {
        isPaginating.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Convenience methods for pagination
  Future<void> fetchNextPage() async {
    if (showSavedOnly.value) {
      // Use saved courses pagination
      if (savedHasNextPage.value && !isPaginating.value) {
        final currentSubject = selectedSubject.value;
        await fetchSavedCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: savedCurrentPage.value + 1,
          limit: 10,
          isPagination: true,
        );
      }
    } else {
      // Use all courses pagination
      if (hasNextPage.value && !isPaginating.value) {
        final currentSubject = selectedSubject.value;
        await fetchAllCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: currentPage.value + 1,
          limit: 10,
          isPagination: true,
        );
      }
    }
  }

  Future<void> fetchPreviousPage() async {
    if (showSavedOnly.value) {
      // Use saved courses pagination
      if (savedHasPreviousPage.value && !isPaginating.value) {
        final currentSubject = selectedSubject.value;
        await fetchSavedCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: savedCurrentPage.value - 1,
          limit: 10,
          isPagination: true,
        );
      }
    } else {
      // Use all courses pagination
      if (hasPreviousPage.value && !isPaginating.value) {
        final currentSubject = selectedSubject.value;
        await fetchAllCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: currentPage.value - 1,
          limit: 10,
          isPagination: true,
        );
      }
    }
  }

  // Methods to update state
  void setSelectedSubject(Subject subject) {
    selectedSubject.value = subject;

    if (!showSavedOnly.value) {
      // Reset pagination when changing subjects
      currentPage.value = 1;
      // Fetch all courses for new subject
      fetchAllCourses(
          subject: subject.id == 'all' ? null : subject.name,
          page: 1,
          limit: 10);
    } else {
      // Reset saved courses pagination when changing subjects
      savedCurrentPage.value = 1;
      // Fetch saved courses for new subject using backend filtering
      fetchSavedCourses(
        subject: subject.id == 'all' ? null : subject.name,
        page: 1,
        limit: 10,
      );
    }
  }

  void toggleSavedFilter() {
    showSavedOnly.value = !showSavedOnly.value;

    if (showSavedOnly.value) {
      // When switching to "saved courses" mode, fetch courses with current subject filter
      savedCurrentPage.value = 1;
      final currentSubject = selectedSubject.value;
      fetchSavedCourses(
        subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
        page: 1,
        limit: 10,
      );
    } else {
      // When switching to "all courses" mode, reset pagination and fetch courses for current subject
      currentPage.value = 1;
      final currentSubject = selectedSubject.value;
      fetchAllCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: 1,
          limit: 10);
    }
  }

  void setSavedFilter(bool enabled) {
    showSavedOnly.value = enabled;

    if (enabled) {
      // When switching to "saved courses" mode, fetch courses with current subject filter
      savedCurrentPage.value = 1;
      final currentSubject = selectedSubject.value;
      fetchSavedCourses(
        subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
        page: 1,
        limit: 10,
      );
    } else {
      // When switching to "all courses" mode, reset pagination and fetch courses for current subject
      currentPage.value = 1;
      final currentSubject = selectedSubject.value;
      fetchAllCourses(
          subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
          page: 1,
          limit: 10);
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Method to refresh current page after deletion
  Future<void> refreshCurrentPage() async {
    if (showSavedOnly.value) {
      // Refresh saved courses with current filters
      final currentSubject = selectedSubject.value;
      await fetchSavedCourses(
        subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
        page: savedCurrentPage.value,
        limit: 10,
      );
    } else {
      // Refresh all courses with current filters
      final currentSubject = selectedSubject.value;
      await fetchAllCourses(
        subject: currentSubject?.id == 'all' ? null : currentSubject?.name,
        page: currentPage.value,
        limit: 10,
      );
    }
  }

  // Method to delete a saved course
  Future<bool> deleteSavedCourse(String courseId) async {
    try {
      // Get the user's authentication token.
      final String? token = await authController.getIdToken();
      if (token == null) {
        print("No user token found. Cannot delete course.");
        Get.snackbar(
          "Error",
          "Authentication required to delete course.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Call the API service to delete the saved course.
      final response = await apiService.deleteSavedCourse(
        token: token,
        courseId: courseId,
      );

      if (response.statusCode == 200) {
        // Remove the course from the local saved courses list
        savedCourses.removeWhere((course) => course['id'] == courseId);
        // Force reactive update
        savedCourses.refresh();

        // Update the total count
        savedTotalCount.value = savedTotalCount.value - 1;

        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          "Course Not Found",
          "This course was not found in your saved courses.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Unauthorized",
          "You are not authorized to delete this course.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      } else {
        print(
            "Failed to delete course: ${response.statusCode} ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to delete course. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print("Error deleting course: $e");
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Methods to configure search screen from other parts of the app
  void showCourseSearch({
    Subject? subject,
    bool savedOnly = false,
  }) {
    final nextSubject = subject ?? subjects.first;
    selectedSubject.value = nextSubject;
    showSavedOnly.value = savedOnly;
    searchQuery.value = '';

    final subjectFilter = nextSubject.id == 'all' ? null : nextSubject.name;
    if (savedOnly) {
      savedCurrentPage.value = 1;
      fetchSavedCourses(subject: subjectFilter, page: 1, limit: 10);
    } else {
      currentPage.value = 1;
      fetchAllCourses(subject: subjectFilter, page: 1, limit: 10);
    }
  }

  void showAllCourses() {
    showCourseSearch();
  }

  void showSavedCourses() {
    showCourseSearch(savedOnly: true);
  }

  void showCoursesForSubject(String subjectId) {
    final subject = subjects.firstWhereOrNull((s) => s.id == subjectId);
    if (subject != null) {
      selectedSubject.value = subject;
      // Reset pagination when showing courses for a specific subject
      currentPage.value = 1;
      // Fetch courses for the selected subject
      fetchAllCourses(
          subject: subject.id == 'all' ? null : subject.name,
          page: 1,
          limit: 10);
    }
    showSavedOnly.value = false;
  }

  void resetFilters() {
    selectedSubject.value = subjects.first;
    showSavedOnly.value = false;
    searchQuery.value = '';
    // Reset pagination and fetch all courses when resetting
    currentPage.value = 1;
    fetchAllCourses(page: 1, limit: 10);
  }

  // Getter for filtered courses that can be used by the UI
  List<Map<String, dynamic>> get filteredCourses {
    List<Map<String, dynamic>> courses = [];

    if (showSavedOnly.value) {
      // When showing saved courses, use the existing logic from CourseController
      // This will be handled in the UI layer
      return [];
    } else {
      // When showing all courses, use the fetched allCourses
      courses = allCourses.toList();
    }

    // Apply search query filter if any
    if (searchQuery.value.isNotEmpty) {
      courses = courses.where((course) {
        final title = course['title']?.toString().toLowerCase() ?? '';
        final subject = course['subject']?.toString().toLowerCase() ?? '';
        final tags = List<String>.from(course['tags'] ?? [])
            .map((tag) => tag.toLowerCase())
            .join(' ');
        final query = searchQuery.value.toLowerCase();

        return title.contains(query) ||
            subject.contains(query) ||
            tags.contains(query);
      }).toList();
    }

    return courses;
  }

  // Getter for status text
  String get statusText {
    String text = 'Showing ';
    String subjectName =
        selectedSubject.value?.name.toLowerCase() ?? 'all subjects';

    if (showSavedOnly.value) {
      text += selectedSubject.value?.id == 'all'
          ? 'saved courses from all subjects'
          : 'saved $subjectName courses';
    } else {
      text += selectedSubject.value?.id == 'all'
          ? 'all courses'
          : 'all $subjectName courses';
    }

    return text;
  }
}
