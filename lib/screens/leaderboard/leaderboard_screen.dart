import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/leaderboard/widget/top_three_widget.dart';
import 'package:lumi_learn_app/screens/leaderboard/components/leaderboard_list.dart';
import 'package:lumi_learn_app/controllers/leaderboard_controller.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';

class LeaderboardPage extends StatelessWidget {
  final LeaderboardController controller = Get.put(LeaderboardController());

  LeaderboardPage({super.key});

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 Galaxy Background (Fixed behind content)
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: 340,
                  width: double.infinity,
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
                Expanded(child: Container(color: Colors.black)),
              ],
            ),
          ),

          // 🧾 Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 🏆 Title Section (on top of galaxy)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top Performers",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Leaderboard",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 👑 Top 3 players
                  TopThreeWidget(),

                  const SizedBox(height: 12),

                  // 📜 Full list
                  LeaderboardList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
