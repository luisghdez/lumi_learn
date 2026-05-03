import 'dart:math';

import 'package:flutter/material.dart';

/// Shared math for the horizontal “course map” so planets, rockets, and the
/// map painter stay aligned.
class CourseLessonMapLayout {
  CourseLessonMapLayout._();

  static const double spacing = 200;
  static const double planetSize = 100;
  static const double amplitude = 180;
  static const double frequency = pi / 3;
  static const double verticalNudge = 60;

  static double planetTopY(int index, double screenHeight) {
    final offsetY = amplitude * sin(index * frequency + pi / 2);
    return screenHeight / 2 - offsetY - verticalNudge;
  }

  static double planetLeftX(int index) => index * spacing;

  static Offset planetCenter(int index, double screenHeight) {
    return Offset(
      planetLeftX(index) + planetSize / 2,
      planetTopY(index, screenHeight) + planetSize / 2,
    );
  }

  static double totalWidth(int lessonCount) => lessonCount * spacing;
}
