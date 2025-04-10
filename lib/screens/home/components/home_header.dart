import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final int streakCount;
  final int xpCount;
  final bool isPremium;

  const HomeHeader({
    Key? key,
    required this.streakCount,
    required this.xpCount,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isPremium
                ? ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFF0004FF),
                          Color.fromARGB(255, 124, 207, 255),
                          Color.fromARGB(255, 71, 0, 186),
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      "Lumi PRO",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1.2,
                      ),
                    ),
                  )
                : const Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -1.2,
                    ),
                  ),
          ],
        ),

        // Right side: icons and numbers
        Row(
          children: [
            // Star Icon + XP Count
            Row(
              children: [
                Image.asset(
                  'assets/icons/star.png',
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  NumberFormat.decimalPattern().format(xpCount),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(width: 18),

            // Meteor Icon + Streak Count
            Row(
              children: [
                Image.asset(
                  'assets/icons/meteor.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  streakCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
