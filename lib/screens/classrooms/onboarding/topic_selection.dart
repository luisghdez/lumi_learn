import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'confirmation.dart'; // Make sure the path is correct

class TopicSelectionScreen extends StatefulWidget {
  final String ageGroup;
  final VoidCallback onCompleteOnboarding; // <-- add this

  const TopicSelectionScreen({Key? key, required this.ageGroup, required this.onCompleteOnboarding}) : super(key: key);

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  late List<Map<String, dynamic>> topics;
  final Set<String> selectedTopics = {};

  @override
  void initState() {
    super.initState();
    topics = _getTopicsForAge(widget.ageGroup);
  }

List<Map<String, dynamic>> _getTopicsForAge(String ageGroup) {
  switch (ageGroup) {
    case "5-7":
      return [
        {"label": "Space", "icon": Icons.rocket_launch},
        {"label": "Animals", "icon": Icons.pets},
        {"label": "Drawing", "icon": Icons.brush},
        {"label": "Colors", "icon": Icons.palette},
        {"label": "Music", "icon": Icons.music_note},
        {"label": "Nature", "icon": Icons.eco},
        {"label": "Dancing", "icon": Icons.directions_run},
        {"label": "Cartoons", "icon": Icons.tv},
      ];
    case "8-10":
      return [
        {"label": "Coding", "icon": Icons.code},
        {"label": "Science", "icon": Icons.science},
        {"label": "Storytelling", "icon": Icons.menu_book},
        {"label": "Robots", "icon": Icons.smart_toy},
        {"label": "Art", "icon": Icons.color_lens},
        {"label": "Math Puzzles", "icon": Icons.calculate},
        {"label": "Space Exploration", "icon": Icons.travel_explore},
        {"label": "Sports", "icon": Icons.sports_soccer},
      ];
    case "11-13":
      return [
        {"label": "AI", "icon": Icons.memory},
        {"label": "Business", "icon": Icons.business_center},
        {"label": "Design", "icon": Icons.design_services},
        {"label": "Gaming", "icon": Icons.sports_esports},
        {"label": "Technology", "icon": Icons.devices},
        {"label": "Film Making", "icon": Icons.movie},
        {"label": "Graphic Design", "icon": Icons.brush_outlined},
        {"label": "Startups", "icon": Icons.lightbulb_outline},
      ];
    case "14-17":
      return [
        {"label": "Entrepreneurship", "icon": Icons.rocket_launch},
        {"label": "Creativity", "icon": Icons.lightbulb},
        {"label": "Marketing", "icon": Icons.show_chart},
        {"label": "Leadership", "icon": Icons.leaderboard},
        {"label": "Finance", "icon": Icons.attach_money},
        {"label": "Philosophy", "icon": Icons.psychology},
        {"label": "Personal Branding", "icon": Icons.badge},
        {"label": "Public Speaking", "icon": Icons.record_voice_over},
      ];
    case "18-22":
      return [
        {"label": "Gym & Fitness", "icon": Icons.fitness_center},
        {"label": "Cars", "icon": Icons.directions_car},
        {"label": "Entrepreneurship", "icon": Icons.rocket_launch},
        {"label": "Finance", "icon": Icons.attach_money},
        {"label": "Self-Development", "icon": Icons.psychology_alt},
        {"label": "Marketing", "icon": Icons.show_chart},
        {"label": "Design", "icon": Icons.design_services},
        {"label": "Public Speaking", "icon": Icons.record_voice_over},
      ];
    default:
      return [];
  }
}


  void _toggleSelection(String topic) {
    setState(() {
      if (selectedTopics.contains(topic)) {
        selectedTopics.remove(topic);
      } else {
        selectedTopics.add(topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final int crossAxisCount = isTablet ? 3 : 2;
    final double aspectRatio = isTablet ? .85 : .9;
    final double horizontalPadding = isTablet ? 48 : 24;
    final double titleFontSize = isTablet ? 32 : 24;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png', // your background
              fit: BoxFit.cover,
            ),
          ),

          // FOREGROUND CONTENT
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // 🔙 Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Flexible Title
                      Expanded(
                        child: Text(
                          "What interests you?",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: titleFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final isSelected = selectedTopics.contains(topic["label"]);

                        return GestureDetector(
                          onTap: () => _toggleSelection(topic["label"]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.purpleAccent
                                    : Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  topic["icon"],
                                  size: isTablet ? 40 : 32,
                                  color: isSelected ? Colors.purpleAccent : Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  topic["label"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 14,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: selectedTopics.isEmpty
                        ? null
                        : () {
                        Get.to(
                          () => ConfirmationScreen(
                            ageGroup: widget.ageGroup,
                            selectedTopics: selectedTopics.toList(),
                            onCompleteOnboarding: widget.onCompleteOnboarding, // <-- pass it here
                          ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 400),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
