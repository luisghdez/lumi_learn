import 'package:get/get.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/services/friends_service.dart';

class FriendsController extends GetxController {
  final FriendsService service;

  // Reactive state variables
  var friends = <Friend>[].obs;
  var sentRequests = <Friend>[].obs;
  var receivedRequests = <Friend>[].obs;

  var isLoading = false.obs;
  var error = RxnString();

  FriendsController({required this.service});

  /// Load accepted friends
  Future<void> loadFriends() async {
    _startLoading();
    try {
      final result = await service.fetchFriends();
      friends.value = result;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Error", error.value ?? "Something went wrong");
    } finally {
      _stopLoading();
    }
  }

  /// Search users (name or email)
  Future<void> searchFriends(String query) async {
    _startLoading();
    try {
      final result = await service.searchUsers(query);
      friends.value = result;
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
      Get.snackbar("Request Sent", "Friend request sent.");
    } catch (e) {
      Get.snackbar("Error", "Failed to send request: ${e.toString()}");
    }
  }

  /// Accept or decline a friend request
  Future<void> respondToRequest(String requestId, bool accept) async {
    try {
      await service.respondToRequest(requestId, accept);
      Get.snackbar("Request Updated", accept ? "Friend added." : "Request declined.");
      await getRequests(); // Refresh list
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Load pending requests (sent + received)
  Future<void> getRequests() async {
    _startLoading();
    try {
      final result = await service.getFriendRequests();
      sentRequests.value = result['sent'] ?? [];
      receivedRequests.value = result['received'] ?? [];
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
}
