import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/widgets/upgrade_popup.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedIndex = -1;
  final courseController = Get.find<CourseController>();
  final authController = Get.find<AuthController>();

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly Plan',
      'price': '\$7.99/month',
      'features': [
        'Unlimited course generation',
        'Access 100% of lesson content',
        'Full Access to shared courses',
        'Speaking and Listening practice',
        'Edit and delete your courses',
      ],
    },
    // {
    //   'title': '6-Month Plan',
    //   'price': '\$24.99/6 months',
    //   'features': [
    //     'Everything in Monthly Plan',
    //     'Priority support',
    //     'Access to early features',
    //     'Exclusive badges',
    //     'Discounted pricing',
    //   ],
    // },
    // {
    //   'title': 'Annual Plan',
    //   'price': '\$44.99/year',
    //   'features': [
    //     'Everything in 6-Month Plan',
    //     '1-on-1 mentorship access',
    //     'Exclusive webinars',
    //     'Advanced analytics',
    //     'Custom themes',
    //     'Early beta access',
    //   ],
    // },
  ];

  @override
  Widget build(BuildContext context) {
    // Determine if subscribe button should be disabled.
    final bool isButtonDisabled =
        authController.isPremium.value || _selectedIndex == -1;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent, // Prevent gray overlay
          shadowColor: Colors.transparent, // Remove shadow glow
          title: const Text("Subscription"),
          centerTitle: true,
        ),
        body: Column(
          children: [
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isButtonDisabled ? Colors.grey[800] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: isButtonDisabled
                    ? null
                    : () {
                        // Show the upgrade popup dialog
                        showDialog(
                          context: context,
                          builder: (context) => const UpgradePopup(),
                        );
                      },
                child: Text(
                  authController.isPremium.value
                      ? "Lumi PRO Active"
                      : "Subscribe Now",
                  style: TextStyle(
                    color: isButtonDisabled ? Colors.white38 : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planTile(int index) {
    final plan = _plans[index];
    final isSelected = _selectedIndex == index;
    final isActive =
        authController.isPremium.value && index == 0; // Monthly is index 0

    return GestureDetector(
      onTap: () {
        // Only allow plan selection if not already premium
        if (!authController.isPremium.value) {
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected || isActive
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.4)
                : (isSelected
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.1)),
            width: isActive ? 2.5 : (isSelected ? 2 : 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                isActive
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0004FF),
                              Color.fromARGB(255, 71, 0, 186),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Active",
                          style: TextStyle(
                              height: 0.9,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : const SizedBox(
                        width: 16,
                      ),
                const SizedBox(width: 8),
                Text(
                  plan['price'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (String feature in plan['features'])
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
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
