import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/leaderboard_controller.dart';
import 'package:lumi_learn_app/screens/leaderboard/widget/top_player_widget.dart';

class TopThreeWidget extends StatelessWidget {
  final LeaderboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.leaderboard.length < 3) {
        return const Center(
          child: Text(
            "Not enough data available.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              "Top Space Voyager",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // **Animated Top 3 Layout**
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // **2nd Place (Left - Slightly Lower)**
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TopPlayerWidget(player: controller.leaderboard[1], position: 2),
                    ],
                  ),
                ),

                // **1st Place (Center - Highest)**
                Expanded(
                  child: Column(
                    children: [
                      TopPlayerWidget(player: controller.leaderboard[0], position: 1, hasCrown: true),
                    ],
                  ),
                ),

                // **3rd Place (Right - Slightly Lower)**
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TopPlayerWidget(player: controller.leaderboard[2], position: 3),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
