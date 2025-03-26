import 'package:flutter/material.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileAvatar({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController();
    final String? profileImage = authController.firebaseUser.value?.photoURL;

    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost Glow (Light Grey)
          Container(
            width: 60, // Largest glow circle
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.15),
            ),
          ),
          // Middle Glow (Darker Grey)
          Container(
            width: 52, // Medium glow circle
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          // Profile Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profileImage != null
                ? AssetImage(profileImage)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
        ],
      ),
    );
  }
}
