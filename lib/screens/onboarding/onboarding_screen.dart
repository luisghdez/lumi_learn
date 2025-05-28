import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AuthController authController = Get.find<AuthController>();
  late PageController _pageController;
  int _currentPage = 0;

  final List<String> highlightPhrases = [
    "twice as effective",
    "Discover and conquer!",
    "before",
    "challenges your mind",
  ];

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Knowledge Become Galaxies",
      "description": "Each course you create becomes its own galaxy.",
      "description2": "Every planet is a lesson or quiz. Discover and conquer!",
      "image": "assets/onboarding/screenshot.png",
    },
    {
      "title": "Prepare Before \n You Land",
      "description": "Review key concepts before starting quizzes",
      "description2": "",
      "image": "assets/onboarding/flashcard_highlight2.png",
      "isFullImage": true,
    },
    {
      "title": "Learn on Every Planet",
      "description2": "Each planet challenges your mind in different ways.",
      "image": "assets/onboarding/lessons.png",
    },
    {
      "title": "Talk to Lumi to review!",
      "description": "Explaining aloud can make learning twice as effective.",
      "description2":
          "We use your mic for voice features. You'll be asked for permission next.",
      "image": "assets/onboarding/speak.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _goToNextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    authController.hasCompletedOnboarding.value = true;

    Get.to(
      () => SignupScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  /// Highlights any phrases found in [highlightPhrases] and renders them bold.
  Widget buildHighlightedText(String text) {
    if (text.isEmpty) return const SizedBox();

    List<TextSpan> spans = [];
    int startIndex = 0;

    while (true) {
      // Find earliest occurrence of any highlight phrase
      int earliestMatchIndex = -1;
      String? matchedPhrase;
      for (String phrase in highlightPhrases) {
        final index = text.indexOf(phrase, startIndex);
        if (index != -1 &&
            (earliestMatchIndex == -1 || index < earliestMatchIndex)) {
          earliestMatchIndex = index;
          matchedPhrase = phrase;
        }
      }

      if (earliestMatchIndex == -1 || matchedPhrase == null) {
        spans.add(TextSpan(text: text.substring(startIndex)));
        break;
      }

      if (earliestMatchIndex > startIndex) {
        spans.add(
            TextSpan(text: text.substring(startIndex, earliestMatchIndex)));
      }

      spans.add(TextSpan(
          text: matchedPhrase,
          style: const TextStyle(fontWeight: FontWeight.w800)));

      startIndex = earliestMatchIndex + matchedPhrase.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildSinglePage(int index) {
    final data = onboardingData[index];
    final String title = data["title"] ?? "";
    final String description = data["description"] ?? "";
    final String description2 = data["description2"] ?? "";
    final String image = data["image"] ?? "";
    final bool isFullImage = data["isFullImage"] ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        final isTablet = screenWidth >= 768 || screenHeight >= 1000;

        // Adjust image height based on device type
        final imageHeight = index == 1
            ? (isFullImage
                ? (isTablet ? screenHeight * 0.9 : screenHeight * 0.65)
                : (isTablet ? screenHeight * 0.8 : screenHeight * 0.6))
            : index == 2
                ? (isTablet ? screenHeight * 0.65 : screenHeight * 0.55)
                : (isTablet ? screenHeight * 0.65 : screenHeight * 0.42);

        final titleFontSize =
            isTablet ? screenWidth * 0.06 : screenWidth * 0.08;

        return SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.03),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: titleFontSize.clamp(22.0, 44.0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),

                SizedBox(
                  width: screenWidth * 0.8,
                  child: buildHighlightedText(description),
                ),

                if (index != 1) ...[
                  SizedBox(height: screenHeight * 0.03),
                  Image.asset(
                    image,
                    height: imageHeight,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: buildHighlightedText(description2),
                  ),
                ],

                if (index == 1)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.04),
                    child: Image.asset(
                      image,
                      height: imageHeight,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    final completedCount = _currentPage.clamp(0, 2);
    final upcomingCount =
        (onboardingData.length - _currentPage - 1).clamp(0, 2);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < 2; i++)
                    AnimatedSwitcher(
                      key: ValueKey('completed-dot-$i'),
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: i < completedCount
                          ? GestureDetector(
                              onTap: () {
                                final pageIndex =
                                    _currentPage - completedCount + i;
                                if (pageIndex >= 0) {
                                  _pageController.animateToPage(
                                    pageIndex,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                key: ValueKey('circle-completed-$i'),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: (i == completedCount - 1) ? 16 : 10,
                                height: (i == completedCount - 1) ? 16 : 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),

            // Center: Next Button
            ElevatedButton(
              onPressed: _goToNextPage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
              ),
              child: const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.arrow_forward, color: Colors.black, size: 24),
              ),
            ),

            // Right: Upcoming
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int i = 0; i < 2; i++)
                    AnimatedSwitcher(
                      key: ValueKey('upcoming-dot-$i'),
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: i < upcomingCount
                          ? GestureDetector(
                              onTap: () {
                                final pageIndex = _currentPage + 1 + i;
                                if (pageIndex < onboardingData.length) {
                                  _pageController.animateToPage(
                                    pageIndex,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                key: ValueKey('circle-upcoming-$i'),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: (i == 0) ? 16 : 10,
                                height: (i == 0) ? 16 : 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.transparent,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000029),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/bg_2.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildSinglePage(index),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }
}
