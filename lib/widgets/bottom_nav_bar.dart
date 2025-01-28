// widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../utils/constants.dart';
import '../screens/add_event/add_event_screen.dart';
import '../screens/add_post/add_post_screen.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  void _showAddOptions() {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Add Event'),
              onTap: () {
                Get.back(); // Close the bottom sheet
                Get.to(() => const AddEventScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Add Post'),
              onTap: () {
                Get.back(); // Close the bottom sheet
                Get.to(() => const AddPostScreen());
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// Maps the provider's currentIndex to the BottomNavigationBar's index.
  int _mapProviderIndexToBottomNav(int providerIndex) {
    if (providerIndex <= 1) {
      return providerIndex;
    } else {
      // For indices after the 'Add' button, increment by 1
      return providerIndex + 1;
    }
  }

  /// Maps the BottomNavigationBar's index to the provider's currentIndex.
  int? _mapBottomNavToProviderIndex(int bottomNavIndex) {
    if (bottomNavIndex <= 1) {
      return bottomNavIndex;
    } else if (bottomNavIndex == 2) {
      // 'Add' button does not map to a provider index
      return null;
    } else {
      // For indices after the 'Add' button, decrement by 1
      return bottomNavIndex - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Obx(
      () {
        int currentIndex = _mapProviderIndexToBottomNav(
            navigationController.currentIndex.value);

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 2) {
              // 'Add' button tapped
              _showAddOptions();
            } else {
              final newIndex = _mapBottomNavToProviderIndex(index);
              if (newIndex != null) {
                navigationController.updateIndex(newIndex);
              }
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: Constants.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: Constants.search,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 36), // Larger icon for 'Add'
              label: '', // No label for 'Add'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: Constants.messaging,
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
