import 'package:flutter/material.dart';
import 'package:lumi_learn_app/application/models/leaderboard_model.dart';

class LeaderboardCard extends StatelessWidget {
  final int position;
  final Player player;

  const LeaderboardCard(
      {required this.position, required this.player, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isYou = player.name == "You";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isYou ? Colors.white : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            "$position",
            style: TextStyle(
              color: isYou ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 23,
                backgroundImage: AssetImage(player.avatar),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                color: isYou ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            "${player.points} pts",
            style: TextStyle(
              color: isYou ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
