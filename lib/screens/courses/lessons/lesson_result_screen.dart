import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';

class LessonResultScreen extends StatefulWidget {
  final String backgroundImage;
  final int xp;

  const LessonResultScreen({
    Key? key,
    required this.backgroundImage,
    required this.xp,
  }) : super(key: key);

  @override
  _LessonResultScreenState createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  final String astronautImage = 'assets/astronaut/celebrate.png';

  bool _isTopStarFilled = false;
  bool _isBottomLeftStarFilled = false;
  bool _isBottomRightStarFilled = false;

  @override
  void initState() {
    super.initState();
    // Animate stars in the order: left, top, right with 200ms intervals
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isBottomLeftStarFilled = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isTopStarFilled = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _isBottomRightStarFilled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bottom layer: half-screen background with gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.65,
            width: double.infinity,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    widget.backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(255, 0, 0, 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Top layer: "Victory" content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Great Job',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                // Animated Stars arranged with top star and bottom row of left/right stars
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top star
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isTopStarFilled
                          ? const Icon(
                              Icons.star,
                              key: ValueKey('filled_top'),
                              color: Colors.white,
                              size: 60,
                            )
                          : const Icon(
                              Icons.star_border,
                              key: ValueKey('unfilled_top'),
                              color: Colors.white,
                              size: 60,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left star
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isBottomLeftStarFilled
                              ? const Icon(
                                  Icons.star,
                                  key: ValueKey('filled_left'),
                                  color: Colors.white,
                                  size: 60,
                                )
                              : const Icon(
                                  Icons.star_border,
                                  key: ValueKey('unfilled_left'),
                                  color: Colors.white,
                                  size: 60,
                                ),
                        ),
                        const SizedBox(width: 58), // space between bottom stars
                        // Right star
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isBottomRightStarFilled
                              ? const Icon(
                                  Icons.star,
                                  key: ValueKey('filled_right'),
                                  color: Colors.white,
                                  size: 60,
                                )
                              : const Icon(
                                  Icons.star_border,
                                  key: ValueKey('unfilled_right'),
                                  color: Colors.white,
                                  size: 60,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Astronaut image
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(astronautImage),
                ),
                const SizedBox(height: 40),
                // Animated XP count starting from 0 and counting up to 36
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: widget.xp.toDouble()),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Text(
                          '+${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAll(() => const CourseOverviewScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
