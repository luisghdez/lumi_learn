import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_step1.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_step2.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_video_transition.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
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
  bool _shouldDisposeController = true;

  @override
  void initState() {
    super.initState();
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
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    if (_shouldDisposeController) {
      _videoController.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    authController.hasCompletedOnboarding.value = true;
    _shouldDisposeController = false; // Pass ownership to next screen

    Get.offAll(
      () => CourseCreation(
        fromOnboarding: true,
        videoController: _videoController,
      ),
      transition: Transition.noTransition,
    );
  }

  void _goToStep2(String username, int avatarIndex) {
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

  void _goToVideoTransition(List<String> selectedSubjects) {
    // Save selected subjects to CourseController
    final courseController = Get.find<CourseController>();
    courseController.onboardingSelectedSubjects.value = selectedSubjects;

    setState(() {
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000029),
      body: OnboardingVideoBackground(
        videoController: _videoController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
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
                      onComplete: _completeOnboarding,
                    ),
        ),
      ),
    );
  }
}
