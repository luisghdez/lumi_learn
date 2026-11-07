import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/services/analytics_service.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_step1.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_step2.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_video_transition.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_start_course_screen.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';
import 'package:lumi_learn_app/widgets/onboarding_video_background.dart';

/// Container that manages the video background and audio for all onboarding steps
/// This ensures smooth transitions between steps without re-initializing media
class OnboardingContainer extends StatefulWidget {
  const OnboardingContainer({super.key});

  @override
  State<OnboardingContainer> createState() => _OnboardingContainerState();
}

class _OnboardingContainerState extends State<OnboardingContainer> {
  final AuthController authController = Get.find<AuthController>();
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;

  // Onboarding state
  int _currentStep = 0; // 0: step1, 1: step2, 2: video transition
  String _username = '';
  List<ApSubject> _selectedApCourses = const [];
  bool _shouldDisposeController = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.screen('onboarding_profile');
    AnalyticsService.instance.log('onboarding_started');
    _initializeMedia();
  }

  void _initializeMedia() {
    // Initialize video controller
    _videoController = VideoPlayerController.asset(
      'assets/videos/onboardingVideo.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          // Keep video paused
          _videoController.pause();
          _videoController.setLooping(false);
        }
      });

    // Initialize and play background music
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  void _initializeAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/onboarding1.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    if (_shouldDisposeController) {
      _videoController.dispose();
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  void _completeOnboarding() {
    if (_selectedApCourses.isEmpty) return;

    // Preserve the original onboarding handoff: the transition video keeps
    // playing behind the next screen and the onboarding music is uninterrupted.
    _shouldDisposeController = false;

    Get.offAll(
      () => OnboardingStartCourseScreen(
        selectedCourses: _selectedApCourses,
        displayName: _username,
        videoController: _videoController,
        onboardingAudioPlayer: _audioPlayer,
      ),
      transition: Transition.noTransition,
    );
  }

  void _goToStep2(String username, int avatarIndex) {
    AnalyticsService.instance.log('onboarding_step_completed', {
      'step_id': 'profile', 'avatar_index': avatarIndex,
    });
    AnalyticsService.instance.screen('onboarding_courses');
    setState(() {
      _username = username;
      _currentStep = 1;
    });
  }

  void _goBackToStep1() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _goToVideoTransition(List<ApSubject> selectedCourses) {
    AnalyticsService.instance.log('onboarding_step_completed', {
      'step_id': 'courses', 'course_count': selectedCourses.length,
    });
    _selectedApCourses = List<ApSubject>.unmodifiable(selectedCourses);

    // Keep the selected titles available to the legacy onboarding state while
    // the new flow passes the exact AP course IDs forward.
    final courseController = Get.find<CourseController>();
    courseController.onboardingSelectedSubjects.value =
        selectedCourses.map((course) => course.title).toList();

    setState(() {
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000029),
      // Step 1 animates keyboard inset locally; avoid instant body shrink + avatar jump.
      resizeToAvoidBottomInset: false,
      body: OnboardingVideoBackground(
        videoController: _videoController,
        child: AnimatedSwitcher(
          duration: _currentStep == 2
              ? Duration.zero
              : const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _currentStep == 0
              ? OnboardingStep1(
                  key: const ValueKey('step1'),
                  onContinue: _goToStep2,
                )
              : _currentStep == 1
                  ? OnboardingStep2(
                      key: const ValueKey('step2'),
                      username: _username,
                      videoController: _videoController,
                      audioPlayer: _audioPlayer,
                      onComplete: _goToVideoTransition,
                      onBack: _goBackToStep1,
                    )
                  : OnboardingVideoTransition(
                      key: const ValueKey('video'),
                      videoController: _videoController,
                      audioPlayer: _audioPlayer,
                      onComplete: _completeOnboarding,
                    ),
        ),
      ),
    );
  }
}
