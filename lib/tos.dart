import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "By using Lumi, a product of SLH, you agree to the following terms. Please read them carefully.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 24),
              Text(
                "Usage Requirements",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "- You must be at least 13 years old\n"
                "- You agree to provide accurate information during sign-up\n"
                "- You will not use Lumi for any illegal activities",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 24),
              Text(
                "Content & Intellectual Property",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "- All lessons and materials are property of SLH\n"
                "- You may not reproduce or redistribute app content without permission",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 24),
              Text(
                "Feedback & Updates",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "- Feedback you provide may be used to improve the app\n"
                "- Features and terms may change; continued use means acceptance",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 24),
              Text(
                "Questions? Contact us at samluidev1@gmail.com",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
