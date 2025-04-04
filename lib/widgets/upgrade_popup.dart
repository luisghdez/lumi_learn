import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpgradePopup extends StatelessWidget {
  final String title;
  final String? subtitle;

  const UpgradePopup({
    Key? key,
    this.title = "Upgrade to Premium",
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // Full-screen edge
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/bg_2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),

          // Safe area so we don't get stuck behind notches, etc.
          SafeArea(
            top: true,
            bottom: false, // We’ll handle bottom with pinned buttons
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Optional title at the top
                          Center(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Row with gradient text + astronaut
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.4,
                                      letterSpacing: -1.2,
                                    ),
                                    children: [
                                      const TextSpan(text: "Upgrade to\n"),
                                      TextSpan(
                                        text: "Lumi Premium\n",
                                        style: TextStyle(
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: [
                                                Color(0xFF0004FF),
                                                Color(0xFFA600FF),
                                              ],
                                            ).createShader(
                                              Rect.fromLTWH(
                                                0.0,
                                                0.0,
                                                300.0,
                                                50.0,
                                              ),
                                            ),
                                        ),
                                      ),
                                      const TextSpan(text: "And unlock:"),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Image.asset(
                                'assets/astronaut/riding.png',
                                height: 145,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Benefits
                          const BenefitItem(
                            assetPath: 'assets/icons/infinite.png',
                            textSpans: [
                              TextSpan(
                                text: 'Unlimited ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'course generation'),
                            ],
                          ),
                          const BenefitItem(
                            assetPath: 'assets/icons/book.png',
                            textSpans: [
                              TextSpan(
                                text: 'Complete ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'course content'),
                            ],
                          ),
                          const BenefitItem(
                            assetPath: 'assets/icons/unlock.png',
                            textSpans: [
                              TextSpan(
                                text: 'Full Access ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'to shared courses'),
                            ],
                          ),
                          const BenefitItem(
                            assetPath: 'assets/icons/headset.png',
                            textSpans: [
                              TextSpan(
                                text: 'Speaking and Listening ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'practice'),
                            ],
                          ),
                          const BenefitItem(
                            assetPath: 'assets/icons/trash.png',
                            textSpans: [
                              TextSpan(
                                text: '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'Edit/delete your courses'),
                            ],
                          ),
                          const BenefitItem(
                            assetPath: 'assets/icons/xpstar.png',
                            textSpans: [
                              TextSpan(
                                text:
                                    'XP Boosts, profile cosmetics, achievements',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'ever'),
                            ],
                          ),

                          // Add extra spacing at the bottom of scroll area
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),

                // Pinned bottom: CTA Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // Trigger subscription flow
                          Get.back();
                          // Get.to(() => const UpgradeScreen());
                        },
                        child: const Text(
                          "Try for \$4.99/month",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "No thanks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Some space so it's not flush to the screen edge
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BenefitItem extends StatelessWidget {
  final String assetPath;
  final List<InlineSpan> textSpans;

  const BenefitItem({
    Key? key,
    required this.assetPath,
    required this.textSpans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                children: textSpans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
