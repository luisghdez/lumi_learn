import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';
import 'package:lumi_learn_app/application/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
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
      final authInit = authController.isAuthInitialized.value;
      final User? user = authController.firebaseUser.value;
      final bool hasCompletedOnboarding =
          authController.hasCompletedOnboarding.value;

      late final String phaseKey;
      late final Widget phaseChild;

      if (!authInit) {
        phaseKey = 'splash_auth';
        phaseChild = SplashScreen();
      } else if (user == null) {
        phaseKey = 'auth';
        phaseChild = SignupScreen();
      } else {
        if (!Get.isRegistered<CourseController>()) {
          Get.put<CourseController>(CourseController(), permanent: true);
        }
        final courseController = Get.find<CourseController>();
        if (!courseController.isInitialized.value) {
          phaseKey = 'splash_post_login';
          phaseChild = SplashScreen();
        } else {
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

          if (!Get.isRegistered<CreateFlowController>()) {
            Get.put<CreateFlowController>(
              CreateFlowController(),
              permanent: true,
            );
          }

          DeepLinkHandler.instance.reinitialize();

          precacheImage(const AssetImage('assets/images/milky_way.png'), context);

          if (DevFlags.forceOnboardingPreview || !hasCompletedOnboarding) {
            phaseKey = 'onboarding';
            phaseChild = const OnboardingContainer();
          } else {
            phaseKey = 'main';
            phaseChild = const MainScreen();
          }
        }
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(phaseKey),
          child: phaseChild,
        ),
      );
    });
  }
}
