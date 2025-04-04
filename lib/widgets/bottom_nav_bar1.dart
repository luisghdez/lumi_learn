// // widgets/bottom_nav_bar.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/navigation_controller.dart';
// import '../utils/constants.dart';

// class BottomNavbar extends StatelessWidget {
//   const BottomNavbar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final NavigationController navigationController = Get.find();

//     return Obx(
//       () {
//         int currentIndex = navigationController.currentIndex.value;

//         return BottomNavigationBar(
//           currentIndex: currentIndex,
//           backgroundColor: Colors.grey[900],
//           onTap: (index) {
//             navigationController.updateIndex(index);
//           },
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: Constants.home,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.group), // Social (Friends)
//                   label: Constants.social,
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.emoji_events), // Leaderboard (Trophy)
//                   label: "Leaderboard",
//                 ),
//               ],
//           selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
//           unselectedItemColor: const Color.fromARGB(255, 112, 112, 112),
//           showUnselectedLabels: false,
//           showSelectedLabels: false,
//           iconSize: 32,
//           type: BottomNavigationBarType.fixed,
//         );
//       },
//     );
//   }
// }