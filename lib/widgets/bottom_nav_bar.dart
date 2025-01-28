// widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../utils/constants.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Obx(
      () {
        int currentIndex = navigationController.currentIndex.value;

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            navigationController.updateIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: Constants.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), // Using group icon for 'Social'
              label: Constants.social, // Ensure Constants.social is defined
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: Constants.profile,
            ),
          ],
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
        );
      },
    );
  }
}
