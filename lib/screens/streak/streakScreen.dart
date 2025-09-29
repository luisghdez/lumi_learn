import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class StreakCelebrationScreen extends StatefulWidget {
  final int newStreak;

  const StreakCelebrationScreen({super.key, required this.newStreak});

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen> {
  @override
  Widget build(BuildContext context) {
    final days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    final todayIndex = DateTime.now().weekday - 1; // 0 = Monday
    final streak = widget.newStreak;

    // ✅ Compute which days should be checked (up to 7 days back)
    final Set<int> checkedDays = {};
    for (int i = 0; i < streak && i < 7; i++) {
      int dayIndex = (todayIndex - i) % 7;
      if (dayIndex < 0) dayIndex += 7;
      checkedDays.add(dayIndex);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌌 Background (stars + planets)
          Image.asset(
            "assets/images/black_moons_lighter.png",
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(flex: 2),

                // 🚀 Animation + streak number
                Column(
                  children: [
                    SizedBox(
                      height: 220,
                      width: 220,
                      child: Lottie.asset(
                        "assets/videos/firepurple.json", // <-- add an astronaut or rocket animation here
                        repeat: true,
                        animate: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Streak number with cosmic glow
                    Text(
                      "${widget.newStreak}",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.28,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color.fromARGB(255, 0, 1, 45), Color.fromARGB(255, 255, 255, 255)],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✨ Astronaut-style streak message
                    Text(
                      "Mission Log: Day $streak\nCommander, you’re crushing it!",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // 🪐 Calendar row (planets style)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 28,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(days.length, (i) {
                      final isChecked = checkedDays.contains(i);

                      return Column(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isChecked
                                  ? const LinearGradient(
                                      colors: [Color(0x9900012D), Color(0x993A005A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isChecked
                                  ? null
                                  : Colors.transparent,
                              border: Border.all(
                                color: isChecked
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: isChecked
                                  ? [
                                      BoxShadow(
                                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                                        blurRadius: 4,
                                        spreadRadius: 0.1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: isChecked
                                  ? const Icon(
                                      Icons.star, // ⭐ checked = glowing star
                                      color: Colors.white,
                                      size: 26,
                                    )
                                  : Text(
                                      days[i][0],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            days[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                const Spacer(flex: 1),


                // ✅ Futuristic glowing button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 232, 232, 243),
                        borderRadius: BorderRadius.circular(18),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.blueAccent.withOpacity(0.6),
                        //     offset: const Offset(0, 6),
                        //     blurRadius: 20,
                        //   ),
                        // ],
                      ),
                      child: const Text(
                        "LOCKED IN FOR LIFT-OFF",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          letterSpacing: 1.2,
                        ),
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
}
