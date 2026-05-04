import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';

/// Shows [AuthController.authFormError] under form fields (no snackbars).
class AuthInlineError extends StatelessWidget {
  const AuthInlineError({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    return Obx(() {
      final msg = auth.authFormError.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            msg,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFF7A7A),
              height: 1.35,
            ),
          ),
        ),
      );
    });
  }
}
