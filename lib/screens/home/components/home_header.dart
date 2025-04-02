import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final int streakCount;
  final int xpCount;

  const HomeHeader({
    Key? key,
    required this.streakCount,
    required this.xpCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Home label
        const Text(
          "Home",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 0.9,
            letterSpacing: -1,
          ),
        ),

        // Right side: icons and numbers
        Row(
          children: [
            // Star Icon + Count
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

            // Meteor Icon + Count
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
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
