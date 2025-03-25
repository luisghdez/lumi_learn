// screens/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/services/friends_service.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_widget.dart';
import 'package:lumi_learn_app/widgets/profile_avatar.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendsService _friendsService = FriendsService();

  List<Friend> _friends = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAllFriends();
  }

  /// Fetch all friends from the service
  Future<void> _fetchAllFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendsService.fetchFriends();
      setState(() => _friends = friends);
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Search friends based on user query
  Future<void> _searchFriends(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    try {
      if (query.isEmpty) {
        final friends = await _friendsService.fetchFriends();
        setState(() => _friends = friends);
      } else {
        final results = await _friendsService.searchUsers(query);
        setState(() => _friends = results);
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // BG set to black
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Row: Title and Profile Avatar
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Friends",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFB0B0B0)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search friends...',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontFamily: 'Inter',
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (query) => _searchFriends(query),
                      ),
                    ),
                  ],
                ),
              ),
              // Friend List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _friends.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return FriendTile(
                            friend: friend,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FriendProfile(friend: friend),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Floating action button for adding new friends
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA099FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Open modal to search for new friends or send a friend request
        },
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendTile({
    Key? key,
    required this.friend,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(friend.avatarUrl),
      ),
      title: Text(
        friend.name,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        '${friend.points} pts',
        style: const TextStyle(
          color: Color(0xFFB4B2FF),
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
