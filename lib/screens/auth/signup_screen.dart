import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure you have GoogleFonts package

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Background Image (Fixed)
          Positioned.fill(
            child: Image.asset(
              'assets/galaxies/galaxy2.png', // Ensure the image is correctly placed
              fit: BoxFit.cover, // Covers the full screen properly
            ),
          ),

          // Dark Overlay for Better Readability (Subtle, Refined)
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(0.4), // Slightly darker for clarity
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button (Refined for Better Placement)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title (Updated for Correct Font & Styling)
                  RichText(
                    text: TextSpan(
                      text: "Let's\n",
                      style: GoogleFonts.poppins(
                        fontSize: 54, // Medium size for "LET'S"
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.1, // Reduced space
                      ),
                      children: [
                        TextSpan(
                          text: "Start",
                          style: GoogleFonts.poppins(
                            fontSize: 64, // Much Bigger
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 120), // Lowering the form for better spacing

                  // Name Field
                  _buildInputField("Your Name", Icons.person),

                  const SizedBox(height: 20),

                  // Email Field
                  _buildInputField("Email", Icons.email),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildInputField("Password", Icons.lock, isPassword: true),

                  const SizedBox(height: 30), // More space before button

                  // Sign Up Button
                  _buildPrimaryButton("Sign Up", () {
                    // Signup Logic Here
                  }),

                  const SizedBox(height: 16),

                  // Terms and Conditions (Refined Styling)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to Terms & Conditions
                      },
                      child: Text(
                        "Terms and Conditions",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Input Field Widget (Brighter & Cleaner)
  Widget _buildInputField(String label, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        suffixIcon: Icon(icon, color: Colors.white, size: 22),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white.withOpacity(0.6), width: 1.5), // Softer look
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white, width: 2), // Highlight effect
        ),
      ),
    );
  }

  // Reusable Primary Button (Cleaner & More Modern)
  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.black,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
