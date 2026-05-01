import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/videos/create_video_screen.dart';
import 'package:lumi_learn_app/widgets/create_action_sheet.dart';

import '../application/controllers/navigation_controller.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final NavigationController navigationController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildAnimatedNavBar(),
    );
  }

  Widget _buildAnimatedNavBar() {
    return Obx(() {
      final currentIndex = navigationController.currentIndex.value;
      final visible = navigationController.isNavBarVisible.value;
      // Index 0 == Feed/video screen — bar collapses flush to the bottom
      // so the focus stays on the videos.
      final flushMode = currentIndex == 0;

      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_rounded,
            isSelected: currentIndex == 0,
            onTap: () => navigationController.updateIndex(0),
          ),
          _NavIcon(
            icon: Icons.auto_stories_rounded,
            isSelected: currentIndex == 1,
            onTap: () => navigationController.updateIndex(1),
          ),
          _CreateButton(onTap: _showCreateSheet),
          _NavIcon(
            icon: Icons.person_rounded,
            isSelected: currentIndex == 2,
            onTap: () => navigationController.updateIndex(2),
          ),
        ],
      );

      return AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.6),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: flushMode ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              final radius = lerpDouble(40, 0, t)!;
              final hPad = lerpDouble(28, 0, t)!;
              final bgAlpha = lerpDouble(0.06, 0.18, t)!;
              final borderAlpha = lerpDouble(0.12, 0.0, t)!;
              final shadowAlpha = lerpDouble(0.45, 0.0, t)!;
              final safeBottom = MediaQuery.of(context).padding.bottom;
              // In floating mode the safe inset goes OUTSIDE the pill, in
              // flush mode it goes INSIDE so the bar background extends
              // edge-to-edge while keeping icons above the home indicator.
              final outerBottomPad = lerpDouble(10 + safeBottom, 0, t)!;
              final innerBottomPad = lerpDouble(0, safeBottom, t)!;

              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, outerBottomPad),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: bgAlpha),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: borderAlpha),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: shadowAlpha),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashFactory: NoSplash.splashFactory,
                          highlightColor: Colors.transparent,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            innerBottomPad,
                          ),
                          child: SizedBox(
                            height: 68,
                            child: row,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _showCreateSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      isScrollControlled: true,
      builder: (_) {
        return CreateActionSheet(
          onCreateVideo: () {
            Navigator.of(context).pop();
            Get.to(
              () => const CreateVideoScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
          },
          onCreateCourse: () {
            Navigator.of(context).pop();
            Get.to(
              () => const CourseCreation(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 400),
            );
          },
        );
      },
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.55),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE4E4E4),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.22),
              blurRadius: 18,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
