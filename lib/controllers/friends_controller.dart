import 'package:get/get.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/models/userSearch_model.dart';
import 'package:lumi_learn_app/services/friends_service.dart';

class FriendsController extends GetxController {
  static FriendsController instance = Get.find();
  final FriendsService service;

  // Reactive state variables
  var friends = <Friend>[].obs; // Accepted friends
  var sentRequests = <Friend>[].obs; // Sent requests
  var receivedRequests = <Friend>[].obs; // Received requests
  var searchResults = <UserSearchResult>[].obs; // 🔍 Search results

  var sentRequestIds = <String>{}.obs; // ✅ for fast checks

  var isLoading = false.obs;
  var error = RxnString();

  FriendsController({required this.service});

  /// Load accepted friends
  Future<void> loadFriends() async {
    _startLoading();
    try {
      final result = await service.fetchFriends();
      friends.value = List<Friend>.from(result); // ✅ ensure new list
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Error", error.value ?? "Something went wrong");
    } finally {
      _stopLoading();
    }
  }

  /// Search users (by name or email)
  Future<void> searchFriends(String query) async {
    _startLoading();
    try {
      final result = await service.searchUsers(query);
      searchResults.value = List<UserSearchResult>.from(result);
      if (result.isEmpty) {
        Get.snackbar("No Results", "No users found for '$query'");
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Search Failed", error.value ?? "An error occurred");
    } finally {
      _stopLoading();
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest(String userId) async {
    try {
      await service.sendFriendRequest(userId);
      await getRequests(); // ⬅️ This already updates sentRequests and IDs
      Get.snackbar("Request Sent", "Friend request sent.");
    } catch (e) {
      Get.snackbar("Error", "Failed to send request: ${e.toString()}");
    }
  }

  /// Accept or decline a friend request
  Future<void> respondToRequest(String requestId, bool accept) async {
    try {
      receivedRequests.removeWhere((req) => req.id == requestId);

      await service.respondToRequest(requestId, accept);
      Get.snackbar(
          "Request Updated", accept ? "Friend added." : "Request declined.");

      if (accept) {
        await loadFriends(); // refresh friends if added
      }

      await getRequests(); // keep in sync
    } catch (e) {
      Get.snackbar("Error", e.toString());
      await getRequests(); // fallback to re-sync
    }
  }

  /// Load friend requests (sent and received)
  Future<void> getRequests() async {
    _startLoading();
    try {
      final result = await service.getFriendRequests();

      // ✅ Ensure new list references
      sentRequests.value = List<Friend>.from(result['sent'] ?? []);
      receivedRequests.value = List<Friend>.from(result['received'] ?? []);

      // ✅ Update set of IDs for fast lookup
      sentRequestIds.value = sentRequests.map((f) => f.id).toSet();

      // ✅ Optional: manually trigger refresh if still not reactive
      sentRequests.refresh();
      sentRequestIds.refresh();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Error", error.value ?? "Something went wrong");
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    isLoading.value = true;
    error.value = null;
  }

  void _stopLoading() {
    isLoading.value = false;
  }

  bool isFriend(String userId) {
    return friends.any((f) => f.id == userId);
  }

  bool hasSentRequest(String userId) {
    return sentRequestIds.contains(userId);
  }
}
