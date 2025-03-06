import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/screens/courses/lessons/lesson_screen_main.dart';
import 'package:lumi_learn_app/widgets/bottom_panel.dart';
import 'package:lumi_learn_app/widgets/course_overview_header.dart';
import 'package:lumi_learn_app/widgets/star_painter.dart';
import 'package:lumi_learn_app/widgets/starry_app_scaffold.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/widgets/rocket_animation.dart';

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.find();

  bool _isPanelVisible = false;
  int? _selectedLessonIndex;

  // Key to detect taps outside the panel
  final GlobalKey _panelKey = GlobalKey();
  final StarPainter _starPainter = StarPainter(starCount: 200);

  // For capturing each lesson’s center (similar to planetCenters)
  final List<Offset> _lessonCenters = [];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Horizontal wave layout parameters (optional for the “orbit” effect)
    final double amplitude = 180.0;
    final double frequency = pi / 3;

    // Get all lessons from the controller
    final lessons = courseController.lessons;
    final lessonCount = lessons.length;

    // Each lesson is spaced 200px horizontally
    final totalWidth = lessonCount * 200.0;

    // Clear & recalculate lesson centers each build
    _lessonCenters.clear();

    return Obx(() {
      // Show loading screen if data is still loading
      if (courseController.isLoading.value || lessons.isEmpty) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      return StarryAppScaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) => _handleTapDown(context, details),
          child: Stack(
            children: [
              // 1) Scrollable horizontal region
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  height: screenHeight,
                  child: Stack(
                    children: [
                      // Background stars
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _starPainter,
                        ),
                      ),
                      // 2) Lessons as “Planets”
                      ...List.generate(lessonCount, (index) {
                        final lesson = lessons[index];
                        final lessonTitle =
                            lesson['title'] ?? 'Lesson ${index + 1}';

                        // Wave offset for a fun orbit effect
                        final offsetY =
                            amplitude * sin(index * frequency + pi / 2);
                        final planetLeft = index * 200.0;
                        final planetTop = screenHeight / 2 - offsetY - 60;
                        final planetSize = 100.0;

                        // Save the center of each “planet” (lesson icon) for the rocket animation
                        final lessonCenter = Offset(
                          planetLeft + planetSize / 2,
                          planetTop + planetSize / 2,
                        );
                        _lessonCenters.add(lessonCenter);

                        // You can replace this image with a lesson-specific image if available
                        final lessonImagePath = 'assets/planets/red1.png';

                        return Positioned(
                          left: planetLeft,
                          top: planetTop,
                          child: GestureDetector(
                            onTap: () => _onLessonTap(index),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    lessonImagePath,
                                    width: planetSize,
                                    height: planetSize,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lessonTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // 3) Rocket Animation
                      Positioned.fill(
                        child: _selectedLessonIndex == null
                            ? const SizedBox()
                            : RocketAnimation(
                                planetCenter:
                                    _lessonCenters[_selectedLessonIndex!],
                                planetRadius: 20.0,
                                isActive: _isPanelVisible,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // 4) Bottom Panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isPanelVisible ? 0 : -250,
                left: 0,
                right: 0,
                child: BottomPanel(
                  key: _panelKey,
                  selectedLessonIndex: _selectedLessonIndex,
                  onStartPressed: () {
                    // If you want to navigate to the lesson details
                    Get.to(() => LessonScreenMain());
                    _closePanel();
                  },
                  onClose: _closePanel,
                ),
              ),
              // 5) Top Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CourseOverviewHeader(
                  onBack: () => Get.back(),
                  lessonTitle: "${courseController.selectedCourseTitle}",
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 6) Handling Lesson Taps
  void _onLessonTap(int index) {
    if (_selectedLessonIndex == index && _isPanelVisible) {
      // Same lesson tapped; do nothing if panel is already open.
      return;
    } else {
      // Close any open panel first
      setState(() {
        _isPanelVisible = false;
      });
      // After it hides, show the new panel and rocket
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _selectedLessonIndex = index;
          _isPanelVisible = true;
        });
        courseController.setActivePlanet(index);
        // Or if you want to do something specifically for the tapped lesson,
        // you could store `selectedLessonIndex` in the controller, or handle other logic.
      });
    }
  }

  // 7) Close the bottom panel if we tap outside it
  void _handleTapDown(BuildContext context, TapDownDetails details) {
    if (!_isPanelVisible) return;

    final tapPosition = details.globalPosition;
    if (_panelKey.currentContext != null) {
      final renderBox =
          _panelKey.currentContext!.findRenderObject() as RenderBox;
      final panelOffset = renderBox.localToGlobal(Offset.zero);
      final panelSize = renderBox.size;
      final panelRect = Rect.fromLTWH(
        panelOffset.dx,
        panelOffset.dy,
        panelSize.width,
        panelSize.height,
      );
      if (!panelRect.contains(tapPosition)) {
        _closePanel();
      }
    }
  }

  // 8) Hides the panel & rocket
  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
    });
    // Optionally reset the selected index after the panel animation
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   setState(() {
    //     _selectedLessonIndex = null;
    //   });
    // });
  }
}
