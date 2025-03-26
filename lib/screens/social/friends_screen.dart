import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA099FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Add friend logic
        },
      ),
      body: Stack(
        children: [
          // 🌌 Background image with gradient
          Positioned.fill(
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

          // ✅ TITLE (top left overlay)
          const Positioned(
            left: 20,
            top: 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
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
          ),

          const SizedBox(height: 200),
SafeArea(
  child: CustomScrollView(
    slivers: [
      // 👇 Push content down to avoid overlap with "Your Profile"
      const SliverToBoxAdapter(
        child: SizedBox(height: 160),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: FriendTile(
                  friend: friend,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendProfile(friend: friend),
                      ),
                    );
                  },
                ),
              );
            },
            childCount: _friends.length,
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ],
  ),
),
        ],
      ),
    );
  }
}