import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/profile/widgets/profile_body.dart';
import 'package:lumi_learn_app/screens/profile/widgets/galaxy_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditingPfp = false;

  void handleEditModeChange(bool enable) {
    setState(() {
      isEditingPfp = enable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GalaxyHeader(isEditing: isEditingPfp),
          ProfileBody(
            isEditingPfp: isEditingPfp,
            onEditModeChange: handleEditModeChange,
          ),
        ],
      ),
    );
  }
}
