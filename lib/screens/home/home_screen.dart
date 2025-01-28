// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'components/home_header.dart';
import 'widgets/home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main layout of the Home Screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Column(
        children: [
          HomeHeader(),
          Expanded(
            child: HomeWidget(),
          ),
        ],
      ),
    );
  }
}
