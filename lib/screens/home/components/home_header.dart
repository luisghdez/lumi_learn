import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

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
                const Text(
                  '2,045',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                const Text(
                  '6',
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
