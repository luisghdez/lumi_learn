import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreakCelebrationScreen extends StatelessWidget {
  final int newStreak;

  const StreakCelebrationScreen({super.key, required this.newStreak});

  @override
  Widget build(BuildContext context) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final todayIndex = DateTime.now().weekday - 1; // 0 = Mon

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/black_moons_lighter.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),

              // 🔥 Center animation + text
              Column(
                children: [
                  // Placeholder for animation (swap with Lottie/Rive later)
                  Icon(Icons.local_fire_department,
                      color: Colors.orange, size: MediaQuery.of(context).size.width * 0.25),

                  const SizedBox(height: 20),

                  Text(
                    "🔥 Streak Extended!",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Your streak is now $newStreak days!",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 📅 Calendar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(days.length, (i) {
                    final isToday = i == todayIndex;

                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? Colors.purpleAccent : Colors.transparent,
                            border: Border.all(
                              color: Colors.purpleAccent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              days[i][0], // First letter
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.purpleAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[i],
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
