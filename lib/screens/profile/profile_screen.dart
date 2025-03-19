import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/profile/widgets/pfp_selector.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>(); // GetX Controller

  void _openPictureSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePictureSelector(
          onPictureSelected: (String newImage) async {
            await authController.updateProfilePicture(newImage); // Ensure Firebase updates before UI change
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'App Settings',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header Card
            Container(
              width: screenWidth,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.40),
                        ),
                      ),
                      Container(
                        width: 125,
                        height: 125,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      Obx(() => CircleAvatar(
                            radius: 45,
                            backgroundImage: authController.firebaseUser.value?.photoURL != null
                                ? NetworkImage(authController.firebaseUser.value!.photoURL!)
                                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          )),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _openPictureSelector, // Opens the picture selector
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Text(
                        authController.firebaseUser.value?.displayName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  Obx(() => Text(
                        authController.firebaseUser.value?.email ?? 'No Email',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Settings Options
            _buildSettingsOption(
              icon: Icons.tune,
              title: 'App preferences',
              onTap: () {},
            ),
            _buildSettingsOption(
              icon: Icons.notifications_outlined,
              title: 'App notifications',
              onTap: () {},
            ),
            _buildSettingsOption(
              icon: Icons.help_outline,
              title: 'Help and Support',
              onTap: () {},
            ),
            _buildSettingsOption(
              icon: Icons.feedback_outlined,
              title: 'Give a feedback',
              onTap: () {},
            ),

            const SizedBox(height: 2),

            // Logout Button with Confirmation Dialog
            GestureDetector(
              onTap: () => _confirmLogout(context),
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable settings option method with subtle grey background
  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // Logout confirmation dialog
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black, // Match dark theme
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              authController.signOut(); // Call logout function
              Navigator.pop(context); // Close dialog
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
