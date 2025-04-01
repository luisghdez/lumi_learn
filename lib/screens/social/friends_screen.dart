import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/services/friends_service.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_tile.dart';
import 'package:lumi_learn_app/screens/social/components/search_bar.dart'
    as Custom;
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart'; // Assuming this exists

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 Background image (non-interactive)
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/galaxies/galaxy2.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
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
                  ),
                ],
              ),
            ),
          ),

          // 🔙 Back + Title
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
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
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📜 Scrollable content
          Positioned.fill(
            top: 100, // 👈 Push down to avoid top bar
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),

                  // 🔍 Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Custom.SearchBar(
                        onChanged: (query) => _searchFriends(query),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 👥 Friends list or loading
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final friend = _friends[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
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
                        childCount: _friends.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 300)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
