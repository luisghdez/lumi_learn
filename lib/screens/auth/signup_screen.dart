import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/auth/login_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full-screen background container
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxies/galaxy22.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  RichText(
                    text: const TextSpan(
                      text: "Let's\n",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      children: [
                        TextSpan(
                          text: "Start",
                          style: TextStyle(
                            fontSize: 63,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 160),

                  // Name Field
                  _buildInputField("Your Name", Icons.person,
                      controller: nameController),

                  const SizedBox(height: 20),

                  // Email Field
                  _buildInputField("Email", Icons.email,
                      controller: emailController),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildInputField("Password", Icons.lock,
                      controller: passwordController, isPassword: true),

                  const SizedBox(height: 50),

                  // Sign Up Button
                  _buildPrimaryButton("Sign Up", () {
                    authController.signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      nameController.text.trim(),
                    );
                  }),

                  const SizedBox(height: 26),

                  // Terms and Conditions
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => LoginScreen());
                      },
                      child: Text(
                        "I already have an account",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  // const SizedBox(height: 30), // Space from bottom

                  // // Terms and conditions
                  // Center(
                  //   child: Text(
                  //     "By signing up, you agree to our Terms & Conditions",
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 12,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Input Field
  Widget _buildInputField(String label, IconData icon,
      {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        suffixIcon: Icon(icon, color: Colors.white, size: 22),
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // Primary Button
  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: authController.isLoading.value
                ? null
                : onPressed, // Disable button when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 24),
            ),
            child: authController.isLoading.value
                ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ) // Show loading indicator
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          )),
    );
  }
}
