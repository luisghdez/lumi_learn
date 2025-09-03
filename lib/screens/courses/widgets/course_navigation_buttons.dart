import 'package:flutter/material.dart';

class CourseNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool canProceedToNextStep;
  final bool canCreateCourse;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onCreateCourse;

  const CourseNavigationButtons({
    Key? key,
    required this.currentStep,
    required this.canProceedToNextStep,
    this.canCreateCourse = false,
    required this.onPrevious,
    required this.onNext,
    this.onCreateCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show any buttons on step 0 (input type selection)
    if (currentStep == 0) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onPrevious,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Previous"),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 16),
                  if (currentStep == 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canProceedToNextStep ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Next"),
                      ),
                    ),
                  if (currentStep == 2)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canCreateCourse && onCreateCourse != null
                            ? onCreateCourse
                            : null,
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          "Create Course",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
