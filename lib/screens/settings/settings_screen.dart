import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/settings/screens/notifications_screen.dart';
import 'package:lumi_learn_app/screens/settings/screens/help_support_screen.dart';
import 'package:lumi_learn_app/screens/settings/screens/feedback_screen.dart';
import 'package:lumi_learn_app/screens/settings/screens/whats_new_screen.dart';
import 'package:lumi_learn_app/screens/settings/screens/subscription_screen.dart';
import 'package:lumi_learn_app/screens/settings/screens/more_settings_screen.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final isSmallPhone = size.height < 700;

    final double titleFontSize = isTablet
        ? 26
        : isSmallPhone
            ? 18
            : 22;
    final double tileFontSize = isTablet
        ? 17
        : isSmallPhone
            ? 13.5
            : 15;
    final double topSpacing = isSmallPhone ? 60 : 100;
    final double tileIconSize = isSmallPhone ? 20 : 24;
    final double tilePadding = isSmallPhone ? 14 : 18;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: isSmallPhone ? 16 : 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: topSpacing),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                          top: 10,
                          bottom:
                              isSmallPhone ? 80 : 120), // Safe space for Logout
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _controller,
                            curve: Interval(index * 0.1, 1.0,
                                curve: Curves.easeOut),
                          ),
                          child: _glassOptionTile(
                            icon: _tiles[index]['icon'] as IconData,
                            title: _tiles[index]['title'] as String,
                            iconSize: tileIconSize,
                            fontSize: tileFontSize,
                            paddingVertical: tilePadding,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Get.to(_tiles[index]['screen'] as Widget);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: isSmallPhone ? 30 : 60,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _confirmLogout(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 14 : 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassOptionTile({
    required IconData icon,
    required String title,
    required double fontSize,
    required double iconSize,
    required double paddingVertical,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }

void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          "Are you sure you want to log out? You'll need to sign in again to access your courses.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Logout button with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.8),
                Colors.redAccent.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              authController.signOut();
              Navigator.pop(context);
              Get.offAll(() => SignupScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

final List<Map<String, dynamic>> _tiles = [
  {
    'icon': Icons.help_outline,
    'title': 'Help and Support',
    'screen': const HelpSupportScreen(),
  },
  {
    'icon': Icons.feedback_outlined,
    'title': 'Give a feedback',
    'screen': const FeedbackScreen(),
  },
  {
    'icon': Icons.auto_awesome_rounded,
    'title': "What's New",
    'screen': const WhatsNewScreen(),
  },
  {
    'icon': Icons.workspace_premium_outlined,
    'title': "Subscription",
    'screen': const SubscriptionScreen(),
  },
  {
    'icon': Icons.settings_suggest_outlined,
    'title': "More Settings",
    'screen': const MoreSettingsScreen(),
  },
];