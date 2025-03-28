import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/leaderboard_model.dart';

class TopPlayerWidget extends StatelessWidget {
  final Player player;
  final int position;
  final bool hasCrown;

  const TopPlayerWidget(
      {required this.player,
      required this.position,
      this.hasCrown = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double avatarSize = (position == 1) ? 80 : 60; // 1st place is larger

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _buildBlurredCircle(avatarSize + 25), // Extra blur effect
            _buildBlurredCircle(avatarSize + 10),

            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: avatarSize / 2,
              backgroundImage: AssetImage(player.avatar),
            ),

            // **Position Badge**
            Positioned(
              bottom: -8,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  "$position",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),

            // **Crown for First Place**
            if (hasCrown)
              Positioned(
                top: -25,
                child: Image.asset(
                  'assets/images/crown.png',
                  width: 40,
                  height: 40,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          player.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          "${player.points} pts",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // **Blurred Glow Effect**
  Widget _buildBlurredCircle(double size) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
          ),
        ),
      ),
    );
  }
}
