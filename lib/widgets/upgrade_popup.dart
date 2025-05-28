import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class UpgradePopup extends StatelessWidget {
  final String title;
  final String? subtitle;

  const UpgradePopup({
    Key? key,
    this.title = "",
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double titleFontSize = isTablet ? 46 : 30;

    return Dialog(
        insetPadding: EdgeInsets.zero, // Full-screen edge
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons_lighter.png',
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
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.4,
                                            letterSpacing: -1.2,
                                          ),
                                          children: [
                                            const TextSpan(
                                                text: "Upgrade to\n"),
                                            TextSpan(
                                              text: "Lumi PRO\n",
                                              style: TextStyle(
                                                foreground: Paint()
                                                  ..shader =
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFF0004FF),
                                                      Color.fromARGB(
                                                          255, 124, 207, 255),
                                                      Color(0xFFA600FF),
                                                    ],
                                                  ).createShader(
                                                    const Rect.fromLTWH(
                                                        0.0, 0.0, 300.0, 50.0),
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
                                      height: isTablet ? 250 : 145,
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'course generation'),
                                  ],
                                ),
                                const BenefitItem(
                                  assetPath: 'assets/icons/book.png',
                                  textSpans: [
                                    TextSpan(
                                        text: 'Complete ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'course content'),
                                  ],
                                ),
                                const BenefitItem(
                                  assetPath: 'assets/icons/unlock.png',
                                  textSpans: [
                                    TextSpan(
                                        text: 'Full Access ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'to shared courses'),
                                  ],
                                ),
                                const BenefitItem(
                                  assetPath: 'assets/icons/headset.png',
                                  textSpans: [
                                    TextSpan(
                                        text: 'Speaking and Listening ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'practice'),
                                  ],
                                ),
                                const BenefitItem(
                                  assetPath: 'assets/icons/trash.png',
                                  textSpans: [
                                    TextSpan(
                                        text: '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'Edit/delete your courses'),
                                  ],
                                ),
                                const BenefitItem(
                                  assetPath: 'assets/icons/xpstar.png',
                                  textSpans: [
                                    TextSpan(
                                        text: 'XP Boosts, ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            'profile cosmetics, achievements'),
                                  ],
                                ),

                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Pinned bottom
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () async {
                                try {
                                  final offerings =
                                      await Purchases.getOfferings();
                                  final current = offerings.current;

                                  if (current != null &&
                                      current.availablePackages.isNotEmpty) {
                                    final package =
                                        current.availablePackages.first;
                                    await Purchases.purchasePackage(package);

                                    authController.isPremium.value = true;
                                    Get.back();
                                    Get.dialog(const LumiProSuccessDialog());
                                  } else {
                                    Get.snackbar("Oops",
                                        "No subscription packages available.");
                                  }
                                } on PlatformException catch (error) {
                                  if (error.code == "purchaseCancelled" ||
                                      error.code == "1") {
                                    return;
                                  } else if (error.code == "network_error") {
                                    Get.snackbar("Network Error",
                                        "Please check your internet connection and try again.");
                                  } else {
                                    Get.snackbar("Error",
                                        "Something went wrong: ${error.message}");
                                  }
                                } catch (_) {
                                  Get.snackbar(
                                      "Error", "An unexpected error occurred.");
                                }
                              },
                              child: const Text(
                                "Try for \$7.99/month",
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
                            const SizedBox(height: 42),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
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
            width: 55,
            height: 55,
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

class LumiProSuccessDialog extends StatelessWidget {
  const LumiProSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            width: 320,
            height: 560,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: AssetImage('assets/images/lumi_pro_success_dialog.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome to",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 8,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF0004FF),
                              Color.fromARGB(255, 124, 207, 255),
                              Color.fromARGB(255, 174, 124, 255),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          "LUMI PRO",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Start Exploring!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
