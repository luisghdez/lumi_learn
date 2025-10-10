import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/models/friends_model.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_tile.dart';

import 'components/search_bar.dart' as custom;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // Only used when a search query is provided.
  List<Friend> _filteredFriends = [];
  // Local state to decide which list to display.
  String _searchQuery = "";
  // Local loading flag; could be replaced with the controller's isLoading if desired.
  bool _isLoading = false;

  final friendsController = Get.find<FriendsController>();

  @override
  void initState() {
    super.initState();
    // Optionally, if you wish to run _searchFriends with an empty string
    // immediately, uncomment the following line:
    // _searchFriends("");
  }

  /// Called when the search bar text changes.
  void _searchFriends(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      // If the query is empty, we clear the filtered list.
      if (query.isEmpty) {
        _filteredFriends = [];
      } else {
        _filteredFriends = friendsController.friends.where((friend) {
          final name = friend.name?.toLowerCase() ?? '';
          final email = friend.email?.toLowerCase() ?? '';
          return name.contains(lowerQuery) || email.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Decide which list to show:
    // If _searchQuery is empty, we show all friends from the controller.
    // Otherwise we use our filtered list.
    return Scaffold(
      // Set a default black background so that any gaps show as black.
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image layer.
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main content layer.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button and title.
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
                  const SizedBox(height: 22),
                  // Search Bar.
                  custom.SearchBar(
                    onChanged: _searchFriends,
                  ),
                  const SizedBox(height: 8),
                  // Friends List.
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        // Wrap the list in Obx so that any changes to the controller.friends
                        // are automatically updated.
                        : Obx(() {
                            // Determine the list to display:
                            final List<Friend> displayList =
                                _searchQuery.isEmpty
                                    ? friendsController.friends
                                    : _filteredFriends;
                            if (displayList.isEmpty) {
                              return const Center(
                                  child: Text(
                                "No friends found.",
                                style: TextStyle(color: Colors.white),
                              ));
                            }
                            return ListView.builder(
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final friend = displayList[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: FriendTile(
                                      friend: friend,
                                      onTap: () async {
                                        Get.dialog(
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            barrierDismissible: false);

                                        try {
                                          await friendsController
                                              .setActiveFriend(friend.id);
                                          Get.back();
                                          Get.to(
                                            () => const FriendProfile(),
                                            transition: Transition.fadeIn,
                                          );
                                        } catch (e) {
                                          Get.back();
                                          Get.snackbar("Error",
                                              "Could not load profile: $e");
                                        }
                                      }),
                                );
                              },
                            );
                          }),
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
