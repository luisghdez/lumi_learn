import 'package:flutter/material.dart';
import '../auth/main_start.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  // These are the phrases we want to bold in the text.
  final List<String> highlightPhrases = [
    "twice as effective",
    "Discover and conquer!",
    "before",
    "challenges your mind",
  ];

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Your Knowledge = Galaxies",
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
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => MainStartScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Highlights any phrases found in [highlightPhrases].
  /// Renders them in bold within the returned widget (Text.rich).
  /// If no highlights are found, returns a normal Text widget.
  Widget buildHighlightedText(String text) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    List<TextSpan> spans = [];
    int startIndex = 0;

    while (true) {
      // Find the earliest occurrence of any highlight phrase
      int earliestMatchIndex = -1;
      String? matchedPhrase;

      // We'll track the earliest index among all highlight phrases.
      for (String phrase in highlightPhrases) {
        final index = text.indexOf(phrase, startIndex);
        if (index != -1) {
          if (earliestMatchIndex == -1 || index < earliestMatchIndex) {
            earliestMatchIndex = index;
            matchedPhrase = phrase;
          }
        }
      }

      // If no more matches, add the remaining text and break
      if (earliestMatchIndex == -1 || matchedPhrase == null) {
        spans.add(
          TextSpan(
            text: text.substring(startIndex),
          ),
        );
        break;
      }

      // Add any text before this match as normal
      if (earliestMatchIndex > startIndex) {
        spans.add(
          TextSpan(
            text: text.substring(startIndex, earliestMatchIndex),
          ),
        );
      }

      // Add the matched phrase in bold
      spans.add(
        TextSpan(
          text: matchedPhrase,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );

      // Move past the matched phrase
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

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      top: true,
      bottom:
          false, // We'll manually handle bottom to avoid shifting the buttons
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Title
            Text(
              onboardingData[_currentPage]["title"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 12),

            // Primary Description
            SizedBox(
              width: 0.7 * MediaQuery.of(context).size.width,
              child: buildHighlightedText(
                onboardingData[_currentPage]["description"] ?? "",
              ),
            ),

            // For steps other than the first, show the image and secondary text
            if (_currentPage != 1) ...[
              const SizedBox(height: 12),
              Image.asset(
                onboardingData[_currentPage]["image"],
                height: 400,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 0.7 * MediaQuery.of(context).size.width,
                child: buildHighlightedText(
                  onboardingData[_currentPage]["description2"] ?? "",
                ),
              ),
            ],

            // For the first step, the full-screen image
            if (_currentPage == 1)
              Image.asset(
                onboardingData[_currentPage]["image"],
                height: 600,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      // Pin the buttons to the bottom, ignoring SafeArea so they're truly "fixed"
      left: 0,
      right: 0,
      bottom: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Left side: Completed steps (filled dots)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                  _currentPage.clamp(0, 2),
                  (index) {
                    final isMostRecent = index == _currentPage.clamp(0, 2) - 1;
                    final size = isMostRecent ? 16.0 : 10.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
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
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),

            // Right side: Upcoming steps (unfilled dots)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  (onboardingData.length - _currentPage - 1).clamp(0, 2),
                  (index) {
                    final isNextStep = index == 0;
                    final size = isNextStep ? 16.0 : 10.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/bg_2.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          // Main scrollable content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildContent(context),
          ),
          // The pinned button row
          _buildBottomButtons(),
        ],
      ),
    );
  }
}
