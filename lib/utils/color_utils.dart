import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  // Predefined list of vibrant colors that work well in the app's theme
  static const List<Color> _courseColors = [
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.lightBlueAccent,
    Colors.limeAccent,
    Colors.indigoAccent,
    Colors.tealAccent,
    Colors.deepOrangeAccent,
    Colors.amberAccent,
    Colors.lightGreenAccent,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.deepPurpleAccent,
  ];

  /// Generates a consistent color for a given course ID
  /// The same courseId will always return the same color
  static Color getCourseColor(String? courseId) {
    if (courseId == null || courseId.isEmpty) {
      // Return a default color for threads without a course
      return Colors.grey;
    }

    // Generate a hash from the courseId to ensure consistency
    int hash = 0;
    for (int i = 0; i < courseId.length; i++) {
      hash = ((hash << 5) - hash + courseId.codeUnitAt(i)) & 0xFFFFFFFF;
    }

    // Use the hash to select a color from our predefined list
    final colorIndex = hash.abs() % _courseColors.length;
    return _courseColors[colorIndex];
  }

  /// Alternative method using a more sophisticated hash for better distribution
  static Color getCourseColorV2(String? courseId) {
    if (courseId == null || courseId.isEmpty) {
      return Colors.grey;
    }

    // Use a more sophisticated hash function
    int hash = 5381;
    for (int i = 0; i < courseId.length; i++) {
      hash = ((hash << 5) + hash) + courseId.codeUnitAt(i);
    }

    // Generate HSL values for more visually distinct colors
    final hue = (hash.abs() % 360).toDouble();
    final saturation = 0.7 + (hash.abs() % 30) / 100.0; // 70-100% saturation
    final lightness = 0.5 + (hash.abs() % 20) / 100.0; // 50-70% lightness

    // Convert HSL to RGB
    return _hslToColor(hue, saturation, lightness);
  }

  /// Convert HSL values to Color
  static Color _hslToColor(double h, double s, double l) {
    h = h / 360.0;
    s = s.clamp(0.0, 1.0);
    l = l.clamp(0.0, 1.0);

    double hue2rgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return Color.fromARGB(
      255,
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
    );
  }
}
