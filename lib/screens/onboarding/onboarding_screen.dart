import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Insights",
      "description": "Simply add a presentation, text or image and Lumi will create a personalized lesson plan!",
      "background": "lib/assets/worlds/purple1.png",
      "astronaut": "",
    },
    {
      "title": "Galaxies",
      "description": "Simply add a presentation, text or image and Lumi will create a personalized lesson plan!",
      "background": "lib/assets/galaxies/galaxy1.png",
      "astronaut": "lib/assets/astro/astro_binoculars.png",
    },
    {
      "title": "Planets",
      "description": "Each lesson will consist of multiple planets. In each planet you will learn a different topic according to your content.",
      "background": "lib/assets/planets/planets.png",
      "astronaut": "lib/assets/astro/astro_reading.png",
    },
    {
      "title": "Stars",
      "description": "Earn stars after every lesson. Compete with your friends and chase the stars!",
      "background": "lib/assets/stars/stars.png",
      "astronaut": "lib/assets/astro/astro_star.png",
    },
  ];

  void _goToNextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/home'); // Change '/home' to your main screen route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for Onboarding Screens
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      onboardingData[index]["background"]!,
                      fit: BoxFit.cover,
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

                          // Title
                          Text(
                            onboardingData[index]["title"]!,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            onboardingData[index]["description"]!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),

                          const Spacer(),

                          // Astronaut Image (if available)
                          if (onboardingData[index]["astronaut"]!.isNotEmpty)
                            Center(
                              child: Image.asset(
                                onboardingData[index]["astronaut"]!,
                                height: 180,
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
                                    child: Container(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
