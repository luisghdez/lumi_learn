import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';

class Subject {
  final String id;
  final String name;
  final IconData icon;
  final bool isHeader;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    this.isHeader = false,
  });
}

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

  // Available subjects organized by categories
  final List<Subject> subjects = const [
    Subject(id: 'all', name: 'All Subjects', icon: Icons.apps),

    // Math category header
    Subject(
        id: 'math_header', name: 'Math', icon: Icons.calculate, isHeader: true),
    Subject(id: 'algebra', name: 'Algebra', icon: Icons.functions),
    Subject(id: 'geometry', name: 'Geometry', icon: Icons.change_history),
    Subject(id: 'statistics', name: 'Statistics', icon: Icons.bar_chart),
    Subject(id: 'calculus', name: 'Calculus', icon: Icons.timeline),

    // Science category header
    Subject(
        id: 'science_header',
        name: 'Science',
        icon: Icons.science,
        isHeader: true),
    Subject(id: 'biology', name: 'Biology', icon: Icons.biotech),
    Subject(id: 'chemistry', name: 'Chemistry', icon: Icons.bubble_chart),
    Subject(id: 'physics', name: 'Physics', icon: Icons.scatter_plot),
    Subject(
        id: 'earth_space', name: 'Earth & Space Science', icon: Icons.public),
    Subject(
        id: 'environmental', name: 'Environmental Science', icon: Icons.eco),
    Subject(
        id: 'computer_science', name: 'Computer Science', icon: Icons.computer),

    // Social Studies category header
    Subject(
        id: 'social_header',
        name: 'Social Studies',
        icon: Icons.history_edu,
        isHeader: true),
    Subject(id: 'world_history', name: 'World History', icon: Icons.language),
    Subject(id: 'us_history', name: 'U.S. History', icon: Icons.flag),
    Subject(
        id: 'european_history', name: 'European History', icon: Icons.castle),
    Subject(id: 'art_history', name: 'Art History', icon: Icons.museum),
    Subject(id: 'psychology', name: 'Psychology', icon: Icons.psychology),
    Subject(id: 'sociology', name: 'Sociology', icon: Icons.groups),
    Subject(id: 'philosophy', name: 'Philosophy', icon: Icons.lightbulb),

    // Business & Economics category header
    Subject(
        id: 'business_header',
        name: 'Business & Economics',
        icon: Icons.business,
        isHeader: true),
    Subject(id: 'accounting', name: 'Accounting', icon: Icons.account_balance),
    Subject(id: 'finance', name: 'Finance', icon: Icons.attach_money),
    Subject(id: 'marketing', name: 'Marketing', icon: Icons.campaign),
    Subject(
        id: 'general_business',
        name: 'General Business',
        icon: Icons.business_center),
    Subject(
        id: 'microeconomics', name: 'Microeconomics', icon: Icons.trending_up),
    Subject(
        id: 'macroeconomics', name: 'Macroeconomics', icon: Icons.show_chart),

    // Other category header
    Subject(
        id: 'other_header',
        name: 'Other',
        icon: Icons.more_horiz,
        isHeader: true),
    Subject(id: 'music', name: 'Music', icon: Icons.music_note),
    Subject(id: 'art_design', name: 'Art & Design', icon: Icons.palette),
    Subject(
        id: 'foreign_languages',
        name: 'Foreign Languages',
        icon: Icons.translate),
  ];

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

  // Methods to configure search screen from other parts of the app
  void showSavedCourses() {
    showSavedOnly.value = true;
    selectedSubject.value = subjects.first; // All subjects

    // Fetch courses with subject filter when navigating from "view all"
    savedCurrentPage.value = 1;
    fetchSavedCourses(page: 1, limit: 10);
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
