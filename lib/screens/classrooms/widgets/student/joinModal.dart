import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';

class JoinClassroomModal extends StatefulWidget {
  const JoinClassroomModal({Key? key}) : super(key: key);

  @override
  State<JoinClassroomModal> createState() => _JoinClassroomModalState();
}

class _JoinClassroomModalState extends State<JoinClassroomModal> {
  final TextEditingController codeController = TextEditingController();
  final ClassController classController = Get.find<ClassController>();

  Future<void> _submit() async {
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

    await classController.joinClass(code);

    // 🚀 Here you'd handle actually joining a classroom (API call, DB check, etc.)
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
    final bool isTabletOrBigger = screenWidth > 600;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.05),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTabletOrBigger ? 32 : 24,
              vertical: isTabletOrBigger ? 32 : 24,
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: isTabletOrBigger ? 500 : double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Join a Classroom",
                      style: TextStyle(
                        fontSize: isTabletOrBigger ? 26 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Code Input
                    _buildTextField(
                      controller: codeController,
                      hintText: "Enter Classroom Code",
                    ),

                    const SizedBox(height: 32),

                    // Join button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: isTabletOrBigger ? 20 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          "Join Classroom",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTabletOrBigger ? 18 : 16,
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
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTabletOrBigger ? 20 : 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}
