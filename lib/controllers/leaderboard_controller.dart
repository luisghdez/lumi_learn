// import 'package:get/get.dart';
// import 'package:lumi_learn_app/models/leaderboard_model.dart';
// import 'package:lumi_learn_app/services/api_service.dart';

// class LeaderboardController extends GetxController {
//   RxList<Player> leaderboard = <Player>[].obs;
//   RxBool isLoading = true.obs;

//   @override
//   void onInit() {
//     fetchLeaderboard();
//     super.onInit();
//   }

//   void fetchLeaderboard() async {
//     try {
//       isLoading(true);
//       var data = await ApiService.fetchLeaderboard();
//       leaderboard.value = data;
//     } catch (e) {
//       print("Error fetching leaderboard: $e");
//     } finally {
//       isLoading(false);
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:lumi_learn_app/models/leaderboard_model.dart';

class LeaderboardController extends GetxController {
  RxList<Player> leaderboard = <Player>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    fetchMockLeaderboard(); // Use mock data instead of API
    super.onInit();
  }

  void fetchMockLeaderboard() async {
    try {
      isLoading(true);

      // Mock data for leaderboard (Replace this with real API data later)
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      leaderboard.value = [
        Player(name: "Sam", points: 542, avatar: "assets/pfp/pfp1.png"),
        Player(name: "Tig", points: 450, avatar: "assets/pfp/pfp2.png"),
        Player(name: "Nick", points: 312, avatar: "assets/pfp/pfp3.png"),
        Player(name: "You", points: 275, avatar: "assets/pfp/pfp4.png"),
        Player(name: "Gr", points: 290, avatar: "assets/pfp/pfp5.png"),
      ];
    } catch (e) {
      print("Error fetching leaderboard: $e");
    } finally {
      isLoading(false);
    }
  }
}
