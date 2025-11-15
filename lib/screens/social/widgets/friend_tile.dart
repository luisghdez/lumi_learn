// lib/screens/social/widgets/friend_tile.dart

import 'package:flutter/material.dart';
import 'package:lumi_learn_app/application/models/friends_model.dart';

class FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendTile({
    Key? key,
    required this.friend,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          onTap: onTap,
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(
              friend.avatarUrl != null &&
                      friend.avatarUrl!.isNotEmpty &&
                      friend.avatarUrl != "default"
                  ? 'assets/pfp/pfp${friend.avatarUrl}.png'
                  : 'assets/pfp/pfp28.png',
            ),
            backgroundColor: Colors.transparent,
          ),
          title: Text(
            friend.name ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Text(
            '${friend.totalXP} pts',
            style: const TextStyle(
              color: Color(0xFFB4B2FF),
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.white38,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
