import 'package:flutter/material.dart';

/// High-level groupings used by the catalog filter chips.
enum ApCategory {
  stem('STEM'),
  math('Math'),
  humanities('Humanities'),
  socialStudies('Social Studies');

  const ApCategory(this.label);
  final String label;
}

/// A single AP subject shown in the catalog.
class ApSubject {
  final String title;
  final String description;
  final int units;

  /// Short label shown in the subject tag chip (e.g. "Science", "Math").
  final String subjectTag;

  /// Used for filtering via the top chips.
  final ApCategory category;

  /// Accent color that color-codes the card (glow + tag accent).
  final Color accent;

  /// Firestore course ID — populated once the course is live in the catalog.
  /// Empty string means the course hasn't been generated yet.
  final String courseId;

  const ApSubject({
    required this.title,
    required this.description,
    required this.units,
    required this.subjectTag,
    required this.category,
    required this.accent,
    this.courseId = '',
  });
}

// ─── Static metadata ─────────────────────────────────────────────────────────
//
// Visual metadata (category, accent, subjectTag) for every AP subject.
// This is kept in the frontend so changing accent colors/categories never
// requires a backend deploy.
//
// Keys must exactly match the `apSubject` field stored in Firestore.

class _ApMeta {
  final ApCategory category;
  final Color accent;
  final String subjectTag;
  const _ApMeta(this.category, this.accent, this.subjectTag);
}

const Map<String, _ApMeta> _kApSubjectMeta = {
  // STEM
  'AP Biology':
      _ApMeta(ApCategory.stem, Color(0xFF4ADE80), 'Science'),
  'AP Chemistry':
      _ApMeta(ApCategory.stem, Color(0xFF2DD4BF), 'Science'),
  'AP Computer Science A':
      _ApMeta(ApCategory.stem, Color(0xFF34D399), 'CS'),
  'AP Computer Science Principles':
      _ApMeta(ApCategory.stem, Color(0xFF6EE7B7), 'CS'),
  'AP Environmental Science':
      _ApMeta(ApCategory.stem, Color(0xFF86EFAC), 'Science'),
  'AP Physics 1: Algebra-Based':
      _ApMeta(ApCategory.stem, Color(0xFF22D3EE), 'Science'),
  'AP Physics 2: Algebra-Based':
      _ApMeta(ApCategory.stem, Color(0xFF67E8F9), 'Science'),
  'AP Physics C: Mechanics':
      _ApMeta(ApCategory.stem, Color(0xFF38BDF8), 'Science'),
  'AP Physics C: Electricity and Magnetism':
      _ApMeta(ApCategory.stem, Color(0xFF7DD3FC), 'Science'),

  // Math
  'AP Calculus AB':
      _ApMeta(ApCategory.math, Color(0xFF60A5FA), 'Math'),
  'AP Calculus BC':
      _ApMeta(ApCategory.math, Color(0xFF818CF8), 'Math'),
  'AP Precalculus':
      _ApMeta(ApCategory.math, Color(0xFFA5B4FC), 'Math'),
  'AP Statistics':
      _ApMeta(ApCategory.math, Color(0xFFA78BFA), 'Math'),

  // Social Studies
  'AP African American Studies':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFBBF24), 'History'),
  'AP Comparative Government and Politics':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFACC15), 'Gov & Politics'),
  'AP Human Geography':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFCD34D), 'Geography'),
  'AP Macroeconomics':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFB923C), 'Economics'),
  'AP Microeconomics':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFDBA74), 'Economics'),
  'AP Psychology':
      _ApMeta(ApCategory.socialStudies, Color(0xFFF472B6), 'Social Science'),
  'AP United States Government and Politics':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFF8C69), 'Gov & Politics'),
  'AP United States History':
      _ApMeta(ApCategory.socialStudies, Color(0xFFFBBF24), 'History'),
  'AP World History: Modern':
      _ApMeta(ApCategory.socialStudies, Color(0xFFF97316), 'History'),

  // Humanities
  'AP Art History':
      _ApMeta(ApCategory.humanities, Color(0xFFF87171), 'Arts'),
  'AP English Language and Composition':
      _ApMeta(ApCategory.humanities, Color(0xFFE879F9), 'English'),
  'AP English Literature and Composition':
      _ApMeta(ApCategory.humanities, Color(0xFFF87171), 'English'),
  'AP European History':
      _ApMeta(ApCategory.humanities, Color(0xFFE11D48), 'History'),
  'AP Music Theory':
      _ApMeta(ApCategory.humanities, Color(0xFFEC4899), 'Arts'),
  'AP Seminar':
      _ApMeta(ApCategory.humanities, Color(0xFFD946EF), 'Research'),
  'AP Research':
      _ApMeta(ApCategory.humanities, Color(0xFFC026D3), 'Research'),

  // Languages (under Humanities)
  'AP Chinese Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFE879F9), 'Language'),
  'AP French Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFC084FC), 'Language'),
  'AP German Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFE879F9), 'Language'),
  'AP Italian Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFD8B4FE), 'Language'),
  'AP Japanese Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFF0ABFC), 'Language'),
  'AP Latin':
      _ApMeta(ApCategory.humanities, Color(0xFFE879F9), 'Language'),
  'AP Spanish Language and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFD946EF), 'Language'),
  'AP Spanish Literature and Culture':
      _ApMeta(ApCategory.humanities, Color(0xFFA855F7), 'Language'),
};

/// Fallback metadata when an apSubject isn't in [kApSubjectMeta].
const _ApMeta _kFallbackMeta =
    _ApMeta(ApCategory.stem, Color(0xFF94A3B8), 'AP Course');

/// Build an [ApSubject] from a raw API course map.
/// Visual metadata comes from [kApSubjectMeta]; content from the API.
ApSubject apSubjectFromApiCourse(Map<String, dynamic> course) {
  final apSubject = course['apSubject'] as String? ?? course['title'] as String? ?? '';
  final meta = _kApSubjectMeta[apSubject] ?? _kFallbackMeta;
  return ApSubject(
    courseId:   course['id']          as String? ?? '',
    title:      apSubject,
    description: course['description'] as String? ?? '',
    units:      (course['unitCount']   as num?)?.toInt() ?? 0,
    subjectTag: meta.subjectTag,
    category:   meta.category,
    accent:     meta.accent,
  );
}
