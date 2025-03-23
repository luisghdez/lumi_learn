
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/services/friends_service.dart'; // Import the data file
import 'package:flutter/foundation.dart';

class FriendsController extends ChangeNotifier {
  final FriendsService service;

  List<Friend> friends = [];
  bool isLoading = false;

  FriendsController({required this.service});

  /// Load all friends
  Future<void> loadFriends() async {
    isLoading = true;
    notifyListeners();
    try {
      friends = await service.fetchFriends();
    } catch (e) {
      // Handle error (e.g., show a message)
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Search friends based on a query
  Future<void> searchFriends(String query) async {
    isLoading = true;
    notifyListeners();
    try {
      friends = await service.searchUsers(query);
    } catch (e) {
      // Handle error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Send a friend request for a given friend ID
  Future<void> sendFriendRequest(String userId) async {
    await service.sendFriendRequest(userId);
    // Optionally update local state if needed
  }
}
