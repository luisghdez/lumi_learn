import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/services/friends_service.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_tile.dart';

import 'components/search_bar.dart' as custom;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendsService _friendsService = FriendsService();

  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllFriends();
  }

  Future<void> _fetchAllFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendsService.fetchFriends();
      setState(() {
        _friends = friends;
        _filteredFriends = friends;
      });
    } catch (e) {
      // Optionally: handle the error (e.g., show a snackbar)
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchFriends(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        final name = friend.name?.toLowerCase() ?? '';
        final email = friend.email?.toLowerCase() ?? '';
        return name.contains(lowerQuery) || email.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set a default black background so that any gaps show as black.
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image layer
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: Stack(
                    children: [
                      // 🌌 Galaxy Image
                      Image.asset(
                        'assets/galaxies/galaxy2.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Main content layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Friends",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  custom.SearchBar(
                    onChanged: _searchFriends,
                  ),
                  // const SizedBox(height: 20),
                  // Friends List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _filteredFriends.length,
                            itemBuilder: (context, index) {
                              final friend = _filteredFriends[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: FriendTile(
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
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
