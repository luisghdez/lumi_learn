import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/screens/auth/launch_screen.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';
import 'package:lumi_learn_app/screens/auth/splash_screen.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class AuthGate extends StatelessWidget {
  AuthGate({Key? key}) : super(key: key);

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

      // Show onboarding screen if it hasn't been completed
      if (!hasCompletedOnboarding && user == null) {
        return LaunchScreen();
      }

      // Show login/register screen if no user is logged in
      if (user == null) {
        return SignupScreen();
      }

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

      precacheImage(const AssetImage('assets/images/milky_way.png'), context);

      // Show main screen if user is logged in
      return MainScreen();
    });
  }
}
