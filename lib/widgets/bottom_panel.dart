// lib/widgets/bottom_panel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/controllers/course_controller.dart';

class BottomPanel extends StatelessWidget {
  final int? selectedLessonIndex;
  final VoidCallback onStartPressed;

  const BottomPanel({
    Key? key,
    required this.selectedLessonIndex,
    required this.onStartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final activePlanet = courseController.activePlanet.value;

    if (activePlanet == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color.fromARGB(119, 0, 0, 0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No planet selected',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color.fromARGB(119, 0, 0, 0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    // Planet image
                    ClipOval(
                      child: Image.asset(
                        activePlanet.imagePath,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Lesson details
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Lesson ${selectedLessonIndex != null ? selectedLessonIndex! + 1 : 'N/A'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 34,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'In this lesson you will learn about blablabbsbsb',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // "Start" button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onStartPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Start!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 24, 24, 24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
