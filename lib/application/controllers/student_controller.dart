import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';
import 'package:lumi_learn_app/application/services/api_service.dart'; // Import ClassController

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
  final String id; // Add ID if needed
  final String title;
  final String imagePath;
  final int completedLessons;
  final int totalLessons;

  Course({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.completedLessons,
    required this.totalLessons,
  });
}

// ✅ Student Controller
class StudentController extends GetxController {
  final ClassController classController =
      Get.find(); // Get access to ClassController
  final ApiService _api = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  // The classrooms the student is enrolled in
  RxList<Classroom> classrooms = <Classroom>[].obs;

  // Upcoming assignments/events
  RxList<UpcomingEvent> upcomingEvents = <UpcomingEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStudentClassrooms();
    _loadDummyUpcomingEvents();
  }

  var classroomCourses = <String, List<Course>>{}.obs;

  Future<void> fetchClassCourses(String classId) async {
    final token = await _auth.getIdToken();
    if (token == null) {
      Get.snackbar('Error', 'Not authenticated');
      return;
    }

    final res = await _api.getClassCourses(token: token, classId: classId);
    if (res.statusCode != 200) {
      Get.snackbar('Error', 'Couldn’t load courses');
      return;
    }

    final List<dynamic> raw = jsonDecode(res.body);
    // Convert each { id, title } into your Course model:
    final courses = raw.map<Course>((c) {
      return Course(
        id: c['id'], // Assuming the API returns an ID
        title: c['title'],
        imagePath:
            'assets/galaxies/galaxy1.png', // placeholder or use your hash fn
        completedLessons: 0, // you’ll fill this in later
        totalLessons: 0, // once you call the get-or-create route
        // scheduledDate: DateTime.now(),
      );
    }).toList();

    classroomCourses[classId] = courses;
  }

  Future<void> loadStudentClassrooms() async {
    await classController.loadStudentClasses();
    classrooms.assignAll(classController.classrooms);
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
