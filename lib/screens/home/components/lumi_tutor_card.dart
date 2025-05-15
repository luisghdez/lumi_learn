import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';

import 'package:lumi_learn_app/screens/lumiTutor/lumi_tutor_main.dart';
import 'package:lumi_learn_app/widgets/no_swipe_route.dart';

class LumiTutorCard extends StatelessWidget {
  const LumiTutorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    final popularQuestions = [
      'What is photosynthesis?',
      'Solve quadratic equations',
      'Periodic table trends',
      'Pythagorean theorem proof',
      'Parts of a cell',
      'Newton’s 2nd law',
    ];

    final recentQuestions = [
      'Explain Shakespeare’s Macbeth',
      'Word problems with fractions',
      'Causes of World War II',
      'SQL basic queries',
      'Human respiratory system',
      'Essay structure tips',
    ];

    Widget buildSuggestionRows() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: popularQuestions
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TransparentTag(label: q),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: recentQuestions
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TransparentTag(label: q),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greyBorder),
        gradient: const LinearGradient(
          colors: [
            Color(0x9900012D),
            Color(0x993A005A),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/astronaut/teacher.png',
                    width: 100,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ask Me Anything!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: 
                          ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              NoSwipePageRoute(
                                builder: (_) => const LumiTutorMain(
                                  initialArgs: {
                                    'type': 'text',
                                    'paths': [],
                                    'category': 'Anything',
                                  },
                                ),
                              ),
                            );
                          },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Go to LumiTutor'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            buildSuggestionRows(),
          ],
        ),
      ),
    );
  }
}

class _TransparentTag extends StatelessWidget {
  final String label;
  const _TransparentTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(14, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}
