import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool weeklyReminder = true;
  bool friendRequests = true;
  bool challenges = false;
  bool lessonUpdates = true;
  bool streakReminders = true;
  bool announcements = true;

  // You can call native notification code here if needed when toggles change.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'App Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.black,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildGlassTile(
            title: "Weekly Reminder",
            subtitle: "Get a nudge every week to keep learning.",
            value: weeklyReminder,
            onChanged: (val) {
              setState(() => weeklyReminder = val);
            },
          ),
          _buildGlassTile(
            title: "Friend Requests",
            subtitle: "Be notified when someone wants to connect.",
            value: friendRequests,
            onChanged: (val) {
              setState(() => friendRequests = val);
            },
          ),
          _buildGlassTile(
            title: "Challenges & Leaderboards",
            subtitle: "Compete with friends & see results.",
            value: challenges,
            onChanged: (val) {
              setState(() => challenges = val);
            },
          ),
          _buildGlassTile(
            title: "Lesson Updates",
            subtitle: "Be the first to know when new lessons drop.",
            value: lessonUpdates,
            onChanged: (val) {
              setState(() => lessonUpdates = val);
            },
          ),
          _buildGlassTile(
            title: "Streak Reminders",
            subtitle: "Don’t lose your daily learning streak.",
            value: streakReminders,
            onChanged: (val) {
              setState(() => streakReminders = val);
            },
          ),
          _buildGlassTile(
            title: "General Announcements",
            subtitle: "Hear from Lumi Learn about updates & news.",
            value: announcements,
            onChanged: (val) {
              setState(() => announcements = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PurpleSwitch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PurpleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PurpleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.9,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purpleAccent,
        activeTrackColor: Colors.deepPurple.withOpacity(0.4),
        inactiveThumbColor: Colors.grey[700],
        inactiveTrackColor: Colors.white10,
        splashRadius: 16,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
