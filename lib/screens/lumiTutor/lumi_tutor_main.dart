import 'package:flutter/material.dart';

class LumiTutorMain extends StatelessWidget {
  const LumiTutorMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'LumiTutor Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
