// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'components/profile_header.dart';
import 'widgets/profile_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main layout of the Profile Screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Column(
        children: [
          ProfileHeader(),
          Expanded(
            child: ProfileWidget(),
          ),
        ],
      ),
    );
  }
}
