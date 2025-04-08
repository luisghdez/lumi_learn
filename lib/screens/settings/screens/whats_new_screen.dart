import 'dart:ui';
import 'package:flutter/material.dart';
import 'whats_new_detail_screen.dart';

class WhatsNewScreen extends StatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  List<Map<String, dynamic>> updates = [
    {
      'title': "New Update - Version 1.0.0",
      'subtitle': "NEW UPDATED AI LEARNER",
      'image': "assets/galaxies/galaxy5.png",
      'showImage': true,
    },
    {
      'title': "News",
      'subtitle': "ai new way to learn",
      'showImage': false,
    },
  ];

  void _removeUpdate(int index) {
    setState(() {
      updates.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("What's New", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: updates.isEmpty
            ? const Center(
                child: Text(
                  "No updates",
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.separated(
                itemCount: updates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = updates[index];
                  return _buildUpdateCard(
                    context: context,
                    index: index,
                    title: item['title'],
                    subtitle: item['subtitle'],
                    imagePath: item['image'],
                    showImage: item['showImage'] ?? false,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildUpdateCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    String? imagePath,
    bool showImage = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Text(
                    "now",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              if (showImage && imagePath != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WhatsNewDetailScreen(title: title),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _removeUpdate(index),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white54, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Clear",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
