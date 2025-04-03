import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly Plan',
      'price': '\$4.99/month',
      'features': [
        'Unlimited access to lessons',
        'Track progress',
        'Download content offline',
        'Ad-free experience',
      ],
    },
    {
      'title': '6-Month Plan',
      'price': '\$24.99/6 months',
      'features': [
        'Everything in Monthly Plan',
        'Priority support',
        'Access to early features',
        'Exclusive badges',
        'Discounted pricing',
      ],
    },
    {
      'title': 'Annual Plan',
      'price': '\$44.99/year',
      'features': [
        'Everything in 6-Month Plan',
        '1-on-1 mentorship access',
        'Exclusive webinars',
        'Advanced analytics',
        'Custom themes',
        'Early beta access',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Prevent gray overlay
        shadowColor: Colors.transparent,      // Remove shadow glow
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: _selectedIndex == -1
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Subscribed to ${_plans[_selectedIndex]['title']}')),
                      );
                    },
              child: const Text(
                "Subscribe Now",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile(int index) {
    final plan = _plans[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    plan['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
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
                    const Text('• ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
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
