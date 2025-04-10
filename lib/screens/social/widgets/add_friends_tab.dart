import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'glass_tile.dart';
import 'glass_tile_with_field.dart';

class AddFriendsTab extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onCheckContactsPermission;
  final VoidCallback onShareLink;
  final VoidCallback onSearch;
  final bool contactsPermissionGranted;

  const AddFriendsTab({
    super.key,
    required this.emailController,
    required this.onCheckContactsPermission,
    required this.onShareLink,
    required this.onSearch,
    required this.contactsPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();

    return Obx(() {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          GlassTile(
            title: "Choose from Contacts",
            subtitle: contactsPermissionGranted
                ? "Permission granted. Tap to pick from contacts."
                : "Grant access to find friends from your contacts.",
            onTap: onCheckContactsPermission,
            icon: Icons.contacts,
          ),
          const SizedBox(height: 16),
          GlassTileWithField(
            title: "Search by Name or Email",
            subtitle: "Find users using their name or email address.",
            controller: emailController,
            onPressed: onSearch, // ✅ uses callback from screen
          ),
          const SizedBox(height: 16),
          GlassTile(
            title: "Share Follow Link",
            subtitle: "Invite others to follow you on Lumi Learn.",
            onTap: onShareLink,
            icon: Icons.share,
          ),
          const SizedBox(height: 20),
          if (controller.isLoading.value) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
          ],

          // 👥 Show search results
          if (controller.searchResults.isNotEmpty) ...[
            const Text(
              "Search Results",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            ...controller.searchResults.map((user) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? AssetImage(user.avatarUrl!)
                      : const AssetImage('assets/pfp/pfp1.png'),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(user.name ?? "No Name",
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(user.email ?? "",
                    style: const TextStyle(color: Colors.white60)),
                onTap: () {
                  final fakeFriend = Friend(
                    id: user.id,
                    name: user.name ?? 'Unknown',
                    email: user.email ?? '',
                    avatarUrl: user.avatarUrl ?? 'assets/pfp/pfp1.png',
                    points: 0,
                    dayStreak: 0,
                    totalXP: 0,
                    top3Finishes: 0,
                    goldLeagueWeeks: 0,
                    joinedDate: 'N/A',
                    friendCount: 0,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendProfile(friend: fakeFriend),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ],
      );
    });
  }
}
