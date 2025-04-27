import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'topic_selection.dart';

class AgeSelectionScreen extends StatelessWidget {
  AgeSelectionScreen({Key? key, required this.onCompleteOnboarding}) : super(key: key);

  final VoidCallback onCompleteOnboarding;

  final List<Map<String, String>> ageGroups = [
    {"label": "5-7", "value": "5-7"},
    {"label": "8-10", "value": "8-10"},
    {"label": "11-13", "value": "11-13"},
    {"label": "14-17", "value": "14-17"},
    {"label": "18-22", "value": "18-22"},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isTablet ? 48.0 : 24.0;
    final double titleFontSize = isTablet ? 32.0 : 24.0;
    final double cardHeight = isTablet ? 90.0 : 70.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "How old are you?",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: titleFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: ageGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final ageGroup = ageGroups[index];
                        return InkWell(
                          onTap: () {
                            Get.to(
                              () => TopicSelectionScreen(
                                ageGroup: ageGroup["value"]!,
                                onCompleteOnboarding: onCompleteOnboarding, // ✅ Pass it forward
                              ),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 400),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ageGroup["label"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 22 : 18,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
