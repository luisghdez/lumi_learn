import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<FriendsController>(
      builder: (controller) {
        final received = controller.receivedRequests;

        return RefreshIndicator(
          onRefresh: () async => controller.getRequests(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _sectionTitle("Received Requests"),
              if (received.isEmpty)
                _emptyState("No incoming requests right now.")
              else
                ...received.map((req) => _requestCard(
                      name: req.name ?? "Unknown",
                      email: req.email ?? "",
                      avatarUrl: req.avatarUrl,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                controller.respondToRequest(req.id, true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                controller.respondToRequest(req.id, false),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Reusable section title
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );

  // 🔹 Reusable empty state
  Widget _emptyState(String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          message,
          style: const TextStyle(
              color: Colors.white38, fontStyle: FontStyle.italic),
        ),
      );

  // 🔹 Reusable request card
  Widget _requestCard({
    required String name,
    required String email,
    required String? avatarUrl,
    required Widget trailing,
  }) {
    final image = avatarUrl?.startsWith('http') == true
        ? NetworkImage(avatarUrl!)
        : AssetImage(avatarUrl ?? 'assets/pfp/pfp1.png') as ImageProvider;

    return Card(
      color: Colors.white10,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: image,
          backgroundColor: Colors.transparent,
          radius: 24,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: trailing,
      ),
    );
  }
}
