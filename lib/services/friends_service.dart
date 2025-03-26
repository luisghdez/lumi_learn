// services/friends_service.dart

import 'dart:async';
import 'package:lumi_learn_app/models/friends_model.dart';

class FriendsService {
  /// Simulate fetching friends (with points + extra stats)
  Future<List<Friend>> fetchFriends() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      Friend(
        id: '1',
        name: 'Kathryn',
        avatarUrl: 'assets/pfp/pfp2.png',
        points: 150,
        dayStreak: 3,
        totalXP: 1771,
        top3Finishes: 2,
        goldLeagueWeeks: 1,
        joinedDate: 'May 2023',
        friendCount: 5,
      ),
      Friend(
        id: '2',
        name: 'Jacob',
        avatarUrl:  'assets/pfp/pfp3.png',
        points: 200,
        dayStreak: 1,
        totalXP: 2033,
        top3Finishes: 3,
        goldLeagueWeeks: 2,
        joinedDate: 'April 2023',
        friendCount: 2,
      ),
      Friend(
        id: '3',
        name: 'Jane',
        avatarUrl: 'assets/pfp/pfp4.png',
        points: 175,
        dayStreak: 5,
        totalXP: 1500,
        top3Finishes: 1,
        goldLeagueWeeks: 5,
        joinedDate: 'March 2023',
        friendCount: 10,
      ),
      // Add additional dummy friends as needed
    ];
  }

  /// Simulate searching for users based on a query string
  Future<List<Friend>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For simplicity, filter the dummy data from fetchFriends()
    final allFriends = await fetchFriends();
    return allFriends
        .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Simulate sending a friend request
  Future<void> sendFriendRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simply simulate success; update local state as needed in your controller.
  }
}
