import 'package:flutter/material.dart';

class SearchMain extends StatelessWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Search Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
