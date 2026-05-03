import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/utils/course_galaxy_image.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

/// Saved courses for the logged-in user ([forUserId] == null) or another user.
class SavedCoursesListScreen extends StatefulWidget {
  const SavedCoursesListScreen({
    super.key,
    this.forUserId,
    this.ownerDisplayName,
  });

  /// `null` = current user (uses [CourseController.fetchCourses]).
  final String? forUserId;
  final String? ownerDisplayName;

  @override
  State<SavedCoursesListScreen> createState() => _SavedCoursesListScreenState();
}

class _SavedCoursesListScreenState extends State<SavedCoursesListScreen> {
  final _api = ApiService();
  final _courseController = Get.find<CourseController>();

  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  bool _hasNext = false;
  bool _loadingMore = false;

  bool get _isSelf =>
      widget.forUserId == null || widget.forUserId == Get.find<AuthController>().firebaseUser.value?.uid;

  @override
  void initState() {
    super.initState();
    if (_isSelf && _courseController.courses.isNotEmpty) {
      _loading = false;
    } else if (!_isSelf && widget.forUserId != null) {
      final fc = Get.find<FriendsController>();
      final cached = fc.peekSavedCoursesPrefetch(widget.forUserId!);
      if (cached != null) {
        _courses = cached;
        _hasNext = fc.peekSavedCoursesPrefetchHasNext(widget.forUserId!);
        _page = fc.peekSavedCoursesPrefetchPage(widget.forUserId!);
        _loading = false;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitial();
    });
  }

  Future<void> _loadInitial() async {
    final friendsController = Get.find<FriendsController>();
    final bool showBlockingLoader = _isSelf
        ? _courseController.courses.isEmpty
        : (widget.forUserId == null ||
            !friendsController.hasSavedCoursesPrefetch(widget.forUserId!));

    if (showBlockingLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
        _loading = false;
        if (!_isSelf && widget.forUserId != null) {
          final cached =
              friendsController.peekSavedCoursesPrefetch(widget.forUserId!);
          if (cached != null) {
            _courses = cached;
            _hasNext =
                friendsController.peekSavedCoursesPrefetchHasNext(widget.forUserId!);
            _page =
                friendsController.peekSavedCoursesPrefetchPage(widget.forUserId!);
          }
        }
      });
    }
    if (_isSelf) {
      await _courseController.fetchCourses(page: 1, limit: 30);
      if (mounted) {
        setState(() {
          _courses = List<Map<String, dynamic>>.from(_courseController.courses);
          _loading = false;
          _hasNext = _courseController.hasNextPage.value;
          _page = _courseController.currentPage.value;
        });
      }
      return;
    }

    try {
      final token = await Get.find<AuthController>().getIdToken();
      if (token == null) throw Exception('Not signed in');
      final res = await _api.getUserSavedCourses(
        token: token,
        userId: widget.forUserId!,
        page: 1,
        limit: 30,
      );
      if (res.statusCode != 200) {
        throw Exception('${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['courses'] as List<dynamic>? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _courses = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _hasNext = pagination?['hasNextPage'] == true;
          _page = pagination?['page'] as int? ?? 1;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (_courses.isEmpty) {
            _error = e.toString();
          }
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _loadingMore || widget.forUserId == null) return;
    setState(() => _loadingMore = true);
    try {
      final token = await Get.find<AuthController>().getIdToken();
      if (token == null) return;
      final res = await _api.getUserSavedCourses(
        token: token,
        userId: widget.forUserId!,
        page: _page + 1,
        limit: 30,
      );
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['courses'] as List<dynamic>? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _courses.addAll(
            list.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          _hasNext = pagination?['hasNextPage'] == true;
          _page = pagination?['page'] as int? ?? _page + 1;
          _loadingMore = false;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openCourse(Map<String, dynamic> course) async {
    final id = course['id']?.toString() ?? '';
    final title = course['title']?.toString() ?? 'Course';
    final hasEmbeddings = course['hasEmbeddings'] == true;
    if (id.isEmpty) return;
    await _courseController.setSelectedCourseId(id, title, hasEmbeddings);
    if (!mounted) return;
    await Get.to<void>(
      () => const CourseOverviewScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.ownerDisplayName != null && widget.ownerDisplayName!.isNotEmpty
        ? "${widget.ownerDisplayName}'s courses"
        : 'My courses';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
                child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFB388FF)),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      : _isSelf
                          ? Obx(() {
                              final list = _courseController.courses;
                              if (list.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No saved courses yet.',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: list.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final c = list[i] as Map<String, dynamic>;
                                  return _CourseListTile(
                                    course: c,
                                    onTap: () => _openCourse(c),
                                  );
                                },
                              );
                            })
                          : NotificationListener<ScrollNotification>(
                              onNotification: (n) {
                                if (n is ScrollUpdateNotification) {
                                  final m = n.metrics;
                                  if (_hasNext &&
                                      !_loadingMore &&
                                      m.extentAfter < 200) {
                                    _loadMore();
                                  }
                                }
                                return false;
                              },
                              child: _courses.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No courses to show.',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _courses.length +
                                          (_loadingMore ? 1 : 0),
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        if (i >= _courses.length) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Center(
                                              child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFFB388FF),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        final c = _courses[i];
                                        return _CourseListTile(
                                          course: c,
                                          onTap: () => _openCourse(c),
                                        );
                                      },
                                    ),
                            ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _displayTagsForCourseList(Map<String, dynamic> course) {
  final raw = course['tags'];
  var tags = <String>[];
  if (raw is List) {
    tags = raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
  final subject = course['subject']?.toString();
  final hasEmbeddings = course['hasEmbeddings'] == true;
  if (hasEmbeddings && subject != null && subject.isNotEmpty) {
    tags = <String>[subject, ...tags];
  } else if (tags.isEmpty) {
    tags = ['#Classic'];
  }
  return tags.length > 5 ? tags.sublist(0, 5) : tags;
}

class _CourseListTile extends StatelessWidget {
  const _CourseListTile({
    required this.course,
    required this.onTap,
  });

  final Map<String, dynamic> course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final id = course['id']?.toString() ?? '';
    final title = course['title']?.toString() ?? 'Untitled';
    final subject = course['subject']?.toString() ?? '';
    final imagePath =
        id.isEmpty ? galaxyAssetPathForCourseId('unknown') : galaxyAssetPathForCourseId(id);
    final tags = _displayTagsForCourseList(course);

    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 76,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A2A2A),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white.withValues(alpha: 0.35),
                            size: 28,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (subject.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags
                          .map((tag) => TagChip(label: tag))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.38),
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
