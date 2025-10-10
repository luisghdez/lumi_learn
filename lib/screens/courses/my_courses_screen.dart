import 'package:flutter/material.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Mycourses Screen, all of my saved courses w pagination and search, similar to explore screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
