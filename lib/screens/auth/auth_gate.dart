import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/screens/auth/launch_screen.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';
import 'package:lumi_learn_app/screens/auth/spash_screen.dart';
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

      // Show onboarding screen if it hasn't been completed
      if (!hasCompletedOnboarding) {
        return LaunchScreen();
      }

      // Show login/register screen if no user is logged in
      if (user == null) {
        print("User is not logged in");
        return SignupScreen();
      }

      print("User is logged in: ${user.displayName}");

      if (!Get.isRegistered<CourseController>()) {
        Get.put<CourseController>(CourseController(), permanent: true);
      }
      final courseController = Get.find<CourseController>();
      if (!courseController.isInitialized.value) {
        return SplashScreen();
      }

      if (!Get.isRegistered<SpeakController>()) {
        Get.put<SpeakController>(
          SpeakController(), // no terms yet, we'll set them later
          permanent: true,
        );
      }

      precacheImage(const AssetImage('assets/images/milky_way.png'), context);

      // Show main screen if user is logged in
      return MainScreen();
    });
  }
}
