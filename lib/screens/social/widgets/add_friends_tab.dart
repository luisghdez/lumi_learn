import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';
import 'glass_tile.dart';
import 'glass_tile_with_field.dart';

class AddFriendsTab extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSearchByEmail;
  final VoidCallback onCheckContactsPermission;
  final VoidCallback onShareLink;
  final bool contactsPermissionGranted;

  const AddFriendsTab({
    super.key,
    required this.emailController,
    required this.onSearchByEmail,
    required this.onCheckContactsPermission,
    required this.onShareLink,
    required this.contactsPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find();
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
          title: "Search by Email",
          subtitle: "Find users using their email address.",
          controller: emailController,
          onPressed: onSearchByEmail,
        ),
        const SizedBox(height: 16),
        GlassTile(
          title: "Share Follow Link",
          subtitle: "Invite others to follow you on Lumi Learn.",
          onTap: onShareLink,
          icon: Icons.share,
        ),
        if (controller.isLoading.value) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
