import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Deterministic galaxy art per course id (same as home / featured cards).
String galaxyAssetPathForCourseId(String courseId) {
  final bytes = utf8.encode(courseId);
  final hash = md5.convert(bytes).toString();
  final numericHash = int.parse(hash.substring(0, 6), radix: 16);
  final galaxyIndex = (numericHash % 17) + 1;
  return 'assets/galaxies/galaxy$galaxyIndex.png';
}
