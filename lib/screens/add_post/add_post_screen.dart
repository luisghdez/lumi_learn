import 'package:flutter/material.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Layout for adding a new post
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Post Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Post Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle post creation logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post Added')),
                );
              },
              child: const Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
