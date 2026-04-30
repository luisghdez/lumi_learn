import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';
import 'package:lumi_learn_app/application/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/services/deeplink.dart';
import 'package:lumi_learn_app/dev_flags.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';
import 'package:lumi_learn_app/screens/auth/splash_screen.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_container.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final User? user = authController.firebaseUser.value;
      final bool hasCompletedOnboarding =
          authController.hasCompletedOnboarding.value;

      if (!authController.isAuthInitialized.value) {
        return SplashScreen(); // Show a splash/loading screen
      }

      precacheImage(const AssetImage('assets/galaxies/galaxy22.png'), context);

      // Show login/register screen if no user is logged in
      if (user == null) {
        return SignupScreen();
      }

      // Initialize all controllers first (after login)
      if (!Get.isRegistered<CourseController>()) {
        Get.put<CourseController>(CourseController(), permanent: true);
      }
      final courseController = Get.find<CourseController>();
      if (!courseController.isInitialized.value) {
        return SplashScreen();
      }

      if (!Get.isRegistered<SpeakController>()) {
        Get.put<SpeakController>(
          SpeakController(),
          permanent: true,
        );
      }

      if (!Get.isRegistered<FriendsController>()) {
        Get.put<FriendsController>(
          FriendsController(),
          permanent: true,
        );
      }

      if (!Get.isRegistered<TutorController>()) {
        Get.put<TutorController>(
          TutorController(),
          permanent: true,
        );
      }

      if (!Get.isRegistered<LumiSearchController>()) {
        Get.put<LumiSearchController>(
          LumiSearchController(),
          permanent: true,
        );
      }

      if (!Get.isRegistered<VideoController>()) {
        Get.put<VideoController>(
          VideoController(),
          permanent: true,
        );
      }

      // Initialize deep link handler now that all controllers are registered
      DeepLinkHandler.instance.reinitialize();

      precacheImage(const AssetImage('assets/images/milky_way.png'), context);

      // Check onboarding AFTER login and controller initialization
      // Force onboarding preview for testing, or show if not completed
      if (DevFlags.forceOnboardingPreview || !hasCompletedOnboarding) {
        return const OnboardingContainer();
      }

      // Show main screen if user is logged in and onboarding is completed
      return const MainScreen();
    });
  }
}
