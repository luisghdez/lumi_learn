import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  // Example profile options
  final List<Map<String, dynamic>> options = const [
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Help & Support', 'icon': Icons.help},
    {'title': 'Logout', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    final AuthController authController =
        Get.find<AuthController>(); // GetX Controller

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: options.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final option = options[index];

        return ListTile(
          leading: Icon(option['icon'], color: Colors.blue),
          title: Text(option['title']),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (option['title'] == 'Logout') {
              _confirmLogout(
                  context, authController); // Show confirmation dialog
            }
          },
        );
      },
    );
  }

  // Logout confirmation dialog
  void _confirmLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              authController.signOut(); // Call logout function
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
