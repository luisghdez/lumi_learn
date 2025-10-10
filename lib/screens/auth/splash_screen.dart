import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png', // your background
              fit: BoxFit.cover,
            ),
          ),

          // FOREGROUND CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth * 0.6, // 40% of screen width
                  child: Image.asset('assets/splash/moon_splash.png'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}