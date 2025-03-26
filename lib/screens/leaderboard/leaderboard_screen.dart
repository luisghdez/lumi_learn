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
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      // 🌌 Galaxy Image
                      Image.asset(
                        'assets/galaxies/galaxy2.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Gradient overlay
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
                )
              ],
            ),
          ),

          // 🧾 Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // 🏆 Title Section (on top of galaxy)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top Performers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          const Text(
                            "Leaderboard",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 0.9,
                              letterSpacing: -1,
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
