import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart'; // Import your controller

class WeeklySchedule extends StatelessWidget {
  const WeeklySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final ClassController classController = Get.find();

    // Collect all course dates
    final List<DateTime> scheduledDates = classController.classroomCourses.values
        .expand((courses) => courses.map((course) => course.scheduledDate))
        .toList();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekDates = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate size based on screen width
    double itemSize = screenWidth / 10; // smaller on small phones, bigger on tablets
    itemSize = itemSize.clamp(30.0, 50.0); // keep between 30-50px for sanity

    return SizedBox(
      height: itemSize + 50, // adjust height to match new item size
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final DateTime day = weekDates[index];
          final bool today = day.day == now.day && day.month == now.month && day.year == now.year;
          final bool hasEvent = scheduledDates.any((d) =>
              d.day == day.day && d.month == day.month && d.year == day.year
          );

          final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index],
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: itemSize * 0.35, // scale font based on item size
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    color: today ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      "${day.day}",
                      style: TextStyle(
                        color: today ? Colors.black : Colors.white,
                        fontSize: itemSize * 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                hasEvent
                  ? Container(
                      width: itemSize * 0.15,
                      height: itemSize * 0.15,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : SizedBox(height: itemSize * 0.15),
              ],
            ),
          );
        },
      ),
    );
  }
}
