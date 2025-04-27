import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ✅ Define Classroom model
class Classroom {
  final String title;
  final String subtitle;
  final int studentsCount;
  final int coursesCount;
  final int newSubmissions;
  final Color sideColor;
  final String joinCode; // 🆕 Add this!


  Classroom({
    required this.title,
    required this.subtitle,
    required this.studentsCount,
    required this.coursesCount,
    required this.newSubmissions,
    required this.sideColor,
    required this.joinCode,
  });
}

// ✅ Define Submission model
class Submission {
  final String submissionTitle;
  final String studentName;
  final String className;
  final String timeAgo;
  final Color sideColor;

  Submission({
    required this.submissionTitle,
    required this.studentName,
    required this.className,
    required this.timeAgo,
    required this.sideColor,
  });
}

// ✅ Define Progress and Courses model
class StudentProgress {
  final String studentName;
  final List<CourseProgress> courseProgress;

  StudentProgress({required this.studentName, required this.courseProgress});
}

class CourseProgress {
  final String courseName;
  final int progress;
  final Color color;

  CourseProgress({required this.courseName, required this.progress, required this.color});
}

class ClassCourse {
  final String courseName;
  final int avgProgress;
  final Color color;

  ClassCourse({required this.courseName, required this.avgProgress, required this.color});
}


// ✅ Controller
class ClassController extends GetxController {
  RxList<Classroom> classrooms = <Classroom>[].obs;
  RxList<Submission> recentSubmissions = <Submission>[].obs;
  RxList<StudentProgress> studentProgress = <StudentProgress>[].obs;
  RxList<ClassCourse> classCourses = <ClassCourse>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyClassrooms();
    _loadDummySubmissions();
    _loadDummyStudentProgress();
    _loadDummyClassCourses();
  }

  // ✅ Functions
  void createClassroom({
    required String title,
    required String subtitle,
    required int studentsCount,
    required int coursesCount,
    required Color sideColor,
    required String joinCode, 
  }) {
    final newClassroom = Classroom(
      title: title,
      subtitle: subtitle,
      studentsCount: studentsCount,
      coursesCount: coursesCount,
      newSubmissions: 0,
      sideColor: sideColor,
      joinCode: joinCode,
    );
    classrooms.add(newClassroom);
  }

  void clearClassrooms() {
    classrooms.clear();
  }

  // ✅ Dummy Data Loaders
  void _loadDummyClassrooms() {
    classrooms.addAll([
      Classroom(
        title: 'Physics 101',
        subtitle: 'CRN 12345',
        studentsCount: 25,
        coursesCount: 3,
        newSubmissions: 5,
        sideColor: Colors.blueAccent,
        joinCode: 'PHYS101',
      ),
      Classroom(
        title: 'Chemistry Advanced',
        subtitle: 'CRN 67890',
        studentsCount: 18,
        coursesCount: 2,
        newSubmissions: 2,
        sideColor: Colors.purpleAccent,
        joinCode: 'CHEM678',
      ),
      Classroom(
        title: 'Introduction to Programming',
        subtitle: 'CRN 54321',
        studentsCount: 30,
        coursesCount: 5,
        newSubmissions: 8,
        sideColor: Colors.tealAccent,
        joinCode: 'PROG543',
      ),
    ]);
  }

  void _loadDummySubmissions() {
    recentSubmissions.addAll([
      Submission(
        submissionTitle: 'Newton\'s Laws Course',
        studentName: 'Luis Hernandez',
        className: 'Physics 101',
        timeAgo: 'Yesterday',
        sideColor: Colors.blueAccent,
      ),
      Submission(
        submissionTitle: 'Organic Chemistry Basics',
        studentName: 'Sophia Martinez',
        className: 'Chemistry Advanced',
        timeAgo: '2h ago',
        sideColor: Colors.purpleAccent,
      ),
      Submission(
        submissionTitle: 'Intro to Python',
        studentName: 'Ethan Chen',
        className: 'Introduction to Programming',
        timeAgo: '23h ago',
        sideColor: Colors.tealAccent,
      ),
      Submission(
        submissionTitle: 'Intro to Python',
        studentName: 'Ethan Chen',
        className: 'Introduction to Programming',
        timeAgo: '23h ago',
        sideColor: Colors.tealAccent,
      ),
    ]);
  }

void _loadDummyStudentProgress() {
  studentProgress.addAll([
    StudentProgress(
      studentName: 'Luis Hernandez',
      courseProgress: [
        CourseProgress(courseName: 'Calculus Lesson', progress: 60, color: Colors.orangeAccent),
        CourseProgress(courseName: 'Other Lesson', progress: 45, color: Colors.deepPurpleAccent),
      ],
    ),
    StudentProgress(
      studentName: 'SITI AULIA RAHMAWATI PUTRI',
      courseProgress: [
        CourseProgress(courseName: 'Calculus Lesson', progress: 15, color: Colors.redAccent),
        CourseProgress(courseName: 'Other Lesson', progress: 10, color: Colors.pinkAccent),
      ],
    ),
    StudentProgress(
      studentName: 'AHMAD FAUZAN BINTANG RAMADHAN',
      courseProgress: [
        CourseProgress(courseName: 'Calculus Lesson', progress: 100, color: Colors.greenAccent),
        CourseProgress(courseName: 'Other Lesson', progress: 95, color: Colors.lightBlueAccent),
      ],
    ),
  ]);
}

void _loadDummyClassCourses() {
  classCourses.addAll([
    ClassCourse(courseName: 'Calculus Lesson', avgProgress: 60, color: Colors.orangeAccent),
    ClassCourse(courseName: 'Random Course', avgProgress: 15, color: Colors.redAccent),
    ClassCourse(courseName: 'Personalized Course', avgProgress: 100, color: Colors.greenAccent),
  ]);
}

}
