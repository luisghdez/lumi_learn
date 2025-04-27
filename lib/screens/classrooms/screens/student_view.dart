import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import '../components/home_header.dart';
import 'dart:math' as math; // 👈 for safe constraints


class StudentView extends StatelessWidget {
  StudentView({super.key});

  final AuthController authController = Get.find();
  static const double _tabletBreakpoint = 800.0;

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > _tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = _getHorizontalPadding(context);
    final double topScrollViewPadding = MediaQuery.of(context).padding.top + horizontalPadding;
    const double bottomScrollViewPadding = 40.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= _tabletBreakpoint;

    final TextStyle sectionTitleStyle = isTablet
        ? Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            )
        : const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            decoration: TextDecoration.none,
          );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/black_moons_lighter.png',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double calculatedMinHeight = math.max(
                0.0,
                constraints.maxHeight - topScrollViewPadding - bottomScrollViewPadding,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: topScrollViewPadding,
                  bottom: bottomScrollViewPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: calculatedMinHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Obx(() => HomeHeader(
                              streakCount: authController.streakCount.value,
                              xpCount: authController.xpCount.value,
                              isPremium: authController.isPremium.value,
                            )),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          'Student Dashboard',
                          style: sectionTitleStyle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // TODO: Add teacher-specific widgets here
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
