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
      // In test mode, simulate completion after 10 seconds
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

  // Get responsive sizing based on screen dimensions
  double _getCircleSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use smaller dimension to ensure it fits
    final smallerDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    // Calculate circle size with wider range for larger screens
    if (screenWidth > 600) {
      return (smallerDimension * 0.3).clamp(160.0, 220.0);
    }
    return (smallerDimension * 0.35).clamp(100.0, 160.0);
  }

  double _getProgressCircleStroke(BuildContext context) {
    final circleSize = _getCircleSize(context);
    if (circleSize > 180) return 5.0;
    return circleSize > 130 ? 4.0 : 3.0;
  }

  double _getProgressTextSize(BuildContext context) {
    final circleSize = _getCircleSize(context);
    if (circleSize > 180) return 32.0;
    return circleSize > 130 ? 24.0 : 20.0;
  }

  double _getStepCircleSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 40.0;
    return screenWidth < 360 ? 28.0 : 32.0;
  }

  double _getStepTextSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 18.0;
    return screenWidth < 360 ? 14.0 : 16.0;
  }

  double _getTitleTextSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 26.0;
    if (screenWidth < 360) return 18.0;
    if (screenWidth < 400) return 19.0;
    return 20.0;
  }

  Widget _buildProgressCircle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize = _getCircleSize(context);
        final innerCircleSize = circleSize - 20;
        final strokeWidth = _getProgressCircleStroke(context);
        final textSize = _getProgressTextSize(context);

        return Container(
          width: circleSize,
          height: circleSize,
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
                width: innerCircleSize,
                height: innerCircleSize,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(lumiPurple),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Percentage text
              Text(
                '${(_progress * 100).round()}%',
                style: GoogleFonts.poppins(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepCircle(int index, bool isActive, bool isCompleted) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize = _getStepCircleSize(context);
        final iconSize = circleSize * 0.5625; // Maintains proportion
        final numberSize = circleSize * 0.4375;
        final innerCircleSize = circleSize * 0.75;
        final dotSize = circleSize * 0.1875;

        if (isCompleted) {
          return AnimatedBuilder(
            animation: _stepAnimations[index],
            builder: (context, child) {
              return Container(
                width: circleSize,
                height: circleSize,
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
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              );
            },
          );
        } else if (isActive) {
          return Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: lumiPurple, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: innerCircleSize,
                  height: innerCircleSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(lumiPurple),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Container(
                  width: dotSize,
                  height: dotSize,
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
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: greyBorder.withOpacity(0.5), width: 1),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: numberSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        }
      },
    );
  }

Widget _buildStepsList() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Check if device is in landscape mode (width > height)
      final isLandscape = screenWidth > screenHeight;
      
      final maxWidth = screenWidth > 600 
          ? (screenWidth * 0.6).clamp(400.0, 600.0)
          : (screenWidth * 0.85).clamp(280.0, 400.0);
      final stepTextSize = _getStepTextSize(context);
      final spacing = screenWidth > 600 ? 24.0 : (screenWidth < 360 ? 12.0 : 16.0);
      
      // Reduce vertical padding in landscape mode, especially on tablets
      final verticalPadding = isLandscape 
          ? (screenWidth > 600 ? 8.0 : 10.0)  // Smaller padding in landscape
          : (screenWidth > 600 ? 16.0 : (screenWidth < 360 ? 10.0 : 12.0));

      // Add left padding to shift content right on iPhone
      final leftPadding = screenWidth < 600 ? 20.0 : 0.0;

      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: EdgeInsets.only(left: leftPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              bool isActive = index == _currentStep;
              bool isCompleted = index < _currentStep || _isCompleted;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: Row(
                  children: [
                    // Step circle with individual loading
                    _buildStepCircle(index, isActive, isCompleted),
                    SizedBox(width: spacing),
                    // Step text
                    Expanded(
                      child: Text(
                        step,
                        style: GoogleFonts.poppins(
                          fontSize: stepTextSize,
                          fontWeight: FontWeight.w400,
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.white54,
                          height: 1.3,
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
    },
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final screenWidth = constraints.maxWidth;
                
                // Responsive padding
                final horizontalPadding = (screenWidth * 0.06).clamp(16.0, 32.0);
                final topPadding = (screenHeight * 0.025).clamp(12.0, 24.0);
                
                // Responsive spacing
                final afterCircleSpacing = (screenHeight * 0.04).clamp(20.0, 40.0);
                final afterTitleSpacing = (screenHeight * 0.035).clamp(20.0, 32.0);
                final bottomButtonSpacing = (screenHeight * 0.02).clamp(12.0, 20.0);
                
                final titleTextSize = _getTitleTextSize(context);

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: topPadding,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth > 600 ? 700 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: topPadding),
                          // Progress circle
                          _buildProgressCircle(),
                          SizedBox(height: afterCircleSpacing),
                          // Main title
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 360 ? 8.0 : 0.0,
                            ),
                            child: Text(
                              'Hold tight, Lumi is working hard!',
                              style: GoogleFonts.poppins(
                                fontSize: titleTextSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: afterTitleSpacing),
                          // Steps list - scrollable for small screens
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: bottomButtonSpacing),
                                child: _buildStepsList(),
                              ),
                            ),
                          ),
                          // Bottom button
                          SizedBox(
                            width: double.infinity,
                            child: _isCompleted
                                ? ElevatedButton(
                                    onPressed: _goToCourse,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenWidth < 360 ? 14.0 : (screenWidth > 600 ? 18.0 : 16.0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Start Learning!',
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth > 600 ? 18.0 : (screenWidth < 360 ? 15.0 : 16.0),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenWidth < 360 ? 14.0 : (screenWidth > 600 ? 18.0 : 16.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: greyBorder, width: 1),
                                    ),
                                    child: Text(
                                      'Start Learning!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth > 600 ? 18.0 : (screenWidth < 360 ? 15.0 : 16.0),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: topPadding / 2),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}