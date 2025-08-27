import 'package:flutter/material.dart';

class CourseNavigationButtons extends StatefulWidget {
  final int currentStep;
  final bool canProceedToNextStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CourseNavigationButtons({
    Key? key,
    required this.currentStep,
    required this.canProceedToNextStep,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  State<CourseNavigationButtons> createState() =>
      _CourseNavigationButtonsState();
}

class _CourseNavigationButtonsState extends State<CourseNavigationButtons>
    with TickerProviderStateMixin {
  late AnimationController _buttonFadeController;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _buttonFadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonFadeController,
      curve: Curves.easeInOut,
    ));
    _buttonFadeController.forward();
  }

  @override
  void didUpdateWidget(CourseNavigationButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If step changed, trigger fade animation
    if (oldWidget.currentStep != widget.currentStep) {
      _buttonFadeController.reverse().then((_) {
        if (mounted) {
          _buttonFadeController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _buttonFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show any buttons on step 0 (input type selection)
    if (widget.currentStep == 0) {
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
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedBuilder(
                animation: _buttonFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _buttonFadeAnimation.value,
                    child: Row(
                      children: [
                        if (widget.currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onPrevious,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Previous"),
                            ),
                          ),
                        if (widget.currentStep > 0 && widget.currentStep < 2)
                          const SizedBox(width: 16),
                        if (widget.currentStep == 1)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.canProceedToNextStep
                                  ? widget.onNext
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Next"),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
