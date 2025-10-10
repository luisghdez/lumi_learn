import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class CourseCreationLoadingScreen extends StatefulWidget {
  final String tempCourseId;

  const CourseCreationLoadingScreen({
    Key? key,
    required this.tempCourseId,
  }) : super(key: key);

  @override
  State<CourseCreationLoadingScreen> createState() =>
      _CourseCreationLoadingScreenState();
}

class _CourseCreationLoadingScreenState
    extends State<CourseCreationLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final CourseController courseController = Get.find<CourseController>();
  bool _isCompleted = false;
  String? _completedCourseId;
  String _completedCourseTitle = "";

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Listen for course creation completion
    _listenForCompletion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listenForCompletion() {
    // Check every 500ms if the course creation is complete
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return false;

      // Check if our temp course is no longer loading
      final courses = courseController.courses;
      final tempCourse = courses.firstWhereOrNull(
        (course) => course['id'] == widget.tempCourseId,
      );

      if (tempCourse != null && tempCourse['loading'] == false) {
        setState(() {
          _isCompleted = true;
          _completedCourseId = tempCourse['id'];
          _completedCourseTitle = tempCourse['title'] ?? 'New Course';
        });
        return false; // Stop the loop
      }

      return !_isCompleted; // Continue if not completed
    });
  }

  void _goToCourse() {
    if (_completedCourseId != null) {
      // Set the selected course
      courseController.setSelectedCourseId(
          _completedCourseId!, _completedCourseTitle);

      // Navigate to course overview
      Get.offAll(
        () => const CourseOverviewScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  void _goToHome() {
    Get.offAll(
      () => MainScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(_isCompleted
                    ? 'assets/astronaut/celebrating.png'
                    : 'assets/astronaut/construction.png'),
              ),
              const SizedBox(height: 20),
              if (!_isCompleted) ...[
                // Loading state
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Creating Course...',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        height: 0.8,
                        letterSpacing: -2,
                        color: const Color.fromARGB(200, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This may take a few moments',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                        color: const Color.fromARGB(150, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Success state
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Course Created!',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        height: 0.8,
                        letterSpacing: -2,
                        color: const Color.fromARGB(255, 76, 175, 80),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _completedCourseTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(200, 255, 255, 255),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Go to Home button
                        TextButton(
                          onPressed: _goToHome,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Back to Home',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Go to Course button (primary)
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
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
