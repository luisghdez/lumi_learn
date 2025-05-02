import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final int streakCount;
  final int xpCount;
  final bool isPremium; // still passed but not used for styling

  const HomeHeader({
    Key? key,
    required this.title,
    required this.streakCount,
    required this.xpCount,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle titleStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.2,
      letterSpacing: -1.2,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Static Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: titleStyle),
          ],
        ),

        // XP & Streak Display
        Row(
          children: [
            Row(
              children: [
                Image.asset('assets/icons/star.png', width: 22, height: 22),
                const SizedBox(width: 6),
                Text(
                  NumberFormat.decimalPattern().format(xpCount),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Row(
              children: [
                Image.asset('assets/icons/meteor.png', width: 24, height: 24),
                const SizedBox(width: 6),
                Text(
                  streakCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
