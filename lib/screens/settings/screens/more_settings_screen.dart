import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumi_learn_app/tos.dart';
import 'package:lumi_learn_app/privacy_policy.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Prevent gray overlay
        shadowColor: Colors.transparent, // Remove shadow glow
        title: const Text("More Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _settingOption("Privacy Policy", Icons.privacy_tip_outlined, () {
            Get.to(() => const PrivacyPolicyScreen());
          }),
          _settingOption("Terms of Service", Icons.description_outlined, () {
            Get.to(() => const TermsOfServiceScreen());
          }),
          _settingOption("Delete Account", Icons.delete_outline, () {
            _confirmDelete(context, authController);
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _settingOption(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isDestructive ? Colors.redAccent : Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.redAccent : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthController authController) {
    final user = FirebaseAuth.instance.currentUser;
    final isEmailUser =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    if (isEmailUser) {
      String password = '';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("Delete Account",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please re-enter your password to confirm.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) => password = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authController.deleteAccount();
              },
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    } else {
      // For Google users
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("Delete Account",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "This will permanently delete your account. Are you sure?",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authController.deleteAccount();
              },
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }
  }
}
