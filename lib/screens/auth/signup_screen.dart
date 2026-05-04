import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/auth/login_screen.dart';
import 'package:lumi_learn_app/widgets/auth_inline_error.dart';
import 'package:lumi_learn_app/widgets/lumi_cosmic_backdrop.dart';

class SignupScreen extends StatelessWidget {
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

    final double spacingLarge = isSmallPhone ? 20 : 32;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: LumiCosmicBackdrop()),
          SingleChildScrollView(
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

                    const AuthInlineError(),

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
                            "Sign up with",
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

                    Obx(() {
                      final busy = authController.isLoading.value;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                                "Google",
                                FontAwesomeIcons.google,
                                busy
                                    ? null
                                    : () async {
                                        await authController
                                            .signInWithGoogle();
                                      }),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildSocialButton(
                                "Apple",
                                FontAwesomeIcons.apple,
                                busy
                                    ? null
                                    : () async {
                                        await authController
                                            .signInWithApple();
                                      }),
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: spacingLarge),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          authController.clearAuthFormError();
                          Get.offAll(
                            () => LoginScreen(),
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
                          "Already have an account? Login",
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
        ],
      ),
    );
  }
}

Widget _buildSocialButton(String text, IconData icon, VoidCallback? onPressed) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    icon: Icon(icon, color: Colors.black, size: 20),
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
