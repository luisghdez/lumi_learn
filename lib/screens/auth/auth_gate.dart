import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/auth/launch_screen.dart';
import 'package:lumi_learn_app/screens/auth/login_screen.dart';
import 'package:lumi_learn_app/screens/auth/main_start.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isImagePrecached = false;

  // Pseudocode for auth and onboarding checks:
  final bool isLoggedIn = true;
  final bool hasCompletedOnboarding = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pre-cache the image if MainScreen is about to load and it's not already cached.
    if (isLoggedIn && hasCompletedOnboarding && !_isImagePrecached) {
      precacheImage(const AssetImage('assets/images/milky_way.png'), context)
          .then((_) {
        setState(() {
          _isImagePrecached = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pseudocode: Replace with your actual auth logic.

    if (!hasCompletedOnboarding) {
      return LaunchScreen();
    } else if (!isLoggedIn) {
      return MainStartScreen();
    } else {
      return const MainScreen();
    }
  }
}
