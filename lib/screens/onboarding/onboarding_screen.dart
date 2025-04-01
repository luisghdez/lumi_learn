import 'package:flutter/material.dart';
import '../auth/main_start.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Bold phrases
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
        if (index != -1) {
          if (earliestMatchIndex == -1 || index < earliestMatchIndex) {
            earliestMatchIndex = index;
            matchedPhrase = phrase;
          }
        }
      }

      // No more matches, add remaining text and break
      if (earliestMatchIndex == -1 || matchedPhrase == null) {
        spans.add(
          TextSpan(text: text.substring(startIndex)),
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

  Widget _buildSinglePage(int index) {
    final data = onboardingData[index];
    final String title = data["title"] ?? "";
    final String description = data["description"] ?? "";
    final String description2 = data["description2"] ?? "";
    final String image = data["image"] ?? "";
    final bool isFullImage = data["isFullImage"] ?? false;

    return SafeArea(
      top: true,
      bottom: false, // We'll handle the bottom with pinned buttons
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Title
            Text(
              title,
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
              child: buildHighlightedText(description),
            ),

            // For steps other than the second, show the smaller image + second text
            if (index != 1) ...[
              const SizedBox(height: 12),
              Image.asset(
                image,
                height: 400,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 0.7 * MediaQuery.of(context).size.width,
                child: buildHighlightedText(description2),
              ),
            ],

            // For the second step (index == 1), bigger image
            if (index == 1)
              Image.asset(
                image,
                height: isFullImage ? 600 : 400,
              ),
          ],
        ),
      ),
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
            // Left side: Completed steps (up to 2)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < 2; i++)
                    AnimatedSwitcher(
                      // Each dot uses a distinct key
                      key: ValueKey('completed-dot-$i'),
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        // Simple fade transition
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: i < completedCount
                          ? GestureDetector(
                              onTap: () {
                                // This dot represents page:
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
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),

            // Right side: Upcoming steps (up to 2)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int i = 0; i < 2; i++)
                    AnimatedSwitcher(
                      key: ValueKey('upcoming-dot-$i'),
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: i < upcomingCount
                          ? GestureDetector(
                              onTap: () {
                                // This dot represents the next pages
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
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/bg_2.png',
              fit: BoxFit.fitWidth,
            ),
          ),

          // PageView for smooth sliding
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSinglePage(index);
            },
          ),

          // Pinned bottom buttons with fade-in/out circle transitions
          _buildBottomButtons(),
        ],
      ),
    );
  }
}
