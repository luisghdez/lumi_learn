import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final int streakCount;
  final int xpCount;
  final bool isPremium;

  const HomeHeader({
    Key? key,
    required this.title,
    required this.streakCount,
    required this.xpCount,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).textScaleFactor;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isLargeScreen = constraints.maxWidth > 800;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 32 * scale : 24 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),

          // XP & Streak
          Row(
            children: [
              _iconStat(
                iconPath: 'assets/icons/star.png',
                value: NumberFormat.decimalPattern().format(xpCount),
                size: isLargeScreen ? 22 : 20,
              ),
              const SizedBox(width: 18),
              _iconStat(
                iconPath: 'assets/icons/meteor.png',
                value: streakCount.toString(),
                size: isLargeScreen ? 24 : 20,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _iconStat({required String iconPath, required String value, required double size}) {
    return Row(
      children: [
        Image.asset(iconPath, width: size, height: size),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
