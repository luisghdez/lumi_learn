// lib/screens/courses/course_overview_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/bottom_panel.dart'; // Import the BottomPanel
import 'package:vibra_app/widgets/star_painter.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';
import 'package:vibra_app/controllers/course_controller.dart';
import 'package:vibra_app/data/assets_data.dart'; // Import the data file

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.put(CourseController());

  // Panel visibility and currently selected lesson.
  bool _isPanelVisible = false;
  int? _selectedLessonIndex;

  // Key to detect taps outside the panel
  final GlobalKey _panelKey = GlobalKey();

  // A StarPainter so we don’t recreate it every frame
  final StarPainter _starPainter = StarPainter(starCount: 200);

  @override
  void initState() {
    super.initState();
    // Optionally, you could pre-select a lesson here or leave it null.
  }

  /// Called when user taps on a planet
  void _onPlanetTap(int index) {
    if (_selectedLessonIndex == index && _isPanelVisible) {
      // Same planet tapped while panel is open, do nothing or close
      return;
    } else {
      setState(() {
        _isPanelVisible = false; // animate panel down first
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _selectedLessonIndex = index;
          _isPanelVisible = true; // animate panel up
        });
        courseController.setActivePlanet(index);
      });
    }
  }

  /// Closes the panel
  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
    });
  }

  /// Handle taps anywhere on the screen
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

  @override
  Widget build(BuildContext context) {
    final double amplitude = 180.0;
    final double frequency = pi / 3;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth =
        planets.length * 200.0; // Adjust for item count & spacing

    return StarryAppScaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => _handleTapDown(context, details),
        child: Stack(
          children: [
            // -------------------------------
            // SCROLLABLE BACKGROUND + PLANETS
            // -------------------------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                height: screenHeight,
                child: Stack(
                  children: [
                    // Starry background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _starPainter,
                      ),
                    ),
                    // Planets
                    ...List.generate(planets.length, (index) {
                      final offsetY =
                          amplitude * sin(index * frequency + pi / 2);
                      final xPosition = index * 200.0; // horizontal spacing

                      return Positioned(
                        left: xPosition,
                        top: screenHeight / 2 - offsetY - 60,
                        child: GestureDetector(
                          onTap: () => _onPlanetTap(index),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  planets[index].imagePath,
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Lesson ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // -------------
            // BOTTOM PANEL
            // -------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom:
                  _isPanelVisible ? 0 : -250, // Slide up/down by changing this
              left: 0,
              right: 0,
              child: BottomPanel(
                key: _panelKey, // Assign the GlobalKey here
                selectedLessonIndex: _selectedLessonIndex,
                onStartPressed: () {
                  Get.to(() => LessonScreen());
                },
                onClose: _closePanel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
