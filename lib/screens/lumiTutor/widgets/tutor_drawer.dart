import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/application/models/thread_model.dart';

class LumiDrawer extends StatelessWidget {
  const LumiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final TutorController tutorController = Get.find<TutorController>();

    return Drawer(
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          // Drawer content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chats with Lumi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => tutorController.refreshThreads(),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 30),
                  // const Text(
                  //   'Saved Courses',
                  //   style: TextStyle(color: Colors.white70, fontSize: 16),
                  // ),
                  // const SizedBox(height: 10),
                  // ...List.generate(3, (i) {
                  //   return ListTile(
                  //     contentPadding: EdgeInsets.zero,
                  //     title: const Text(
                  //       'Course Title Placeholder',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //     onTap: () {
                  //       // Navigate to course detail or show modal
                  //     },
                  //   );
                  // }),
                  // const Divider(color: Colors.white30),
                  // const SizedBox(height: 10),
                  // const Text(
                  //   'Chat History',
                  //   style: TextStyle(color: Colors.white70, fontSize: 16),
                  // ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (tutorController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (tutorController.errorMessage.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tutorController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (tutorController.threads.isEmpty) {
                      return const Text(
                        'No chat history yet',
                        style: TextStyle(color: Colors.white54),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: tutorController.getSortedThreads().length,
                        itemBuilder: (context, index) {
                          final thread =
                              tutorController.getSortedThreads()[index];
                          return _buildThreadTile(
                              context, thread, tutorController);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadTile(
      BuildContext context, Thread thread, TutorController controller) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        thread.initialMessage.length > 50
            ? '${thread.initialMessage.substring(0, 50)}...'
            : thread.initialMessage,
        style: const TextStyle(color: Colors.white),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${thread.messageCount} messages • ${_formatDate(thread.lastMessageAt)}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.white54, size: 20),
        onPressed: () {
          // TODO: Implement delete thread functionality
          Get.snackbar(
            'Delete Thread',
            'Delete functionality coming soon',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
      onTap: () {
        // TODO: Navigate to thread chat
        Get.snackbar(
          'Open Thread',
          'Opening thread: ${thread.threadId}',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
