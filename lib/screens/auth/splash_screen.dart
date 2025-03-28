import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Adjust background color
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150, // Adjust width
              height: 150, // Adjust height
              child: Image.asset('assets/astronaut/astromoonFull.png'),
            ),
            const SizedBox(height: 20), // Spacing between image and text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lumi',
                  style: GoogleFonts.poppins(
                    fontSize: 60,
                    fontWeight: FontWeight.w800, // Bold
                    height:
                        0.8, // Adjust line height (default might be too spaced out)
                    letterSpacing:
                        -2, // Reduce letter spacing for a tighter look
                    // Removed fontVariations as it is not a valid parameter
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'LEARN',
                  style: TextStyle(
                    fontSize: 25, // Adjust font size
                    color: Color.fromARGB(
                        255, 255, 255, 255), // Change color as needed
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
