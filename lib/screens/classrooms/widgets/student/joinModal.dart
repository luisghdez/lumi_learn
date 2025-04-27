import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoinClassroomModal extends StatefulWidget {
  const JoinClassroomModal({Key? key}) : super(key: key);

  @override
  State<JoinClassroomModal> createState() => _JoinClassroomModalState();
}

class _JoinClassroomModalState extends State<JoinClassroomModal> {
  final TextEditingController codeController = TextEditingController();

  void _submit() {
    final String code = codeController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a valid classroom code!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.back(); // Close modal

    Get.snackbar(
      "Request Sent",
      "You've requested to join the classroom!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800; // More aggressive for iPad 13 inch

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.07),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 48 : 32,
              vertical: isLargeScreen ? 48 : 32,
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 600 : double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Join a Classroom",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Code Input
                    _buildTextField(
                      controller: codeController,
                      hintText: "Enter Classroom Code",
                      isLargeScreen: isLargeScreen,
                    ),

                    const SizedBox(height: 40),

                    // Join button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: isLargeScreen ? 24 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          "Join Classroom",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 20 : 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isLargeScreen,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isLargeScreen ? 24 : 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}
