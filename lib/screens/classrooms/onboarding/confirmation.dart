import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final String ageGroup;
  final List<String> selectedTopics;
  final VoidCallback onCompleteOnboarding;

  ConfirmationScreen({
    super.key,
    required this.ageGroup,
    required this.selectedTopics,
    required this.onCompleteOnboarding,
  });

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isTablet ? 48.0 : 24.0;
    final double titleFontSize = isTablet ? 32.0 : 26.0;
    final double subtitleFontSize = isTablet ? 20.0 : 18.0;

    final String userName =
        authController.firebaseUser.value?.displayName ?? "Student";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png', // your background
              fit: BoxFit.cover,
            ),
          ),
          // FOREGROUND
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // 🔙 Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Title
                      Text(
                        "Hey, $userName",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Welcome to Lumi Classrooms.",
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Age Group:",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ageGroup,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Your Interests:",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedTopics.map((topic) {
                          return Chip(
                            label: Text(
                              topic,
                              style: const TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color:
                                    Colors.purpleAccent.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final AuthController authController = Get.find();
                      authController
                          .setUserRole(UserRole.student); // ✅ Set userRole
                      await authController.completeOnboarding();

                      final NavigationController navigationController =
                          Get.find();
                      navigationController
                          .updateIndex(0); // 0 = Feed tab in the main shell
                      Get.offAll(() =>
                          const MainScreen()); // Go back cleanly to the main structure
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
