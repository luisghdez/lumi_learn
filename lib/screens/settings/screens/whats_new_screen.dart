// whats_new_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'whats_new_detail_screen.dart';
import '../data/updateData.dart';

class WhatsNewScreen extends StatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  late List<UpdateData> updates;

  @override
  void initState() {
    super.initState();
    // Load all updates from the data file
    updates = List.from(allUpdates);
  }

  void _removeUpdate(int index) {
    setState(() {
      updates.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Content
          Column(
            children: [
              // AppBar
              AppBar(
                title: const Text("What's New",
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              // Body content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: updates.isEmpty
                      ? const Center(
                          child: Text(
                            "You're all caught up!",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: updates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final update = updates[index];
                            return Dismissible(
                              key: ValueKey('${update.version}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) => _removeUpdate(index),
                              child: _buildUpdateCard(
                                context: context,
                                update: update,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard({
    required BuildContext context,
    required UpdateData update,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        update.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Text(
                      "now",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  update.subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),

                // Optional Image
                if (update.showImage)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WhatsNewDetailScreen(
                            title: update.title,
                            version: update.version,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: update.title,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          update.imagePath,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.white54, size: 18),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () {
                        final index = updates.indexOf(update);
                        if (index != -1) _removeUpdate(index);
                      },
                      child: const Text(
                        "Clear this update",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}