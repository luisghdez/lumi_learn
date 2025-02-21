import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart'; // Import the onboarding screen

class LaunchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/worlds/red1.png', // Path to the background image
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title & Subtitle
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100), // Space from top
                      Text(
                        "Lumi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Learner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You will learn everything there is to learn",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Spacer to push astronaut and button to bottom
                  Spacer(),

                  // Stack for astronaut and button
                  Stack(
                    clipBehavior: Clip.none, // Prevent clipping the astronaut
                    alignment: Alignment.bottomRight, // Align astronaut at bottom right
                    children: [
                      // Astronaut Positioned Outside the Button
                      Positioned(
                        bottom: 10, // Adjust to make it hover over button
                        right: 0, // Slightly out of bounds for better effect
                        child: Image.asset(
                          'lib/assets/astro/astro1.png',
                          height: 220, // Adjust size to match UI design
                        ),
                      ),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to the Onboarding Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 26),
                          ),
                          child: const Text(
                            "Start Learning →",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20), // Space from bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
