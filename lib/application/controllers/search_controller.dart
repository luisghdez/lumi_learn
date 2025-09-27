import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
