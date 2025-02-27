import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/auth/launch_screen.dart';
import 'package:lumi_learn_app/screens/auth/login_screen.dart';
import 'package:lumi_learn_app/screens/auth/main_start.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pseudocode: Replace with your own auth logic.
    final bool isLoggedIn = false /* check your auth state */;
    final bool hasCompletedOnboarding = false /* check onboarding state */;

    if (!hasCompletedOnboarding) {
      // return MainStartScreen();
      return LaunchScreen();
      // ignore: dead_code
    } else if (!isLoggedIn) {
      // return LoginScreen();
      return MainStartScreen();
    } else {
      return const MainScreen();
    }
  }
}
