import 'package:flutter/material.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';

/// A single selectable subject (or a non-selectable category header) used by
/// the course search filters.
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

/// A top-level grouping of subjects shown in the first dropdown of the home
/// search (e.g. "All Courses" vs "AP Courses"). Add or remove a collection
/// here and the home search updates automatically.
class CourseCollection {
  final String id;
  final String label;
  final IconData icon;
  final List<Subject> subjects;

  const CourseCollection({
    required this.id,
    required this.label,
    required this.icon,
    required this.subjects,
  });

  /// First real (non-header) subject in the collection.
  Subject get defaultSubject =>
      subjects.firstWhere((subject) => !subject.isHeader);
}

/// General (non-AP) subjects. This is the canonical list used across the app.
const List<Subject> generalSubjects = [
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
  Subject(id: 'earth_space', name: 'Earth & Space Science', icon: Icons.public),
  Subject(id: 'environmental', name: 'Environmental Science', icon: Icons.eco),
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
  Subject(id: 'european_history', name: 'European History', icon: Icons.castle),
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
  Subject(id: 'microeconomics', name: 'Microeconomics', icon: Icons.trending_up),
  Subject(id: 'macroeconomics', name: 'Macroeconomics', icon: Icons.show_chart),

  // Other category header
  Subject(
      id: 'other_header', name: 'Other', icon: Icons.more_horiz, isHeader: true),
  Subject(id: 'music', name: 'Music', icon: Icons.music_note),
  Subject(id: 'art_design', name: 'Art & Design', icon: Icons.palette),
  Subject(
      id: 'foreign_languages',
      name: 'Foreign Languages',
      icon: Icons.translate),
];

/// Icon per onboarding [subjectCatalog] category, reused for AP subjects so the
/// AP list and onboarding stay visually consistent.
const Map<String, IconData> _categoryIcons = {
  'Sciences': Icons.science,
  'Computer Science & Technology': Icons.computer,
  'PE & Health': Icons.health_and_safety,
  'Maths': Icons.calculate,
  'Humanities & Social Sciences': Icons.history_edu,
  'English & Literature': Icons.menu_book,
  'Arts & Music': Icons.palette,
  'Foreign Languages': Icons.translate,
};

String _slug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

/// AP subjects derived directly from the onboarding [subjectCatalog]. Any AP
/// course added/removed there flows through to the home search automatically.
List<Subject> _buildApSubjects() {
  final List<Subject> result = [];
  for (final category in subjectCatalog) {
    final apSubjects =
        category.subjects.where((name) => name.startsWith('AP ')).toList();
    if (apSubjects.isEmpty) continue;

    final icon = _categoryIcons[category.title] ?? Icons.school;
    result.add(Subject(
      id: '${_slug(category.title)}_header',
      name: category.title,
      icon: icon,
      isHeader: true,
    ));
    for (final name in apSubjects) {
      result.add(Subject(id: 'ap_${_slug(name)}', name: name, icon: icon));
    }
  }
  return result;
}

final List<Subject> apSubjects = _buildApSubjects();

/// The course collections shown in the first dropdown. Add or remove entries
/// here to change the top-level options.
final List<CourseCollection> courseCollections = [
  const CourseCollection(
    id: 'all',
    label: 'All Courses',
    icon: Icons.menu_book_rounded,
    subjects: generalSubjects,
  ),
  CourseCollection(
    id: 'ap',
    label: 'AP Courses',
    icon: Icons.workspace_premium_rounded,
    subjects: apSubjects,
  ),
];
