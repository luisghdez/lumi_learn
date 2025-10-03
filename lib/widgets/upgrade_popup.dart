import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class UpgradePopup extends StatefulWidget {
  final String title;
  final String? subtitle;

  const UpgradePopup({
    Key? key,
    this.title = "",
    this.subtitle,
  }) : super(key: key);

  @override
  State<UpgradePopup> createState() => _UpgradePopupState();
}

class _UpgradePopupState extends State<UpgradePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _purchasePlan(
      String productId, AuthController authController) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null && current.availablePackages.isNotEmpty) {
        final package = current.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier.contains(productId),
          orElse: () => current.availablePackages.first,
        );

        await Purchases.purchasePackage(package);

        authController.isPremium.value = true;
        Get.back();
        Get.dialog(const LumiProSuccessDialog());
      } else {
        Get.snackbar("Oops", "No subscription packages available.");
      }
    } on PlatformException catch (error) {
      if (error.code == "purchaseCancelled" || error.code == "1") {
        return;
      } else if (error.code == "network_error") {
        Get.snackbar("Network Error",
            "Please check your internet connection and try again.");
      } else {
        Get.snackbar("Error", "Something went wrong: ${error.message}");
      }
    } catch (_) {
      Get.snackbar("Error", "An unexpected error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final isSmallPhone = size.height < 700;

    // Responsive sizing
    final double titleFontSize = isTablet ? 52 : (isSmallPhone ? 20 : 24);
    final double subtitleSize = isTablet ? 18 : (isSmallPhone ? 12 : 14);
    final double benefitFontSize = isTablet ? 20 : (isSmallPhone ? 12 : 14);
    final double benefitIconSize = isTablet ? 64 : (isSmallPhone ? 36 : 42);
    final double astronautHeight = isTablet ? 280 : (isSmallPhone ? 80 : 110);
    final double horizontalPadding = isTablet ? 32 : (isSmallPhone ? 18 : 22);
    final double verticalPadding = isTablet ? 40 : (isSmallPhone ? 16 : 24);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Animated shimmer overlay
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0004FF).withOpacity(0.05),
                        Colors.transparent,
                        const Color(0xFFA600FF).withOpacity(0.05),
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            top: true,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Premium badge
                              if (widget.title.isNotEmpty)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0004FF),
                                          Color(0xFFA600FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0004FF)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: subtitleSize,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: isSmallPhone ? 18 : 24),

                              // Title and astronaut
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          height: 1.1,
                                          letterSpacing: -1.2,
                                        ),
                                        children: [
                                          const TextSpan(text: "Upgrade to\n"),
                                          TextSpan(
                                            text: "Lumi PRO\n",
                                            style: TextStyle(
                                              foreground: Paint()
                                                ..shader =
                                                    const LinearGradient(
                                                  colors: [
                                                    Color(0xFF0004FF),
                                                    Color.fromARGB(
                                                        255, 124, 207, 255),
                                                    Color(0xFFA600FF),
                                                  ],
                                                ).createShader(
                                                  const Rect.fromLTWH(
                                                      0.0, 0.0, 300.0, 50.0),
                                                ),
                                            ),
                                          ),
                                          const TextSpan(text: "And unlock:"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Image.asset(
                                    'assets/astronaut/riding.png',
                                    height: astronautHeight,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 16 : 20),

                              // Benefits list with enhanced styling
                              BenefitItem(
                                assetPath: 'assets/icons/infinite.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'Unlimited ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: 'course generation'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 8),

                              BenefitItem(
                                assetPath: 'assets/icons/book.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'Complete ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: 'course content'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 8),

                              BenefitItem(
                                assetPath: 'assets/icons/unlock.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'Full Access ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: 'to shared courses'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 8),

                              BenefitItem(
                                assetPath: 'assets/icons/headset.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'Speaking and Listening ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: 'practice'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 8),

                              BenefitItem(
                                assetPath: 'assets/icons/trash.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'Edit and delete ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: 'your courses'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 8),

                              BenefitItem(
                                assetPath: 'assets/icons/xpstar.png',
                                iconSize: benefitIconSize,
                                fontSize: benefitFontSize,
                                textSpans: const [
                                  TextSpan(
                                    text: 'XP Boosts, ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(
                                      text:
                                          'profile cosmetics, and achievements'),
                                ],
                              ),
                              SizedBox(height: isSmallPhone ? 30 : 45),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom actions with enhanced styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Yearly button (promoted)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA500),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallPhone ? 12 : 14,
                                ),
                              ),
                              onPressed: () => _purchasePlan(
                                  "lumi_annual", authController),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Get Yearly for \$79.99/year",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize:
                                          isTablet ? 18 : (isSmallPhone ? 14 : 15),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Save 17% • Best Value",
                                    style: TextStyle(
                                      fontSize:
                                          isTablet ? 14 : (isSmallPhone ? 10 : 11),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Monthly button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.95),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallPhone ? 12 : 14,
                              ),
                            ),
                            onPressed: () =>
                                _purchasePlan("lumi_monthly", authController),
                            child: Text(
                              "Try for \$7.99/month",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 15),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "No thanks",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isTablet ? 17 : (isSmallPhone ? 13 : 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallPhone ? 24 : 32),
                        ],
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

class BenefitItem extends StatelessWidget {
  final String assetPath;
  final List<InlineSpan> textSpans;
  final double iconSize;
  final double fontSize;

  const BenefitItem({
    Key? key,
    required this.assetPath,
    required this.textSpans,
    this.iconSize = 56,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0004FF).withOpacity(0.2),
                  const Color(0xFFA600FF).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  height: 1.25,
                ),
                children: textSpans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LumiProSuccessDialog extends StatefulWidget {
  const LumiProSuccessDialog({super.key});

  @override
  State<LumiProSuccessDialog> createState() => _LumiProSuccessDialogState();
}

class _LumiProSuccessDialogState extends State<LumiProSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Container(
                width: isTablet ? 400 : 320,
                height: isTablet ? 700 : 560,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/lumi_pro_success_dialog.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0004FF).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: isTablet ? 70 : 50,
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Welcome to",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 36 : 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [
                                  Color(0xFF0004FF),
                                  Color.fromARGB(255, 124, 207, 255),
                                  Color.fromARGB(255, 174, 124, 255),
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              "LUMI PRO",
                              style: TextStyle(
                                fontSize: isTablet ? 44 : 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFF0F0F0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 32 : 24,
                                  vertical: isTablet ? 16 : 12,
                                ),
                              ),
                              child: Text(
                                "Start Exploring!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ),
                          ),
                        ],
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
}