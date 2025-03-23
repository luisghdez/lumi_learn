import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/leaderboard/widget/top_three_widget.dart';
import 'package:lumi_learn_app/screens/leaderboard/components/leaderboard_list.dart';
import 'package:lumi_learn_app/controllers/leaderboard_controller.dart';
import 'package:lumi_learn_app/widgets/profile_avatar.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';




class LeaderboardPage extends StatelessWidget {
  final LeaderboardController controller = Get.put(LeaderboardController());

  LeaderboardPage({super.key});

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              // Header Row: Title and Profile Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Perfoemers",
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
                  ProfileAvatar(onTap: () => _navigateToProfile(context)),
                ],
              ),

              const SizedBox(height: 20),

              // Top 3 Players
              TopThreeWidget(),

              const SizedBox(height: 5),

              // Full Leaderboard List
              Expanded(child: LeaderboardList()),
            ],
          ),
        ),
      ),
    );
  }
}