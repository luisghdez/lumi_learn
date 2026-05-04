import 'package:flutter/material.dart';

/// Fade timing shared by create hub ([CreateFlowShell]), video sub-steps
/// ([CreateVideoScreen]), main tab cross-fades ([MainScreen]), and course
/// creation step changes ([CourseCreation]).
const Duration kCreateFlowFadeDuration = Duration(milliseconds: 380);
const Curve kCreateFlowFadeCurve = Curves.easeInOut;

Widget kCreateFlowFadeTransition(
  Widget child,
  Animation<double> animation,
) {
  return FadeTransition(opacity: animation, child: child);
}
