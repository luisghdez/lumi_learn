import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class TutorHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onCreateCourse;
  final VoidCallback onClearThread;
  final String? courseTitle;

  const TutorHeader({
    Key? key,
    required this.onMenuPressed,
    required this.onCreateCourse,
    required this.onClearThread,
    required this.courseTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final TutorController tutorController = Get.find<TutorController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───── Top Row: Hamburger, Avatar, Title, and Close Button ─────
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LumiTutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (courseTitle != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              courseTitle!,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: onClearThread,
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: onMenuPressed,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ───── Glassy Gradient Button ─────
        // GestureDetector(
        //   onTap: onCreateCourse,
        //   child: ClipRRect(
        //     borderRadius: const BorderRadius.only(
        //       bottomLeft: Radius.circular(14),
        //       bottomRight: Radius.circular(14),
        //     ),
        //     child: BackdropFilter(
        //       filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        //       child: Container(
        //         width: double.infinity,
        //         padding:
        //             const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        //         decoration: const BoxDecoration(
        //           gradient: LinearGradient(
        //             colors: [
        //               Color(0x55B388FF),
        //               Color(0x44D3B4FF),
        //             ],
        //             begin: Alignment.topLeft,
        //             end: Alignment.bottomRight,
        //           ),
        //           border: Border(
        //             bottom: BorderSide(color: Colors.white30),
        //             left: BorderSide(color: Colors.white30),
        //             right: BorderSide(color: Colors.white30),
        //             top: BorderSide.none,
        //           ),
        //           borderRadius: BorderRadius.only(
        //             bottomLeft: Radius.circular(14),
        //             bottomRight: Radius.circular(14),
        //           ),
        //         ),
        //         child: const Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(Icons.menu_book_rounded,
        //                 color: Colors.white, size: 18),
        //             SizedBox(width: 8),
        //             Text(
        //               'Create a course from this chat',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w500,
        //                 fontSize: 14,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 4),
      ],
    );
  }

  PageRouteBuilder _fadeRouteToMainScreen() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => MainScreen(),
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
