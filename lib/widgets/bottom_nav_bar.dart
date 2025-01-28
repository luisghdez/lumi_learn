import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart';
import '../screens/add_event/add_event_screen.dart';
import '../screens/add_post/add_post_screen.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Add Event'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Close the modal
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEventScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.post_add),
                title: const Text('Add Post'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Close the modal
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddPostScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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
    final navigationProvider = Provider.of<NavigationProvider>(context);
    int currentIndex =
        _mapProviderIndexToBottomNav(navigationProvider.currentIndex);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) {
          // 'Add' button tapped
          _showAddOptions(context);
        } else {
          final newIndex = _mapBottomNavToProviderIndex(index);
          if (newIndex != null) {
            navigationProvider.updateIndex(newIndex);
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
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
