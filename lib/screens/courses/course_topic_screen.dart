import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';

class CourseTopicScreen extends StatefulWidget {
  const CourseTopicScreen({Key? key}) : super(key: key);

  @override
  State<CourseTopicScreen> createState() => _CourseTopicScreenState();
}

class _CourseTopicScreenState extends State<CourseTopicScreen> {
  final List<String> _categories = [
    'Nursing',
    'Computer Science',
    'Business',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    // …add more
  ];

  final Map<String, IconData> _categoryIcons = {
    'Nursing': Icons.local_hospital,
    'Computer Science': Icons.computer,
    'Business': Icons.business_center,
    'Mathematics': Icons.calculate,
    'Physics': Icons.science,
    'Chemistry': Icons.science_outlined,
    'Biology': Icons.nature,
    // …add more mappings here
  };

  String _selectedCategory = 'Nursing';

  final List<Map<String, String>> _allTopics = [
    {
      'title': 'Anatomy and Physiology',
      'subtitle': 'Learn about structure and function of human body',
      'category': 'Nursing',
    },
    {
      'title': 'Pharmacology',
      'subtitle': 'Explore effects of drugs on the body',
      'category': 'Nursing',
    },
    {
      'title': 'Nursing Care',
      'subtitle': 'Learn principles of patient care',
      'category': 'Nursing',
    },
    {
      'title': 'Data Structures',
      'subtitle': 'Learn about data organization and storage',
      'category': 'Computer Science',
    },
    {
      'title': 'Algorithms',
      'subtitle': 'Explore problem-solving techniques',
      'category': 'Computer Science',
    },
    {
      'title': 'Software Engineering',
      'subtitle': 'Learn about software development processes',
      'category': 'Computer Science',
    },
    {
      'title': 'Marketing Strategies',
      'subtitle': 'Learn effective marketing techniques',
      'category': 'Business',
    },
    {
      'title': 'Financial Management',
      'subtitle': 'Explore financial principles and practices',
      'category': 'Business',
    },
    // … other topics
  ];

  List<Map<String, String>> get _filteredTopics =>
      _allTopics.where((t) => t['category'] == _selectedCategory).toList();

  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image stretched fully
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // 1) Top graphic + title with horizontal padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/astronaut/moon.png',
                        width: 220,
                        height: 220,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'What would you like to \nlearn today?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: -0.8,
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2) Category chips (no horizontal padding)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return ChoiceChip(
                        avatar: Icon(
                          _categoryIcons[cat],
                          color: selected ? Colors.black : Colors.white,
                        ),
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                          ),
                        ),
                        showCheckmark: false,
                        selected: selected,
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey.shade800,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 3) Topic list with horizontal padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      itemCount: _filteredTopics.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final t = _filteredTopics[i];
                        return _TopicTile(
                          title: t['title']!,
                          subtitle: t['subtitle']!,
                          isActive: _activeIndex == i,
                          onTap: () {
                            setState(() {
                              _activeIndex = _activeIndex == i ? null : i;
                            });
                          },
                          onConfirm: () {
                            Get.snackbar(
                                'Confirmed', 'You chose ${t['title']}');
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Divider OR row with OR text, padded
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade700)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                ),

                // 4) “Create Your Own Course” CTA with padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const CourseCreation(),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 400),
                        fullscreenDialog: true,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.open_in_new, color: Colors.black),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Your Own Course!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Upload your PDF, Images, PPTX for personalized learning',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onConfirm;

  const _TopicTile({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ---------- MAIN CONTENT ----------
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- SLIDE-IN CONFIRM ----------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              right: isActive ? 0 : -140,
              width: 140,
              child: GestureDetector(
                onTap: onConfirm,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF7d48a8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Start Learning!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
