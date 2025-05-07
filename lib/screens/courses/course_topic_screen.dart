import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart'; // or whatever your CourseCreation route is

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
    // …add more
  ];
  String _selectedCategory = 'Nursing';

  // A simple model for demo; you can pull this from JSON or a repo later.
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
    // … other topics in other categories
  ];

  List<Map<String, String>> get _filteredTopics =>
      _allTopics.where((t) => t['category'] == _selectedCategory).toList();
  @override
  Widget build(BuildContext context) {
    return AppScaffoldHome(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Top graphic + title
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'assets/astronaut/moon.png',
              width: 220,
              height: 220,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'What would you like to \nlearn today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: -0.8,
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2) Category chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat,
                      style: TextStyle(
                          color: selected ? Colors.black : Colors.white)),
                  selected: selected,
                  selectedColor: Colors.white,
                  backgroundColor: Colors.grey.shade800,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3) Topic list
          Expanded(
            child: ListView.separated(
              itemCount: _filteredTopics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final t = _filteredTopics[i];
                return GestureDetector(
                  onTap: () {
                    // TODO: handle pre-made topic click
                    // e.g. navigate & prefill, or call createCourse directly
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 4),
                        Text(t['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
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

          // 4) “Create Your Own Course” CTA
          GestureDetector(
            onTap: () {
              Get.to(() => const CourseCreation());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
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
                        Text('Create Your Own Course!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            )),
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

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
