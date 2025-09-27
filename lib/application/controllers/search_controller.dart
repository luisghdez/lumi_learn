import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final IconData icon;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class LumiSearchController extends GetxController {
  // State variables
  final Rx<Subject?> selectedSubject = Rx<Subject?>(null);
  final RxBool showSavedOnly = false.obs;
  final RxString searchQuery = ''.obs;

  // Available subjects
  final List<Subject> subjects = const [
    Subject(id: 'all', name: 'All Subjects', icon: Icons.apps),
    Subject(id: 'math', name: 'Mathematics', icon: Icons.calculate),
    Subject(id: 'physics', name: 'Physics', icon: Icons.science),
    Subject(id: 'english', name: 'English', icon: Icons.menu_book),
    Subject(id: 'biology', name: 'Biology', icon: Icons.biotech),
    Subject(id: 'chemistry', name: 'Chemistry', icon: Icons.bubble_chart),
    Subject(id: 'history', name: 'History', icon: Icons.history_edu),
    Subject(
        id: 'computer_science', name: 'Computer Science', icon: Icons.computer),
    Subject(id: 'economics', name: 'Economics', icon: Icons.trending_up),
    Subject(id: 'psychology', name: 'Psychology', icon: Icons.psychology),
    Subject(id: 'sociology', name: 'Sociology', icon: Icons.groups),
    Subject(id: 'philosophy', name: 'Philosophy', icon: Icons.lightbulb),
    Subject(id: 'art', name: 'Art & Design', icon: Icons.palette),
    Subject(id: 'music', name: 'Music', icon: Icons.music_note),
    Subject(id: 'languages', name: 'Foreign Languages', icon: Icons.translate),
  ];

  @override
  void onInit() {
    super.onInit();
    // Default to 'All Subjects'
    selectedSubject.value = subjects.first;
  }

  // Methods to update state
  void setSelectedSubject(Subject subject) {
    selectedSubject.value = subject;
  }

  void toggleSavedFilter() {
    showSavedOnly.value = !showSavedOnly.value;
  }

  void setSavedFilter(bool enabled) {
    showSavedOnly.value = enabled;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Methods to configure search screen from other parts of the app
  void showSavedCourses() {
    showSavedOnly.value = true;
    selectedSubject.value = subjects.first; // All subjects
  }

  void showCoursesForSubject(String subjectId) {
    final subject = subjects.firstWhereOrNull((s) => s.id == subjectId);
    if (subject != null) {
      selectedSubject.value = subject;
    }
    showSavedOnly.value = false;
  }

  void resetFilters() {
    selectedSubject.value = subjects.first;
    showSavedOnly.value = false;
    searchQuery.value = '';
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
