import 'dart:ui'; // For the glass blur
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';

class CreateClassroomModal extends StatefulWidget {
  const CreateClassroomModal({super.key});

  @override
  State<CreateClassroomModal> createState() => _CreateClassroomModalState();
}

class _CreateClassroomModalState extends State<CreateClassroomModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final ClassController classController = Get.find<ClassController>();

  Color selectedColor = Colors.blue; // Default selected color

  final List<Color> availableColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.teal,
    Colors.pinkAccent,
    Colors.amber,
  ];

  void _submit() async {
    final String title = titleController.text.trim();
    final String identifier = subtitleController.text.trim();

    if (title.isEmpty || identifier.isEmpty) {
      Get.snackbar("Error", "Please fill all fields properly!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    await classController.createClassroom(
      title: title,
      identifier: identifier,
      sideColor: selectedColor,
      joinCode: '',
    );

    Get.back();

    Get.snackbar("Success", "Classroom Created!",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Center(
      child: AlertDialog(
        // Make the dialog shell itself transparent
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTabletOrBigger ? 500 : double.infinity,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  // Your semi-transparent “frosted glass” background
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletOrBigger ? 32 : 24,
                    vertical: isTabletOrBigger ? 32 : 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create New Classroom",
                        style: TextStyle(
                          fontSize: isTabletOrBigger ? 26 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: titleController,
                        hintText: "Classroom Title",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: subtitleController,
                        hintText: "Subtitle (CRN)",
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pick Side Color:",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: availableColors.map((color) {
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedColor = color;
                            }),
                            child: Container(
                              width: isTabletOrBigger ? 44 : 38,
                              height: isTabletOrBigger ? 44 : 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
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
                            "Create Classroom",
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
