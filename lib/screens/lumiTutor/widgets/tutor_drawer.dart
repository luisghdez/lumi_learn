import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/application/models/thread_model.dart';
import 'package:lumi_learn_app/utils/color_utils.dart';

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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chat History',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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
                      child: Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => tutorController.refreshThreads(),
                              color: Colors.white,
                              backgroundColor: Colors.black.withOpacity(0.3),
                              child: ListView.separated(
                                itemCount:
                                    tutorController.getSortedThreads().length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  color: Colors.white12,
                                  height: 1,
                                  thickness: 0.5,
                                ),
                                itemBuilder: (context, index) {
                                  final thread =
                                      tutorController.getSortedThreads()[index];
                                  return _buildThreadTile(
                                      context, thread, tutorController);
                                },
                              ),
                            ),
                          ),
                          // Load More Button
                          Obx(() {
                            if (!tutorController.hasMore.value) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: tutorController.isLoadingMore.value
                                      ? null
                                      : () => tutorController.loadMoreThreads(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: tutorController.isLoadingMore.value
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Load More',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ],
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
      title: Row(
        children: [
          Expanded(
            child: Text(
              thread.initialMessage.length > 50
                  ? '${thread.initialMessage.substring(0, 50)}...'
                  : thread.initialMessage,
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(thread.lastMessageAt),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      subtitle: (thread.courseTitle ?? '').trim().isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: ColorUtils.getCourseColor(thread.courseId),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        thread.courseTitle!.trim(),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12, height: 0.8),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      onTap: () async {
        await controller.setActiveThread(thread);
        Get.back();
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
