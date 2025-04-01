import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<FriendsController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () async => controller.getRequests(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const Text("Received Requests",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...controller.receivedRequests.map((req) => Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text(req.name ?? "Unknown",
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(req.email ?? "",
                          style: const TextStyle(color: Colors.white70)),
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
                    ),
                  )),
              const SizedBox(height: 24),
              const Text("Sent Requests",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...controller.sentRequests.map((req) => Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text(req.name ?? "Unknown",
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(req.email ?? "",
                          style: const TextStyle(color: Colors.white70)),
                      trailing: const Text("Pending",
                          style: TextStyle(color: Colors.white30)),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}