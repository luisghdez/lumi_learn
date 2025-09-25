import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';

class CourseLoadingScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> courseCreationFuture;

  const CourseLoadingScreen({
    Key? key,
    required this.courseCreationFuture,
  }) : super(key: key);

  @override
  State<CourseLoadingScreen> createState() => _CourseLoadingScreenState();
}

class _CourseLoadingScreenState extends State<CourseLoadingScreen> {
  bool _isCompleted = false;
  String? _completedCourseId;
  String _completedCourseTitle = "";
  bool _hasEmbeddings = true;

  @override
  void initState() {
    super.initState();
    _listenForCompletion();
  }

  void _listenForCompletion() async {
    try {
      final result = await widget.courseCreationFuture;
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _completedCourseId = result['courseId'] as String?;
          _completedCourseTitle = result['title'] ?? 'New Course';
          _hasEmbeddings = result['hasEmbeddings'] ?? true;
        });
      }
    } catch (e) {
      if (mounted) {
        // Handle error - could show an error state or navigate back
        Get.snackbar(
          "Error",
          "Failed to create course. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      }
    }
  }

  void _goToCourse() {
    if (_completedCourseId != null) {
      final courseController = Get.find<CourseController>();

      // Set the selected course
      courseController.setSelectedCourseId(
          _completedCourseId!, _completedCourseTitle, _hasEmbeddings);

      // Navigate to course overview
      Get.offAll(
        () => const CourseOverviewScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0A0A0A), // Same as existing LoadingScreen
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300, // Same dimensions as LoadingScreen
              height: 300,
              child: Image.asset(
                  'assets/astronaut/whistling.png'), // Same as LoadingScreen
            ),
            const SizedBox(height: 20), // Same spacing as LoadingScreen
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isCompleted) ...[
                  // Loading state - replicate LoadingScreen text style
                  Text(
                    'Creating Course...',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w300, // Same as LoadingScreen
                      height: 0.8, // Same as LoadingScreen
                      letterSpacing: -2, // Same as LoadingScreen
                      color: const Color.fromARGB(
                          94, 255, 255, 255), // Same as LoadingScreen
                    ),
                  ),
                ] else ...[
                  // Completion state with "Go to Course" button
                  Text(
                    'Course Created!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      height: 0.8,
                      letterSpacing: -2,
                      color: const Color.fromARGB(200, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Empty button as requested
                  ElevatedButton(
                    onPressed: _goToCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      'Go to Course',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
