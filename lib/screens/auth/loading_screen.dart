import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  width: 300, // Adjust width
                  height: 300, // Adjust height
                  child: Image.asset('assets/astronaut/whistling.png'),
                ),
                const SizedBox(height: 20), // Spacing between image and text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w300, // Bold
                        height:
                            0.8, // Adjust line height (default might be too spaced out)
                        letterSpacing:
                            -2, // Reduce letter spacing for a tighter look
                        // Removed fontVariations as it is not a valid parameter
                        color: const Color.fromARGB(94, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}