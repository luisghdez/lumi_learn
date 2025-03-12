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
        Player(name: "Sam", points: 542, avatar: "https://placehold.co/100x100"),
        Player(name: "Tig", points: 450, avatar: "https://placehold.co/100x100"),
        Player(name: "Nick", points: 312, avatar: "https://placehold.co/100x100"),
        Player(name: "You", points: 275, avatar: "https://placehold.co/100x100"),
        Player(name: "Gr", points: 290, avatar: "https://placehold.co/100x100"),
      ];
    } catch (e) {
      print("Error fetching leaderboard: $e");
    } finally {
      isLoading(false);
    }
  }
}
