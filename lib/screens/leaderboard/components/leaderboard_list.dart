import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/leaderboard_controller.dart';
import 'package:lumi_learn_app/screens/leaderboard/components/leaderboard_card.dart';

class LeaderboardList extends StatelessWidget {
  final LeaderboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: controller.leaderboard.length,
        itemBuilder: (context, index) {
          return LeaderboardCard(
            position: index + 1,
            player: controller.leaderboard[index],
          );
        },
      );
    });
  }
}
