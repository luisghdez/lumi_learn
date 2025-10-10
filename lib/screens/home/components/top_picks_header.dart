import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';

class TopPicksHeader extends StatelessWidget {
  final VoidCallback onAddTap;
  final int slotsUsed;
  final int maxSlots;
  final bool isPremium;
  final TextStyle titleStyle;

  const TopPicksHeader({
    Key? key,
    required this.onAddTap,
    required this.slotsUsed,
    required this.maxSlots,
    required this.isPremium,
    required this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Courses',
          style: titleStyle,
        ),
        GestureDetector(
          onTap: () {
            // Set the search controller to show saved courses
            final LumiSearchController searchController =
                Get.find<LumiSearchController>();
            searchController.showSavedCourses();

            // Navigate to search screen using navigation controller
            final NavigationController navigationController =
                Get.find<NavigationController>();
            navigationController.updateIndex(1);
          },
          child: Row(
            children: [
              Text(
                'View All',
                style: titleStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
