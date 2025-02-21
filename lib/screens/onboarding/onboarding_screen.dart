import 'package:flutter/material.dart';
import '../start/main_start.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Insights",
      "description": "Simply add a presentation, text or image and Lumi will create a personalized lesson plan!",
      "background": "lib/assets/worlds/purple1.png",
      "astronaut": "",
      "quote": "\"Education is the most powerful weapon which you can use to change the world.\" — Nelson Mandela",
      "astroSize": 0.0,
      "astroAlignment": Alignment.center,
      "astroOffset": Offset(0, 0),
    },
    {
      "title": "Galaxies",
      "description": "Each galaxy will consist of different materials to learn!",
      "background": "lib/assets/galaxies/galaxy1.png",
      "astronaut": "lib/assets/astro/astrocamera.png",
      "quote": "",
      "astroSize": 350.0,
      "astroAlignment": Alignment.centerRight,
      "astroOffset": Offset(0, -0.2), // Move higher
    },
    {
      "title": "Planets",
      "description": "Each lesson will consist of multiple planets. In each planet, you will learn a different topic according to your content.",
      "background": "lib/assets/planets/planets.png",
      "astronaut": "lib/assets/astro/astromoon.png",
      "quote": "",
      "astroSize": 450.0,
      "astroAlignment": Alignment.centerLeft,
      "astroOffset": Offset(0.4, 0), // Move more left
    },
    {
      "title": "Stars",
      "description": "Earn stars after every lesson. Compete with your friends and chase the stars!",
      "background": "lib/assets/stars/stars.png",
      "astronaut": "lib/assets/astro/astrostars.png",
      "quote": "",
      "astroSize": 350.0,
      "astroAlignment": Alignment.centerLeft,
      "astroOffset": Offset(0.1, -0.2), // Move higher
    },
  ];

  void _goToNextPage() {
    if (_currentPage < onboardingData.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      _finishOnboarding();
    }
  }

void _finishOnboarding() {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => MainStartScreen(), // Navigate to LoginScreen
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Fade Transition
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              onboardingData[_currentPage]["background"]!,
              key: ValueKey(_currentPage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Title with Animation
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Text(
                      onboardingData[_currentPage]["title"]!,
                      key: ValueKey(_currentPage),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description with Animation
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Text(
                      onboardingData[_currentPage]["description"]!,
                      key: ValueKey(_currentPage),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Quote (Only on Insights Page)
                  if (onboardingData[_currentPage]["quote"]!.isNotEmpty) ...[
                    Text(
                      onboardingData[_currentPage]["quote"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Astronaut Image with Alignment Adjustments
                  if (onboardingData[_currentPage]["astronaut"]!.isNotEmpty)
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 10),
                      child: Align(
                        key: ValueKey(_currentPage),
                        alignment: onboardingData[_currentPage]["astroAlignment"],
                        child: FractionalTranslation(
                          translation: onboardingData[_currentPage]["astroOffset"],
                          child: Image.asset(
                            onboardingData[_currentPage]["astronaut"]!,
                            height: onboardingData[_currentPage]["astroSize"],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Dots Indicator & Next Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(
                          onboardingData.length,
                          (dotIndex) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 10),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _currentPage == dotIndex
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(color: Colors.white),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next Button
                      ElevatedButton(
                        onPressed: _goToNextPage,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


