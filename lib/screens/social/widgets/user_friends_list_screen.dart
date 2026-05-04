import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/models/friends_model.dart';
import 'package:lumi_learn_app/application/services/friends_service.dart';
import 'package:lumi_learn_app/screens/social/components/search_bar.dart' as custom;
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_tile.dart';

/// Friends of another user — same chrome as [FriendsScreen] (moon bg, header,
/// search, list) without the Add button.
class UserFriendsListScreen extends StatefulWidget {
  const UserFriendsListScreen({
    super.key,
    required this.userId,
    required this.ownerDisplayName,
  });

  final String userId;
  final String ownerDisplayName;

  @override
  State<UserFriendsListScreen> createState() => _UserFriendsListScreenState();
}

class _UserFriendsListScreenState extends State<UserFriendsListScreen> {
  final _service = FriendsService();
  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await Get.find<AuthController>().getIdToken();
      if (token == null) throw Exception('Not signed in');
      final list = await _service.fetchFriendsOfUser(
        token: token,
        userId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _friends = list;
          _loading = false;
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredFriends = [];
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredFriends = _friends.where((friend) {
      final name = friend.name?.toLowerCase() ?? '';
      final email = friend.email?.toLowerCase() ?? '';
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applySearch();
    });
  }

  Future<void> _openFriend(Friend f) async {
    final friendsController = Get.find<FriendsController>();
    try {
      await friendsController.setActiveFriend(f.id);
      if (!mounted) return;
      if (friendsController.activeFriend.value != null) {
        await Get.to<void>(
          () => const FriendProfile(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load profile: $e');
    }
  }

  String get _headerTitle {
    if (widget.ownerDisplayName.isNotEmpty) {
      return "${widget.ownerDisplayName}'s friends";
    }
    return 'Friends';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _headerTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  custom.SearchBar(onChanged: _onSearchChanged),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFB388FF),
                            ),
                          )
                        : _error != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  final displayList = _searchQuery.isEmpty
                                      ? _friends
                                      : _filteredFriends;
                                  if (displayList.isEmpty) {
                                    return Center(
                                      child: Text(
                                        _searchQuery.isEmpty
                                            ? 'No friends to show.'
                                            : 'No friends found.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: displayList.length,
                                    itemBuilder: (context, index) {
                                      final friend = displayList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: FriendTile(
                                          friend: friend,
                                          onTap: () => _openFriend(friend),
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
        ],
      ),
    );
  }
}
