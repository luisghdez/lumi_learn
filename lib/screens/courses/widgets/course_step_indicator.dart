import 'package:flutter/material.dart';

class CourseStepIndicator extends StatelessWidget {
  final int currentStep;
  final AnimationController progressController;

  const CourseStepIndicator({
    Key? key,
    required this.currentStep,
    required this.progressController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: progressController,
              builder: (context, child) {
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: currentStep >= 0
                        ? Colors.white
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: progressController,
              builder: (context, child) {
                return TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 400),
                  tween: ColorTween(
                    begin: Colors.grey.withOpacity(0.3),
                    end: currentStep >= 1
                        ? Colors.white
                        : Colors.grey.withOpacity(0.3),
                  ),
                  builder: (context, color, child) {
                    return Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
