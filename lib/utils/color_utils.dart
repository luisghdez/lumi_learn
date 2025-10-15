import 'package:flutter/material.dart';

class ColorUtils {
  /// Generates a unique, consistent color for a given course ID.
  /// Uses a 64-bit FNV-1a hash and maps multiple independent bit ranges
  /// to H, S, and L to avoid collisions (not just hue).
  static Color getCourseColor(String? courseId) {
    if (courseId == null || courseId.isEmpty) {
      return Colors.grey;
    }

    final int hash = _fnv1a64(courseId);

    // Spread different parts of the hash across H, S, and L
    final int hBits = hash & 0xFFFF; // 16 bits → Hue
    final int sBits = (hash >> 16) & 0xFF; // 8 bits  → Saturation band
    final int lBits = (hash >> 24) & 0xFF; // 8 bits  → Lightness band
    final int jBits = (hash >> 32) & 0xFFFF; // 16 bits → tiny jitter

    final double hue = (hBits / 0xFFFF) * 360.0; // 0..360
    final double saturation = 0.60 + (sBits / 255.0) * 0.30; // 0.60..0.90
    final double lightness = 0.50 + (lBits / 255.0) * 0.20; // 0.50..0.70

    // Tiny deterministic jitter (~≤1°) to separate near-equal colors after 8-bit rounding.
    final double hueJitter = (jBits / 0xFFFF) * 1.0; // degrees

    return _hslToColor(hue + hueJitter, saturation, lightness);
  }

  /// 64-bit FNV-1a hash (stable across runs, no dependencies).
  static int _fnv1a64(String input) {
    const int fnvOffset = 0x811c9dc5; // 2166136261
    const int fnvPrime = 0x100000001b3; // 1099511628211
    
    const int mask32 = 0xFFFFFFFF;
    int hash = fnvOffset;
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * fnvPrime) & mask32;
    }
    return hash;
  }

  /// Convert HSL values to a Flutter [Color].
  static Color _hslToColor(double h, double s, double l) {
    double hh = ((h % 360) + 360) % 360 / 360.0; // normalize to [0,1)
    double ss = s.clamp(0.0, 1.0);
    double ll = l.clamp(0.0, 1.0);

    double hue2rgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    double r, g, b;
    if (ss == 0) {
      r = g = b = ll; // achromatic
    } else {
      final double q = ll < 0.5 ? ll * (1 + ss) : ll + ss - ll * ss;
      final double p = 2 * ll - q;
      r = hue2rgb(p, q, hh + 1 / 3);
      g = hue2rgb(p, q, hh);
      b = hue2rgb(p, q, hh - 1 / 3);
    }

    return Color.fromARGB(
      255,
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
    );
  }
}
