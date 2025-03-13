import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';

class LessonProgressBar extends StatelessWidget {
  final double progress;
  final VoidCallback? onClose;

  const LessonProgressBar({
    Key? key,
    required this.progress,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          onPressed: onClose ?? () => Get.back(),
          iconSize: 30,
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
