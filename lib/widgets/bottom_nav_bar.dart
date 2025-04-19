import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../utils/constants.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

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
      int currentIndex = navigationController.currentIndex.value;

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
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    // remove all ink splashes
                    splashFactory: NoSplash.splashFactory,
                    // make highlight (the darker overlay on tap) transparent
                    highlightColor: Colors.transparent,
                  ),
                  child: IntrinsicHeight(
                    child: BottomNavigationBar(
                      currentIndex: currentIndex,
                      backgroundColor: Colors.grey[900],
                      onTap: (index) {
                        navigationController.updateIndex(index);
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: Constants.home,
                        ),
                        // BottomNavigationBarItem(
                        //   icon: Icon(Icons.emoji_events), // Leaderboard (Trophy)
                        //   label: Constants.leaderboard,
                        // ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person), // Leaderboard (Trophy)
                          label: Constants.profile,
                        ),
                      ],
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey,
                      showUnselectedLabels: false,
                      showSelectedLabels: false,
                      iconSize: 28,
                      type: BottomNavigationBarType.fixed,
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
}
