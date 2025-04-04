import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/screens/social/components/pfp_viewer.dart';
import 'package:lumi_learn_app/screens/social/components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/social/components/xp_chart_box.dart';

class FriendProfile extends StatelessWidget {
  final Friend friend;

  const FriendProfile({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 Galaxy header background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/galaxies/galaxy2.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🧑‍🚀 Friend name title overlay
          Positioned(
            left: 20,
            top: 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Friend",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 👇 Scrollable body content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                children: [
                  Center(
                    child: PfpViewer(
                      offsetUp: -90,
                      backgroundImage: AssetImage(friend.avatarUrl),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info box
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Joined ${friend.joinedDate}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.white24, thickness: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InfoStatCard(
                              icon: Icons.rocket_launch,
                              label: 'Streak',
                              value: '${friend.dayStreak} days',
                              background: false,
                            ),
                            const VerticalDivider(
                              color: Colors.white24,
                              thickness: 1,
                              width: 20,
                              indent: 10,
                              endIndent: 10,
                            ),
                            InfoStatCard(
                              icon: Icons.people,
                              label: 'Friends',
                              value: '${friend.friendCount}',
                              background: false,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Follow button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add follow logic here
                      },
                      icon: const Icon(Icons.person_add_alt,
                          size: 24, color: Color(0xFFB388FF)),
                      label: const Text('FOLLOW',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      InfoStatCard(
                        icon: Icons.star,
                        label: 'Total XP',
                        value: '${friend.totalXP}',
                      ),
                      const SizedBox(width: 16),
                      InfoStatCard(
                        icon: Icons.emoji_events,
                        label: 'Top 3s',
                        value: '${friend.top3Finishes}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // XP Chart
                  const XPChartBox(), // Optional: pass friend data if needed

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
