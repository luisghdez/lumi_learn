import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/services/api_service.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';

// ─── Models ─────────────────────────────────────────────────────────────┐
class Classroom {
  final String id;
  final String title;
  final String subtitle;
  final int studentsCount;
  final int coursesCount;
  final int newSubmissions;
  final Color sideColor;
  final String inviteCode; // new
  final String ownerName; // new

  Classroom({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.studentsCount,
    required this.coursesCount,
    required this.newSubmissions,
    required this.sideColor,
    required this.inviteCode,
    required this.ownerName,
  });
}

class Submission {
  final String classId;
  final String submissionTitle; // e.g. lessonId or formatted name
  final String studentName; // userId or you can map to real name
  final String className; // ← new
  final String timeAgo; // completedAt string (or formatted)
  final Color sideColor; // ← new

  Submission({
    required this.classId,
    required this.submissionTitle,
    required this.studentName,
    required this.className,
    required this.timeAgo,
    required this.sideColor,
  });
}

class StudentProgress {
  final String studentName;
  final List<CourseProgress> courseProgress;

  StudentProgress({required this.studentName, required this.courseProgress});
}

class CourseProgress {
  final String courseName;
  final int progress; // 0–100
  final Color color;

  CourseProgress({
    required this.courseName,
    required this.progress,
    required this.color,
  });
}

class ClassCourse {
  final String courseName;
  final int avgProgress; // 0–100
  final Color color;

  ClassCourse({
    required this.courseName,
    required this.avgProgress,
    required this.color,
  });
}
// ────────────────────────────────────────────────────────────────────────┘

// ✅ Define Course model for classroomCourses
class Course {
  final String title;
  final String imagePath;
  final int completedLessons;
  final int totalLessons;
  final DateTime scheduledDate; // 🆕 Add this!



  Course({
    required this.title,
    required this.imagePath,
    required this.completedLessons,
    required this.totalLessons,
    required this.scheduledDate, // 🆕

  });
}

class ClassController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  var classrooms = <Classroom>[].obs;
  var recentSubmissions = <Submission>[].obs;
  var studentProgress = <String, List<StudentProgress>>{}.obs;
  var classCourses = <String, List<ClassCourse>>{}.obs;

  // 🆕 Added classroomCourses properly
  RxMap<String, List<Course>> classroomCourses = <String, List<Course>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllTeacherData();
  }

  Future<void> loadAllTeacherData() async {
    await _loadClassrooms();
    await _loadRecentSubmissions();
  }

  Future<void> _loadClassrooms() async {
    final token = await _auth.getIdToken();
    if (token == null) {
      Get.snackbar('Error', 'Not authenticated');
      return;
    }

    final res = await _api.getClasses(token: token);
    if (res.statusCode != 200) return;
    final List data = jsonDecode(res.body);

    final list = data.map((item) {
      final colorHex = item['colorCode'] as String? ?? '#4A90E2';
      return Classroom(
        id: item['id'],
        title: item['name'],
        subtitle: item['identifier'],
        studentsCount: item['studentCount'],
        coursesCount: item['courseCount'],
        newSubmissions: 0, // updated below
        sideColor: _colorFromHex(colorHex),
        inviteCode: item['inviteCode'],
        ownerName: item['ownerName'] ?? 'Unknown',
      );
    }).toList();

    classrooms.assignAll(list);
  }

  Future<void> _loadRecentSubmissions() async {
    final token = await _auth.getIdToken();
    if (token == null) return;

    final res = await _api.getAllClassSubmissions(token: token);
    if (res.statusCode != 200) return;

    final List data = jsonDecode(res.body);
    recentSubmissions.assignAll(data.map((item) {
      // parse the hex color code
      final rawColor = item['classColor'] as String? ?? '#4A90E2';
      final sideColor = _colorFromHex(rawColor);

      // format the lessonId into a nicer title if needed
      final submissionTitle = item['lessonId'];

      return Submission(
        classId: item['classId'],
        submissionTitle: submissionTitle,
        studentName: item['userId'], // or map ID→name separately
        className: item['className'], // now available
        timeAgo: item['completedAt'], // or turn into “2h ago”
        sideColor: sideColor, // class color
      );
    }).toList());
  }

  Future<void> loadStudentProgress(String classId) async {
    final token = await _auth.getIdToken();
    if (token == null) return;

    final res = await _api.getClassStudents(token: token, classId: classId);
    if (res.statusCode != 200) return;

    final coursesRes =
        await _api.getClassCourses(token: token, classId: classId);
    final Map<String, String> titles = {};
    if (coursesRes.statusCode == 200) {
      for (var c in jsonDecode(coursesRes.body)) {
        titles[c['id']] = c['title'];
      }
    }

    final List data = jsonDecode(res.body);
    studentProgress[classId] = data.map((stu) {
      final cp = (stu['progress'] as List).map((p) {
        final total = p['totalLessons'] as int;
        final done = p['completedLessons'] as int;
        final pct = total > 0 ? (done * 100 ~/ total) : 0;
        return CourseProgress(
          courseName: titles[p['courseId']] ?? p['courseId'],
          progress: pct,
          color: Colors.blueAccent,
        );
      }).toList();
      return StudentProgress(
        studentName: stu['name'],
        courseProgress: cp,
      );
    }).toList();
  }

  Future<void> loadClassCourses(String classId) async {
    final token = await _auth.getIdToken();
    if (token == null) return;

    // 1) Get the raw list of courses
    final coursesRes =
        await _api.getClassCourses(token: token, classId: classId);
    if (coursesRes.statusCode != 200) {
      return;
    }
    final List<dynamic> courses = jsonDecode(coursesRes.body);

    // 2) Instead of the broken progress endpoint, fetch students (each has a 'progress' list)
    final stuRes = await _api.getClassStudents(token: token, classId: classId);
    List<dynamic> students = [];
    if (stuRes.statusCode == 200) {
      students = jsonDecode(stuRes.body);
    }

    // 3) Build a bucket: courseId → [ pct1, pct2, pct3… ]
    final bucket = <String, List<int>>{};
    for (final stu in students) {
      final progList = stu['progress'] as List<dynamic>;
      for (final p in progList) {
        final cid = p['courseId'] as String;
        final total = p['totalLessons'] as int;
        final done = p['completedLessons'] as int;
        final pct = total > 0 ? (done * 100 ~/ total) : 0;
        bucket.putIfAbsent(cid, () => []).add(pct);
      }
    }

    // 4) Map your courses → ClassCourse, averaging each bucket
    final List<ClassCourse> mapped = courses.map<ClassCourse>((c) {
      final cid = c['id'] as String;
      final title = c['title'] as String;
      final arr = bucket[cid] ?? [];
      final avg = arr.isEmpty ? 0 : arr.reduce((a, b) => a + b) ~/ arr.length;

      return ClassCourse(
        courseName: title,
        avgProgress: avg,
        color: Colors.greenAccent,
      );
    }).toList();

    // 5) Push it into your observable map & trigger UI update
    classCourses[classId] = mapped;
    classCourses.refresh();
  }

  Color _colorFromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  void _loadDummyClassroomCourses() {
    classroomCourses.addAll({
      'Physics 101': [
        Course(
          title: 'Calculus Lesson',
          imagePath: 'assets/galaxies/galaxy10.png',
          completedLessons: 3,
          totalLessons: 5,
          scheduledDate: DateTime.now(),
        ),
        Course(
          title: 'Physics Basics',
          imagePath: 'assets/galaxies/galaxy10.png',
          completedLessons: 2,
          totalLessons: 4,
          scheduledDate: DateTime.now(),
        ),
      ],
      'Chemistry Advanced': [
        Course(
          title: 'Organic Chemistry',
          imagePath: 'assets/galaxies/galaxy10.png',
          completedLessons: 1,
          totalLessons: 3,
          scheduledDate: DateTime.now().add(Duration(days: 1)), // tomorrow


        ),
      ],
      'Introduction to Programming': [
        Course(
          title: 'Intro to Python',
          imagePath: 'assets/galaxies/galaxy10.png',
          completedLessons: 4,
          totalLessons: 6,
          scheduledDate: DateTime.now().add(Duration(days: 1)), // tomorrow

        ),
      ],
    });

  Future<void> createClassroom({
    required String title,
    required String identifier,
    required Color sideColor, // still pass in the selected Color
  }) async {
    final token = await _auth.getIdToken();
    if (token == null) {
      Get.snackbar('Error', 'Not authenticated');
      return;
    }

    // 1) Send to your API
    final res = await _api.createClassroom(
      token: token,
      name: title,
      identifier: identifier,
      colorCode: '#${sideColor.value.toRadixString(16).substring(2)}',
    );

    if (res.statusCode != 201) {
      final msg = jsonDecode(res.body)['error'] ?? 'Unknown error';
      Get.snackbar('Error', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 2) Parse the response
    final data = jsonDecode(res.body);
    final returnedHex = data['colorCode'] as String? ?? '#4A90E2';

    // 3) Build your Classroom model, converting the hex string back to a Color
    final room = Classroom(
      id: data['id'] as String,
      title: data['name'] as String,
      subtitle: data['identifier'] as String,
      studentsCount: 0,
      coursesCount: 0,
      newSubmissions: 0,
      sideColor: _colorFromHex(returnedHex), // <-- FIXED
      inviteCode: data['inviteCode'] as String,
      ownerName: data['ownerName'] ?? 'Unknown',
    );

    // 4) Insert into your list
    classrooms.insert(0, room);
  }
}
