import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class TutorHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onCreateCourse;

  const TutorHeader({
    Key? key,
    required this.onMenuPressed,
    required this.onCreateCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───── Top Row: Hamburger, Avatar, Title, and Close Button ─────
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/astronaut/teacher2.png'),
              radius: 24,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LumiTutor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Helping 20,000 students now',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                final NavigationController navController = Get.find();
                navController.updateIndex(0);
                navController.showNavBar();
                Navigator.of(context).pushAndRemoveUntil(
                  _fadeRouteToMainScreen(),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ───── Glassy Gradient Button ─────
        GestureDetector(
          onTap: onCreateCourse,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x55B388FF),
                      Color(0x44D3B4FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.white30),
                    left: BorderSide(color: Colors.white30),
                    right: BorderSide(color: Colors.white30),
                    top: BorderSide.none,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Create a course from this chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  PageRouteBuilder _fadeRouteToMainScreen() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) =>  MainScreen(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutQuad,
          ),
          child: child,
        );
      },
    );
  }
}
