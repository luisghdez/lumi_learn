import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonProgressBar extends StatelessWidget {
  final double progress;

  const LessonProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  void _showQuitConfirmationDialog(BuildContext context) {
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 12, 12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/astronaut/sad.png',
                height: 130, // Adjust size to match UI design
              ),
              const SizedBox(height: 16),
              const Text(
                'Poof! If you quit now, all your stars from this lesson will disappear!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 28),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // simply dismiss the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Keep Learning',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      // backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // dismiss the dialog
                      Get.back(); // dismiss lesson
                    },
                    child: const Text('Quit', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          iconSize: 30,
          onPressed: () {
            _showQuitConfirmationDialog(context);
          },
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 5,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, animatedProgress, child) {
                  return LinearProgressIndicator(
                    value: animatedProgress,
                    backgroundColor: const Color.fromARGB(113, 158, 158, 158),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 255, 255, 255),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
