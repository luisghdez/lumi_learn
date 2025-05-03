import 'package:flutter/material.dart';

class AiScannerMain extends StatelessWidget {
  const AiScannerMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'AiScanner Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
