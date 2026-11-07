import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';
import 'package:lumi_learn_app/screens/courses/lessons/lesson_screen_main.dart';
import 'package:video_player/video_player.dart';

/// Final onboarding step: choose one of the AP courses selected earlier and
/// launch its first incomplete lesson without visiting the course overview.
class OnboardingStartCourseScreen extends StatefulWidget {
  const OnboardingStartCourseScreen({
    super.key,
    required this.selectedCourses,
    required this.videoController,
    this.displayName,
    this.onboardingAudioPlayer,
  });

  final List<ApSubject> selectedCourses;
  final String? displayName;
  final VideoPlayerController videoController;
  final AudioPlayer? onboardingAudioPlayer;

  @override
  State<OnboardingStartCourseScreen> createState() =>
      _OnboardingStartCourseScreenState();
}

class _OnboardingStartCourseScreenState
    extends State<OnboardingStartCourseScreen>
    with SingleTickerProviderStateMixin {
  final CourseController _courseController = Get.find<CourseController>();
  final AuthController _authController = Get.find<AuthController>();
  late final AnimationController _entryController;
  late final Animation<double> _entryFadeAnimation;
  late final AudioPlayer _entrySoundPlayer;

  String? _startingCourseId;
  bool _ownsOnboardingAudio = true;

  bool get _isStarting => _startingCourseId != null;

  @override
  void initState() {
    super.initState();
    _entrySoundPlayer = AudioPlayer();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _entryFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryController.forward();
    _playEntrySound();
  }

  Future<void> _playEntrySound() async {
    try {
      await _entrySoundPlayer.setSource(AssetSource('sounds/glow.mp3'));
      await _entrySoundPlayer.setVolume(1.5);
      await _entrySoundPlayer.resume();
    } catch (_) {
      // The onboarding flow should continue even if the one-shot sound fails.
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _entrySoundPlayer.dispose();
    widget.videoController.dispose();
    if (_ownsOnboardingAudio) {
      widget.onboardingAudioPlayer?.stop();
      widget.onboardingAudioPlayer?.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmAndStart(ApSubject course) async {
    if (_isStarting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _StartLessonDialog(course: course),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _startingCourseId = course.courseId);

    try {
      final isAlreadySaved = _courseController.courses.any(
        (savedCourse) => savedCourse['id'] == course.courseId,
      );

      if (!isAlreadySaved) {
        final saved = await _courseController.saveSharedCourse(
          course.courseId,
          course.title,
        );
        if (!saved) {
          throw Exception('Could not save AP course');
        }
      }

      final loaded = await _courseController.setSelectedCourseId(
        course.courseId,
        course.title,
        true,
      );

      if (!loaded || _courseController.lessons.isEmpty) {
        throw Exception('This AP course has no lessons');
      }

      final firstIncomplete = _courseController.lessons.indexWhere(
        (lesson) => lesson['completed'] != true,
      );
      final lessonIndex = firstIncomplete == -1 ? 0 : firstIncomplete;
      final lesson = _courseController.lessons[lessonIndex];
      final lessonId = lesson['id']?.toString() ?? 'lesson${lessonIndex + 1}';

      _courseController.setActiveLessonIndex(lessonIndex);
      _courseController.setActivePlanet(
        _planetForLesson(course.courseId, lessonId),
      );
      _courseController.loadQuestions(quickStart: true);

      if (_courseController.computedQuestions.isEmpty) {
        throw Exception('This lesson has no activities');
      }

      final onboardingSaved = await _authController.completeOnboarding(
        courseIds: widget.selectedCourses.map((item) => item.courseId).toList(),
        displayName: widget.displayName,
      );
      if (!onboardingSaved) throw StateError('Could not save onboarding');
      await widget.onboardingAudioPlayer?.stop();
      await widget.onboardingAudioPlayer?.dispose();
      _ownsOnboardingAudio = false;

      Get.offAll(
        () => LessonScreenMain(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingCourseId = null);
      Get.snackbar(
        'Couldn\'t start the lesson',
        'Please check your connection and try again.',
        backgroundColor: const Color(0xFF251B2B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Planet _planetForLesson(String courseId, String lessonId) {
    final hash = md5.convert(utf8.encode('$courseId$lessonId')).toString();
    final numericHash = int.parse(hash.substring(0, 6), radix: 16);
    return planets[numericHash % planets.length];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 768;
    final horizontalPadding = isTablet ? size.width * 0.16 : 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.videoController.value.size.width,
                  height: widget.videoController.value.size.height,
                  child: VideoPlayer(widget.videoController),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.30)),
          ),
          FadeTransition(
            opacity: _entryFadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isTablet ? 34 : 22,
                      horizontalPadding,
                      18,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Start your first course',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: isTablet ? 58 : 42,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -1.4,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Choose one of your AP courses. Your first lesson is short and takes about 2 minutes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: isTablet ? 19 : 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        32,
                      ),
                      itemCount: widget.selectedCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final course = widget.selectedCourses[index];
                        return _SelectedApCourseCard(
                          course: course,
                          isLoading: _startingCourseId == course.courseId,
                          enabled: !_isStarting,
                          onTap: () => _confirmAndStart(course),
                        );
                      },
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

class _SelectedApCourseCard extends StatelessWidget {
  const _SelectedApCourseCard({
    required this.course,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  final ApSubject course;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || isLoading ? 1 : 0.48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF14161D).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: course.accent.withValues(alpha: 0.42),
              ),
              boxShadow: [
                BoxShadow(
                  color: course.accent.withValues(alpha: 0.10),
                  blurRadius: 28,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: course.accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: course.accent,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'First lesson · About 2 minutes',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartLessonDialog extends StatelessWidget {
  const _StartLessonDialog({required this.course});

  final ApSubject course;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF17171B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Start ${course.title}?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        'Your first lesson takes about 2 minutes. Your progress will be saved automatically.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.68),
          height: 1.45,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Choose another',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: const Text('Start 2-minute lesson'),
        ),
      ],
    );
  }
}
