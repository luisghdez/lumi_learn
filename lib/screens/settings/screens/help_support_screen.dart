import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/courses/course_loading_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is Lumi?',
      'answer':
          'Lumi is a study guide app that uses AI to create personalized lessons based on your learning goals and performance.',
    },
    {
      'question': 'How do I get started?',
      'answer':
          'Just sign up, pick a subject, and Lumi will generate lessons tailored to your needs. You can also track progress and review previous lessons.',
    },
    {
      'question': 'Is Lumi free to use?',
      'answer':
          'Lumi offers a free plan with core features. To access premium content and tools, you can subscribe to one of our affordable plans.',
    },
    {
      'question': 'What subjects does Lumi support?',
      'answer':
          'Lumi supports a variety of subjects, including Math, Science, History, English, and more. Were always adding new topics!',
    },
    {
      'question': 'Can I use Lumi offline?',
      'answer':
          'Yes! Premium users can download lessons and access them offline for studying anytime, anywhere.',
    },
    {
      'question': 'How can I contact support?',
      'answer':
          'Lumi supports a variety of subjects, including Math, Science, History, English, and more. Were always adding new topics!',
    },
  ];

  final List<bool> _expanded = List.generate(6, (_) => false);

  @override
  Widget build(BuildContext context) {
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
          // Content
          Column(
            children: [
              // AppBar
              AppBar(
                title: const Text('Help and Support', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              // FAQ List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    final isOpen = _expanded[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          collapsedIconColor: Colors.white70,
                          iconColor: Colors.white,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          childrenPadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(
                            isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: lumiPurple,
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() => _expanded[index] = expanded);
                          },
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          children: [
                            Text(
                              faq['answer']!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}