import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/ap_catalog/ap_unit_notes_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';

/// Thin wrapper (~60 lines) around [CourseOverviewScreen] that wires the
/// "Note" button to the AP per-unit notes picker ([ApUnitNotesScreen]) instead
/// of the default course-level markdown view.
///
/// All planet-map, flashcard, tutor, podcast and lesson-locking behaviour is
/// inherited unchanged from [CourseOverviewScreen].
class ApCourseOverviewScreen extends StatelessWidget {
  const ApCourseOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();

    return CourseOverviewScreen(
      onViewNotesOverride: () {
        // Extract unique units from already-loaded lessons.
        final units = <int, String>{};
        for (final lesson in courseController.lessons) {
          final n = lesson['unitNumber'] as int?;
          final name = lesson['unitName'] as String?;
          if (n != null && name != null && !units.containsKey(n)) {
            units[n] = name;
          }
        }

        Get.to(
          () => ApUnitNotesScreen(
            courseId: courseController.selectedCourseId.value,
            units: units,
          ),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
