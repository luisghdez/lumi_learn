import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/bottom_panel.dart';
import 'package:vibra_app/widgets/star_painter.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';
import 'package:vibra_app/controllers/course_controller.dart';
import 'package:vibra_app/data/assets_data.dart';
import 'package:vibra_app/widgets/rocket_animation.dart';

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.put(CourseController());

  bool _isPanelVisible = false;
  int? _selectedLessonIndex;

  // Key to detect taps outside the panel
  final GlobalKey _panelKey = GlobalKey();
  final StarPainter _starPainter = StarPainter(starCount: 200);

  // For capturing each planet’s center
  final List<Offset> _planetCenters = [];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Horizontal wave layout
    final double amplitude = 180.0;
    final double frequency = pi / 3;

    // Calculate total width to hold all planets side by side
    final totalWidth = planets.length * 200.0;

    // We’ll recalc _planetCenters each build
    _planetCenters.clear();

    return StarryAppScaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => _handleTapDown(context, details),
        child: Stack(
          children: [
            // SCROLLABLE HORIZONTAL
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                height: screenHeight,
                child: Stack(
                  children: [
                    // Star background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _starPainter,
                      ),
                    ),

                    // Planets
                    ...List.generate(planets.length, (index) {
                      final offsetY =
                          amplitude * sin(index * frequency + pi / 2);
                      final planetLeft = index * 200.0;
                      final planetTop = screenHeight / 2 - offsetY - 60;
                      final planetSize = 100.0;

                      // planet center in the local coordinate system
                      final planetCenter = Offset(
                        planetLeft + planetSize / 2,
                        planetTop + planetSize / 2,
                      );
                      _planetCenters.add(planetCenter);

                      return Positioned(
                        left: planetLeft,
                        top: planetTop,
                        child: GestureDetector(
                          onTap: () => _onPlanetTap(index),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  planets[index].imagePath,
                                  width: planetSize,
                                  height: planetSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Lesson ${index + 1}",
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

                    // --- ROCKET ANIMATION ---
                    if (_selectedLessonIndex != null)
                      // We fill the entire stack so we can
                      // position the rocket freely in local coords
                      Positioned.fill(
                        child: RocketAnimation(
                          planetCenter: _planetCenters[_selectedLessonIndex!],
                          planetRadius: 16.0, // adjust radius
                          isActive: _isPanelVisible,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // BOTTOM PANEL (outside the scroll area)
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

  // Show/hide bottom panel
  void _onPlanetTap(int index) {
    if (_selectedLessonIndex == index && _isPanelVisible) {
      // same planet tapped, do nothing
      return;
    } else {
      setState(() {
        _isPanelVisible = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _selectedLessonIndex = index;
          _isPanelVisible = true;
        });
        courseController.setActivePlanet(index);
      });
    }
  }

  // Panel outside-tap detection
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

  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
    });
  }
}
