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

  /// Approximate height of [CourseOverviewHeader] (padding + rows). Used with
  /// safe-area top inset so planets are never placed under the header hit-box.
  static const double approxHeaderCardHeight = 210;

  /// Extra gap below the header before the first planet row may start.
  static const double minPlanetTopGapBelowHeader = 10;

  static double planetTopY(
    int index,
    double screenHeight, {
    double minPlanetTop = 0,
  }) {
    final offsetY = amplitude * sin(index * frequency + pi / 2);
    final raw = screenHeight / 2 - offsetY - verticalNudge;
    if (minPlanetTop <= 0) return raw;
    return max(raw, minPlanetTop);
  }

  static double planetLeftX(int index) => index * spacing;

  static Offset planetCenter(
    int index,
    double screenHeight, {
    double minPlanetTop = 0,
  }) {
    return Offset(
      planetLeftX(index) + planetSize / 2,
      planetTopY(index, screenHeight, minPlanetTop: minPlanetTop) +
          planetSize / 2,
    );
  }

  static double totalWidth(int lessonCount) => lessonCount * spacing;
}
