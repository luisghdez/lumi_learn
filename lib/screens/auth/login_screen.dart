import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    final isSmallPhone = size.height < 700 || size.width < 375;

    final double horizontalPadding = isTablet
        ? size.width * 0.2
        : isSmallPhone
            ? 20
            : size.width * 0.06;

    final double titleFontSize = isTablet
        ? 44
        : isSmallPhone
            ? 28
            : 40;

    final double subTitleFontSize = isTablet
        ? 64
        : isSmallPhone
            ? 42
            : 58;

    final double topPadding = isTablet
        ? size.height * 0.08
        : isSmallPhone
            ? 30
            : size.height * 0.06;

    final double betweenTitleAndFields = isTablet
        ? size.height * 0.1
        : isSmallPhone
            ? 24
            : size.height * 0.08;

    final double spacingSmall = isSmallPhone ? 6 : 14;
    final double spacingMedium = isSmallPhone ? 12 : 24;
    final double spacingLarge = isSmallPhone ? 20 : 32;

    return Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPadding),

                  // Title
                  RichText(
                    text: TextSpan(
                      text: "Let's\n",
                      style: TextStyle(
                        fontSize: titleFontSize.toDouble(),
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      children: [
                        TextSpan(
                          text: "Start",
                          style: GoogleFonts.poppins(
                            fontSize: subTitleFontSize.toDouble(),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: betweenTitleAndFields),

                  _buildInputField(
                    "Email Address",
                    Icons.email,
                    controller: emailController,
                  ),
                  SizedBox(height: spacingMedium),

                  _buildInputField(
                    "Password",
                    Icons.lock,
                    isPassword: true,
                    controller: passwordController,
                  ),

                  SizedBox(height: spacingSmall),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacingMedium),

                  _buildPrimaryButton("Log In", () {
                    authController.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  }),

                  SizedBox(height: spacingLarge),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.5),
                          thickness: 1.2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Or login with",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.5),
                          thickness: 1.2,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacingLarge),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                            "Google", FontAwesomeIcons.google, () async {
                          await authController.signInWithGoogle();
                        }),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildSocialButton(
                            "Apple", FontAwesomeIcons.apple, () async {
                          await authController.signInWithApple();
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: spacingLarge),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Get.offAll(
                          () => SignupScreen(),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        "Are you new? Create an account",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: authController.isLoading.value ? null : onPressed,
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
                  )
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

Widget _buildInputField(String label, IconData icon,
    {bool isPassword = false, TextEditingController? controller}) {
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

Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    icon: Icon(icon, color: Colors.black, size: 20), // Use built-in icons
    label: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );
}
