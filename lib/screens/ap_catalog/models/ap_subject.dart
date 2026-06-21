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

  const ApSubject({
    required this.title,
    required this.description,
    required this.units,
    required this.subjectTag,
    required this.category,
    required this.accent,
  });
}

/// Static catalog data — UI only for now.
const List<ApSubject> kApSubjects = [
  ApSubject(
    title: 'AP Biology',
    description: 'Cells, genetics, evolution, ecology, and test-style practice.',
    units: 8,
    subjectTag: 'Science',
    category: ApCategory.stem,
    accent: Color(0xFF4ADE80),
  ),
  ApSubject(
    title: 'AP Chemistry',
    description: 'Atomic structure, bonding, reactions, thermodynamics, and labs.',
    units: 9,
    subjectTag: 'Science',
    category: ApCategory.stem,
    accent: Color(0xFF2DD4BF),
  ),
  ApSubject(
    title: 'AP Calculus AB',
    description: 'Limits, derivatives, integrals, and the fundamental theorem.',
    units: 8,
    subjectTag: 'Math',
    category: ApCategory.math,
    accent: Color(0xFF60A5FA),
  ),
  ApSubject(
    title: 'AP Calculus BC',
    description: 'Everything in AB plus series, polar, and parametric functions.',
    units: 10,
    subjectTag: 'Math',
    category: ApCategory.math,
    accent: Color(0xFF818CF8),
  ),
  ApSubject(
    title: 'AP Physics 1',
    description: 'Kinematics, forces, energy, momentum, and rotational motion.',
    units: 8,
    subjectTag: 'Science',
    category: ApCategory.stem,
    accent: Color(0xFF22D3EE),
  ),
  ApSubject(
    title: 'AP Statistics',
    description: 'Data, sampling, probability, inference, and significance tests.',
    units: 9,
    subjectTag: 'Math',
    category: ApCategory.math,
    accent: Color(0xFFA78BFA),
  ),
  ApSubject(
    title: 'AP Computer Science A',
    description: 'Java fundamentals, objects, data structures, and algorithms.',
    units: 7,
    subjectTag: 'Science',
    category: ApCategory.stem,
    accent: Color(0xFF34D399),
  ),
  ApSubject(
    title: 'AP US History',
    description: 'Colonial era to the present with document-based reasoning.',
    units: 9,
    subjectTag: 'History',
    category: ApCategory.socialStudies,
    accent: Color(0xFFFBBF24),
  ),
  ApSubject(
    title: 'AP World History',
    description: 'Global eras, empires, trade, and cross-cultural change.',
    units: 9,
    subjectTag: 'History',
    category: ApCategory.socialStudies,
    accent: Color(0xFFFB923C),
  ),
  ApSubject(
    title: 'AP Psychology',
    description: 'Brain, behavior, cognition, development, and disorders.',
    units: 9,
    subjectTag: 'Social Science',
    category: ApCategory.socialStudies,
    accent: Color(0xFFF472B6),
  ),
  ApSubject(
    title: 'AP English Literature',
    description: 'Close reading of prose, poetry, and timed analytical essays.',
    units: 8,
    subjectTag: 'English',
    category: ApCategory.humanities,
    accent: Color(0xFFF87171),
  ),
  ApSubject(
    title: 'AP English Language',
    description: 'Rhetoric, argument, synthesis, and persuasive writing.',
    units: 8,
    subjectTag: 'English',
    category: ApCategory.humanities,
    accent: Color(0xFFE879F9),
  ),
];
