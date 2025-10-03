import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  final courseController = Get.find<CourseController>();
  final authController = Get.find<AuthController>();
  late AnimationController _shimmerController;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly Plan',
      'price': '\$7.99/month',
      'identifier': 'lumi_monthly', // 👈 use your RevenueCat monthly product ID
      'gradientColors': [const Color(0xFF0004FF), const Color(0xFF4D4DFF)],
      'features': [
        'Unlimited course generation',
        'Access 100% of lesson content',
        'Full Access to shared courses',
        'Speaking and Listening practice',
        'Edit and delete your courses',
      ],
    },
    {
      'title': 'Yearly Plan',
      'price': '\$79.99/year',
      'identifier': 'lumi_annual', // 👈 use your RevenueCat yearly product ID
      'savings': 'Save \$16! Only \$6.67/month',
      'gradientColors': [const Color(0xFFFFB800), const Color(0xFFFFD700)],
      'features': [
        'Everything in Monthly Plan',
        'Best value - 2 months free',
        'Priority customer support',
        'Early access to new features',
        'Exclusive yearly subscriber badge',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (_selectedIndex == -1) return;

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null && current.availablePackages.isNotEmpty) {
        final targetId = _plans[_selectedIndex]['identifier'] as String;

        final package = current.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier.contains(targetId),
          orElse: () => current.availablePackages.first,
        );

        await Purchases.purchasePackage(package);

        authController.isPremium.value = true;
        Get.snackbar("Success", "Subscription activated!");
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
    final bool isButtonDisabled =
        authController.isPremium.value || _selectedIndex == -1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Animated gradient overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0004FF).withOpacity(0.03),
                        Colors.transparent,
                        const Color(0xFFA28BFF).withOpacity(0.03),
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  title: const Text("Subscription"),
                  centerTitle: true,
                ),
                _buildPremiumHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        for (int i = 0; i < _plans.length; i++) _planTile(i),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Cancel anytime from the App Store or device settings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: !isButtonDisabled
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonDisabled
                            ? Colors.grey[800]
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                      ),
                      onPressed: isButtonDisabled ? null : _subscribe,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!authController.isPremium.value)
                            const Icon(Icons.workspace_premium,
                                color: Colors.black, size: 22),
                          if (!authController.isPremium.value)
                            const SizedBox(width: 8),
                          Text(
                            authController.isPremium.value
                                ? "Lumi PRO Active"
                                : "Subscribe Now",
                            style: TextStyle(
                              color: isButtonDisabled
                                  ? Colors.white38
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFA28BFF).withOpacity(0.2),
            const Color(0xFF8B5CF6).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA28BFF).withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Unlock Lumi PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Get unlimited access to all premium features',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile(int index) {
    final plan = _plans[index];
    final isSelected = _selectedIndex == index;
    final isActive = authController.isPremium.value && index == 0;
    final gradientColors = plan['gradientColors'] as List<Color>;
    final isYearly = index == 1;

    return GestureDetector(
      onTap: () {
        if (!authController.isPremium.value) {
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isActive || isSelected
              ? LinearGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.1),
                    gradientColors[1].withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isActive && !isSelected
              ? Colors.white.withOpacity(0.03)
              : null,
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.4)
                : (isSelected
                    ? gradientColors[0].withOpacity(0.5)
                    : Colors.white.withOpacity(0.08)),
            width: isActive ? 2 : (isSelected ? 1.5 : 1),
          ),
          boxShadow: isActive || isSelected
              ? [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['title'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          if (isYearly) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    gradientColors[0].withOpacity(0.25),
                                    gradientColors[1].withOpacity(0.25),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: gradientColors[0].withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'BEST VALUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (plan['savings'] != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          plan['savings'],
                          style: TextStyle(
                            color: gradientColors[0].withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 12),
                        SizedBox(width: 3),
                        Text(
                          "Active",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 12),
                const SizedBox(width: 6),
                Text(
                  plan['price'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (String feature in plan['features'])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: gradientColors[0],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.4),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}