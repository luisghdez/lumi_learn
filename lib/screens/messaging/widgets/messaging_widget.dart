import 'package:flutter/material.dart';

class MessagingWidget extends StatelessWidget {
  const MessagingWidget({Key? key}) : super(key: key);

  // Example list of conversations
  final List<Map<String, String>> conversations = const [
    {'name': 'Alice', 'lastMessage': 'Hey there!'},
    {'name': 'Bob', 'lastMessage': 'Let\'s catch up later.'},
    {'name': 'Charlie', 'lastMessage': 'Check out this link.'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final convo = conversations[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(convo['name']![0]),
          ),
          title: Text(convo['name']!),
          subtitle: Text(convo['lastMessage']!),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Handle conversation tap, e.g., navigate to chat detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Opening conversation with ${convo['name']}')),
            );
          },
        );
      },
    );
  }
}
