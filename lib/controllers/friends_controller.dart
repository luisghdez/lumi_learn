import 'dart:convert';

import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/models/friend_profile_model.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/models/userSearch_model.dart';
import 'package:lumi_learn_app/services/api_service.dart';
import 'package:lumi_learn_app/services/friends_service.dart';

class FriendsController extends GetxController {
  static FriendsController instance = Get.find();

  final authController = Get.find<AuthController>();

  // Reactive state variables
  var friends = <Friend>[].obs; // Accepted friends
  var sentRequests = <Friend>[].obs; // Sent requests
  var receivedRequests = <Friend>[].obs; // Received requests
  var searchResults = <UserSearchResult>[].obs; // 🔍 Search results

  var sentRequestIds = <String>{}.obs; // ✅ for fast checks

  // Add a reactive variable for the active friend.
  var activeFriend = Rxn<FriendProfileModel>();

  var isLoading = false.obs;
  var error = RxnString();

  final service = FriendsService();
  final apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    // Fetch the friends when the controller is initialized
    loadFriends();
  }

  /// Load accepted friends
  Future<void> loadFriends() async {
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }

      final result = await service.fetchFriends(token: token);
      friends.value = List<Friend>.from(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      _stopLoading();
    }
  }

  /// Search users (by name or email) search just in state from already loaded friends
  Future<void> searchUsers(String query) async {
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }

      final result = await service.searchUsers(query: query, token: token);
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
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }

      await service.sendFriendRequest(recipientId: userId, token: token);
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
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }
      await service.respondToRequest(
        requestId: requestId,
        accept: accept,
        token: token,
      );
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
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }
      final result = await service.getFriendRequests(token: token);

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

  Future<void> setActiveFriend(String friendId) async {
    _startLoading();
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back();
        throw Exception("No user token found.");
      }

      // Call the ApiService with named parameters.
      final response =
          await ApiService.getUserData(token: token, userId: friendId);

      // Parse the JSON from the response.
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Convert the JSON data to a Friend object.
      activeFriend.value = FriendProfileModel.fromJson(data['user']);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Error", error.value ?? "Could not set active friend");
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
