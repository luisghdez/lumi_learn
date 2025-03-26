// lib/screens/social/widgets/friend_tile.dart

import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';

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
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: AssetImage(friend.avatarUrl),
        backgroundColor: Colors.transparent,
      ),
      title: Text(
        friend.name,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        '${friend.points} pts',
        style: const TextStyle(
          color: Color(0xFFB4B2FF),
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
