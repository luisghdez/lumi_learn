// components/friends/friend_profile.dart

import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';

class FriendProfile extends StatelessWidget {
  final Friend friend;

  const FriendProfile({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adjust your color palette to match your existing dark theme
    const backgroundColor = Color.fromARGB(255, 0, 0, 0);
    const cardColor = Color(0xFF262626);
    const primaryTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);
    const accentColor = Color(0xFFA099FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          friend.name,
          style: const TextStyle(
            color: primaryTextColor,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(friend.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Joined ${friend.joinedDate} • ${friend.friendCount} Friends',
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Handle Follow / Unfollow
                    },
                    child: const Text('Follow'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Day streak', friend.dayStreak.toString(), accentColor),
                      _buildStatItem('Total XP', friend.totalXP.toString(), accentColor),
                      _buildStatItem('Top 3 finishes', friend.top3Finishes.toString(), accentColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        'Gold League',
                        '${friend.goldLeagueWeeks} wks',
                        accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // XP This Week Section (Placeholder Graph)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'XP this week',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder chart
                  _buildXPChart(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Friends Section (Optional)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friends',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // If the user isn’t following anyone:
                  Text(
                    'Not following anyone yet',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Achievements Section (Placeholder)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAchievementItem('Level 1', Icons.star, Colors.amber),
                      _buildAchievementItem('Level 2', Icons.star, Colors.green),
                      _buildAchievementItem('Level 3', Icons.star, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Block user
            TextButton(
              onPressed: () {
                // Handle blocking user
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('BLOCK USER'),
            ),
          ],
        ),
      ),
    );
  }

  /// A small helper for building stats with a label and a value.
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// A placeholder for your weekly XP chart.
  Widget _buildXPChart() {
    // Example of a simple horizontal bar for each day.
    // You can replace this with a real chart library if you like.
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final xp = [10, 5, 0, 12, 8, 7, 10]; // dummy data

    return Column(
      children: List.generate(days.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  days[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  color: const Color(0xFFB0B0B0),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xp[index] / 12, // scale your bar
                    child: Container(
                      color: const Color(0xFFA099FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${xp[index]} XP',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// A small helper for building an achievement item with an icon and a label.
  Widget _buildAchievementItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
