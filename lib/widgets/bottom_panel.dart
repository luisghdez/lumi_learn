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
      // No fixed height here — the container will size itself based on its child.
      return Container(
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
          child: Padding(
            padding: EdgeInsets.all(16.0), // Added padding
            child: Text(
              'No planet selected',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }

    // Main panel content
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24.0, vertical: 20.0), // Increased padding
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Allows the panel to size itself based on content
          children: [
            // Optional: Add a drag handle for better UX (commonly seen in bottom sheets)
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use Stack with `clipBehavior: Clip.none` to allow overflow.
                ClipOval(
                  child: Image.asset(
                    activePlanet.imagePath,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                    width: 24), // Increased spacing between image and text
                // Lesson details
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to start
                    children: [
                      Text(
                        'Lesson ${selectedLessonIndex != null ? selectedLessonIndex! + 1 : 'N/A'}',
                        style: const TextStyle(
                          fontSize:
                              28, // Slightly reduced font size for better fit
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'In this lesson you will learn about various fascinating topics related to your course.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // "Start" button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onStartPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14, // Increased vertical padding
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Start!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 24, 24, 24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
