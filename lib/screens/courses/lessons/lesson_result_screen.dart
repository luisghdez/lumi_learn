import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';

class LessonResultScreen extends StatelessWidget {
  final String backgroundImage;

  const LessonResultScreen({
    Key? key,
    required this.backgroundImage,
  }) : super(key: key);

  final String astronautImage = 'assets/astronaut/celebrating.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 12, 12, 12),
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
                    backgroundImage,
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
                          Color.fromARGB(255, 12, 12, 12),
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
                  'Victory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                // Stars
                // Replace the Row of stars with this:
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top star
                    Icon(Icons.star, color: Colors.white, size: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 60),
                        SizedBox(width: 58), // space between bottom stars
                        Icon(Icons.star_border, color: Colors.white, size: 60),
                      ],
                    ),
                  ],
                ),
                // // Points
                // const Text(
                //   '8/10 Points',
                //   style: TextStyle(
                //     fontSize: 24,
                //     color: Colors.white,
                //   ),
                // ),

                // Astronaut image
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(astronautImage),
                ),
                const SizedBox(height: 40),
                // Reward
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+36',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          // SizedBox(width: 8),
                          // Icon(
                          //   Icons.home_rounded,
                          //   color: Colors.black,
                          //   size: 30,
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
