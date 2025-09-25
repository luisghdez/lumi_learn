import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/constants.dart';

const lumiPurple = Color(0xFFA28BFF);

class CourseLoadingScreen extends StatefulWidget {
  final Future<Map<String, dynamic>>? courseCreationFuture;
  final bool isTestMode;

  const CourseLoadingScreen({
    Key? key,
    required this.courseCreationFuture,
  })  : isTestMode = false,
        super(key: key);

  // Test constructor for development
  const CourseLoadingScreen.test({
    Key? key,
  })  : courseCreationFuture = null,
        isTestMode = true,
        super(key: key);

  @override
  State<CourseLoadingScreen> createState() => _CourseLoadingScreenState();
}

class _CourseLoadingScreenState extends State<CourseLoadingScreen>
    with TickerProviderStateMixin {
  bool _isCompleted = false;
  String? _completedCourseId;
  String _completedCourseTitle = "";
  bool _hasEmbeddings = true;

  // Progress tracking
  int _currentStep = 0;
  double _progress = 0.0;
  Timer? _progressTimer;

  // Animation controllers for each step completion
  late List<AnimationController> _stepAnimationControllers;
  late List<Animation<double>> _stepAnimations;

  // Steps for course creation
  final List<String> _steps = [
    "Understanding your material",
    "Generating flashcards",
    "Generating quizzes",
    "Training your study bot",
    "Preparing Speak & learn",
    "Finalizing your course"
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each step
    _stepAnimationControllers = List.generate(
      _steps.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Create animations for each step
    _stepAnimations = _stepAnimationControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _startProgressSimulation();
    if (!widget.isTestMode) {
      _listenForCompletion();
    } else {
      // In test mode, simulate completion after 8 seconds
      Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isCompleted = true;
            _completedCourseId = 'test-course-id';
            _completedCourseTitle = 'Test Course - Introduction to Flutter';
            _progress = 1.0;
            _currentStep = _steps.length - 1;
          });
          _progressTimer?.cancel();

          // Play completion sound
          final courseController = Get.find<CourseController>();
          courseController.playCorrectAnswerSound();

          // Animate all remaining steps
          for (int i = 0; i < _steps.length; i++) {
            _stepAnimationControllers[i].forward();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    for (var controller in _stepAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startProgressSimulation() {
    // Smoother progress - updates every 50ms with smaller increments
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.002; // Increment by 0.2% for smoother animation

        // Update current step based on progress
        int newStep = (_progress * _steps.length).floor();
        if (newStep != _currentStep && newStep < _steps.length) {
          // Animate the completion of the previous step
          if (_currentStep >= 0 && _currentStep < _steps.length) {
            _stepAnimationControllers[_currentStep].forward();
          }
          _currentStep = newStep;
        }

        // Cap at 95% until actual completion (unless in test mode)
        if (_progress >= 0.95 && !_isCompleted && !widget.isTestMode) {
          _progress = 0.95;
          timer.cancel();
        }

        // In test mode, continue to 100%
        if (widget.isTestMode && _progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  void _listenForCompletion() async {
    if (widget.courseCreationFuture == null) return;

    try {
      final result = await widget.courseCreationFuture!;
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _completedCourseId = result['courseId'] as String?;
          _completedCourseTitle = result['title'] ?? 'New Course';
          _hasEmbeddings = result['hasEmbeddings'] ?? true;
          _progress = 1.0; // Complete the progress
          _currentStep = _steps.length - 1; // Mark all steps complete
        });
        _progressTimer?.cancel();

        // Play completion sound
        final courseController = Get.find<CourseController>();
        courseController.playCorrectAnswerSound();

        // Animate completion of all steps
        for (int i = 0; i < _steps.length; i++) {
          Future.delayed(Duration(milliseconds: i * 100), () {
            if (mounted) {
              _stepAnimationControllers[i].forward();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _progressTimer?.cancel();
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
    if (widget.isTestMode) {
      // In test mode, just show a snackbar
      Get.snackbar(
        "Test Mode",
        "This would navigate to the course overview screen",
        backgroundColor: lumiPurple,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }

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

  Widget _buildProgressCircle() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.03),
        border: Border.all(
          color: greyBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(lumiPurple),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Percentage text
          Text(
            '${(_progress * 100).round()}%',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int index, bool isActive, bool isCompleted) {
    if (isCompleted) {
      return AnimatedBuilder(
        animation: _stepAnimations[index],
        builder: (context, child) {
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                Colors.white.withOpacity(0.05),
                lumiPurple,
                _stepAnimations[index].value,
              ),
              border: Border.all(
                color: Color.lerp(
                  greyBorder.withOpacity(0.5),
                  lumiPurple,
                  _stepAnimations[index].value,
                )!,
                width: 1,
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: _stepAnimations[index].value > 0.5 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          );
        },
      );
    } else if (isActive) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: lumiPurple, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(lumiPurple),
                backgroundColor: Colors.transparent,
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: lumiPurple,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: greyBorder.withOpacity(0.5), width: 1),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStepsList() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          children: _steps.asMap().entries.map((entry) {
            int index = entry.key;
            String step = entry.value;
            bool isActive = index == _currentStep;
            bool isCompleted = index < _currentStep || _isCompleted;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  // Step circle with individual loading
                  _buildStepCircle(index, isActive, isCompleted),
                  const SizedBox(width: 20),
                  // Step text
                  Expanded(
                    child: Text(
                      step,
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Progress circle
                  _buildProgressCircle(),
                  const SizedBox(height: 32),
                  // Main title
                  Text(
                    'Hold tight, Lumi is working hard!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Steps list
                  Expanded(
                    child: Center(
                      child: _buildStepsList(),
                    ),
                  ),
                  // Bottom button - disabled while loading, enabled when completed
                  SizedBox(
                    width: double.infinity,
                    child: _isCompleted
                        ? ElevatedButton(
                            onPressed: _goToCourse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Start Learning!',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: greyBorder, width: 1),
                            ),
                            child: Text(
                              'Start Learning!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
