import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/videos/create_video_screen.dart';
import 'package:lumi_learn_app/widgets/create_action_sheet.dart';
import '../application/controllers/navigation_controller.dart';
import '../utils/constants.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _HideableNavBarPageState();
}

class _HideableNavBarPageState extends State<BottomNavbar> {
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

      return AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        offset: navigationController.isNavBarVisible.value
            ? Offset.zero
            : const Offset(0, 1),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavItem(
                          icon: Icons.home,
                          label: Constants.home,
                          isSelected: currentIndex == 0,
                          onTap: () => navigationController.updateIndex(0),
                        ),
                        _NavItem(
                          icon: Icons.menu_book_outlined,
                          label: 'Courses',
                          isSelected: currentIndex == 1,
                          onTap: () => navigationController.updateIndex(1),
                        ),
                        _CreateNavButton(onTap: _showCreateSheet),
                        _NavItem(
                          icon: Icons.person,
                          label: Constants.profile,
                          isSelected: currentIndex == 2,
                          onTap: () => navigationController.updateIndex(2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  height: 1,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateNavButton extends StatelessWidget {
  const _CreateNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 58,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
