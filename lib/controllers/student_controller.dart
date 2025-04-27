import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart'; // Import ClassController

// ✅ Upcoming Event model
class UpcomingEvent {
  final String eventTitle;
  final String className;
  final String dueDateText;
  final String daysLeftText;
  final Color sideColor;

  UpcomingEvent({
    required this.eventTitle,
    required this.className,
    required this.dueDateText,
    required this.daysLeftText,
    required this.sideColor,
  });
}

// ✅ Course model (optional if needed separately)
class Course {
  final String title;
  final String imagePath;
  final int completedLessons;
  final int totalLessons;

  Course({
    required this.title,
    required this.imagePath,
    required this.completedLessons,
    required this.totalLessons,
  });
}

// ✅ Student Controller
class StudentController extends GetxController {
  final ClassController classController = Get.find(); // Get access to ClassController

  // The classrooms the student is enrolled in
  RxList<Classroom> classrooms = <Classroom>[].obs;

  // Upcoming assignments/events
  RxList<UpcomingEvent> upcomingEvents = <UpcomingEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadStudentClassrooms();
    _loadDummyUpcomingEvents();
  }

  void _loadStudentClassrooms() {
    // Example: enroll the student into the first two classrooms
    if (classController.classrooms.length >= 2) {
      classrooms.addAll([
        classController.classrooms[0],
        classController.classrooms[1],
      ]);
    }
  }

  void _loadDummyUpcomingEvents() {
    upcomingEvents.addAll([
      UpcomingEvent(
        eventTitle: "Calculus Problem Set",
        className: "Physics 101",
        dueDateText: "Due Apr 27",
        daysLeftText: "3 days left",
        sideColor: Colors.blueAccent,
      ),
      UpcomingEvent(
        eventTitle: "Organic Chemistry Homework",
        className: "Chemistry Advanced",
        dueDateText: "Due Apr 28",
        daysLeftText: "4 days left",
        sideColor: Colors.purpleAccent,
      ),
      UpcomingEvent(
        eventTitle: "Final Project Research",
        className: "Introduction to Programming",
        dueDateText: "Due May 1",
        daysLeftText: "7 days left",
        sideColor: Colors.tealAccent,
      ),
      UpcomingEvent(
        eventTitle: "Final Project Research",
        className: "Introduction to Programming",
        dueDateText: "Due May 1",
        daysLeftText: "7 days left",
        sideColor: Colors.tealAccent,
      ),
    ]);
  }
}
