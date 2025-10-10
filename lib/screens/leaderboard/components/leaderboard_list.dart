import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/leaderboard_controller.dart';
import 'package:lumi_learn_app/screens/leaderboard/components/leaderboard_card.dart';

class LeaderboardList extends StatelessWidget {
  final LeaderboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final leaderboard = controller.leaderboard;

      return Column(
        children: leaderboard
            .asMap()
            .entries
            .map((entry) => LeaderboardCard(
                  position: entry.key + 1,
                  player: entry.value,
                ))
            .toList(),
      );
    });
  }
}
