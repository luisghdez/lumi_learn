import 'package:flutter/material.dart';
import 'package:get/get.dart';

//controllers
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';

//widgets
import 'package:lumi_learn_app/widgets/regular_category_card.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

//screens
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';

class SearchMain extends StatelessWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LumiSearchController searchController =
        Get.find<LumiSearchController>();
    final CourseController courseController = Get.find<CourseController>();

    double getHorizontalPadding() {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth > 800 ? 32.0 : 16.0;
    }

    final double horizontalPadding = getHorizontalPadding();
    final double topScrollViewPadding =
        MediaQuery.of(context).padding.top + horizontalPadding;
    const double bottomScrollViewPadding = 40.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons_lighter.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              top: false,
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: topScrollViewPadding,
                      bottom: bottomScrollViewPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            topScrollViewPadding -
                            bottomScrollViewPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CustomSearchBar(
                                  //   controller: TextEditingController(
                                  //       text: searchController.searchQuery.value),
                                  //   hintText: 'Search courses, topics or tags...',
                                  //   onChanged: (query) {
                                  //     searchController.setSearchQuery(query);
                                  //   },
                                  // ),
                                  // const SizedBox(height: 20),
                                  // Subject and Saved Filters
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SubjectSelector(
                                          selectedSubject: searchController
                                              .selectedSubject.value,
                                          subjects: searchController.subjects,
                                          onSubjectSelected: (subject) {
                                            searchController
                                                .setSelectedSubject(subject);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _SavedCoursesToggle(
                                        isSelected: searchController
                                            .showSavedOnly.value,
                                        onToggle: () {
                                          searchController.toggleSavedFilter();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Course List
                                  _buildCourseList(
                                      searchController, courseController),
                                  // Pagination Controls (for both saved and all courses)
                                  _buildPaginationControls(
                                      searchController, courseController),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCourseList(
    LumiSearchController searchController, CourseController courseController) {
  // Show loading indicator only for initial load (not pagination)
  if (searchController.isLoading.value &&
      !searchController.isPaginating.value) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> filteredCourses = [];

  if (searchController.showSavedOnly.value) {
    // When showing saved courses, use saved courses from SearchController (already filtered by backend)
    // Only apply client-side search query filtering since backend handles subject filtering
    filteredCourses = List<Map<String, dynamic>>.from(
        searchController.savedCourses.where((course) {
      // Search query filter for saved courses (backend handles subject filtering)
      if (searchController.searchQuery.value.isNotEmpty) {
        final title = course['title']?.toString().toLowerCase() ?? '';
        final subject = course['subject']?.toString().toLowerCase() ?? '';
        final tags = List<String>.from(course['tags'] ?? [])
            .map((tag) => tag.toLowerCase())
            .join(' ');
        final query = searchController.searchQuery.value.toLowerCase();

        if (!title.contains(query) &&
            !subject.contains(query) &&
            !tags.contains(query)) {
          return false;
        }
      }

      return true;
    }));
  } else {
    // When showing all courses, use the new filteredCourses getter
    filteredCourses = searchController.filteredCourses;
  }

  // Handle empty states
  if (filteredCourses.isEmpty) {
    if (searchController.showSavedOnly.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.bookmark_border,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            Text(
              searchController.selectedSubject.value?.id == 'all'
                  ? 'No saved courses found'
                  : 'No saved ${searchController.selectedSubject.value?.name.toLowerCase()} courses',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create or save some courses to see them here',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      // No courses found in explore mode
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.explore_off,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            Text(
              searchController.selectedSubject.value?.id == 'all'
                  ? 'No courses found'
                  : 'No ${searchController.selectedSubject.value?.name.toLowerCase()} courses found',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or subject filter',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // Display the filtered courses
  return Column(
    children: filteredCourses.map<Widget>((course) {
      final galaxyImagePath = getGalaxyForCourse(course['id']);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Builder(
          builder: (context) => RegularCategoryCard(
            imagePath: galaxyImagePath,
            courseName: course['title'] ?? 'Untitled',
            tags: List<String>.from(course['tags'] ?? []),
            bookmarkCount: course['savedCount'] ?? 0,
            lessonCount: course['lessonCount'] ?? course['totalLessons'] ?? 0,
            subject: course['subject'],
            hasEmbeddings: course['hasEmbeddings'] ?? false,
            onStartLearning: () => _showCourseConfirmationDialog(
                context, course, courseController),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _buildPaginationControls(
    LumiSearchController searchController, CourseController courseController) {
  return Obx(() {
    // Determine which controller to use based on the current mode
    final bool showSavedOnly = searchController.showSavedOnly.value;
    final bool hasPreviousPage = showSavedOnly
        ? searchController.savedHasPreviousPage.value
        : searchController.hasPreviousPage.value;
    final bool hasNextPage = showSavedOnly
        ? searchController.savedHasNextPage.value
        : searchController.hasNextPage.value;
    final int currentPage = showSavedOnly
        ? searchController.savedCurrentPage.value
        : searchController.currentPage.value;
    final int totalPages = showSavedOnly
        ? searchController.savedTotalPages.value
        : searchController.totalPages.value;
    final bool isPaginating = searchController.isPaginating.value;

    // Only show pagination if there are multiple pages
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          GestureDetector(
            onTap: hasPreviousPage && !isPaginating
                ? () => searchController.fetchPreviousPage()
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasPreviousPage && !isPaginating
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasPreviousPage && !isPaginating
                      ? Colors.white24
                      : Colors.white12,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: hasPreviousPage && !isPaginating
                    ? Colors.white
                    : Colors.white38,
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Page indicator with subtle loading animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPaginating
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPaginating ? Colors.white38 : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPaginating) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '$currentPage / $totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Next button
          GestureDetector(
            onTap: hasNextPage && !isPaginating
                ? () => searchController.fetchNextPage()
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasNextPage && !isPaginating
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasNextPage && !isPaginating
                      ? Colors.white24
                      : Colors.white12,
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: hasNextPage && !isPaginating
                    ? Colors.white
                    : Colors.white38,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Future<void> _navigateToUserProfile(String userId) async {
  try {
    final friendsController = Get.find<FriendsController>();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await friendsController.setActiveFriend(userId);
    Get.back(); // Close loading dialog
    Get.to(
      () => const FriendProfile(),
      transition: Transition.fadeIn,
    );
  } catch (e) {
    Get.back(); // Close loading dialog
    Get.snackbar("Error", "Could not load profile: $e");
  }
}

void _showCourseConfirmationDialog(BuildContext context,
    Map<String, dynamic> course, CourseController courseController) {
  List<String> displayTags = List<String>.from(course['tags'] ?? []);
  final String title = course['title'] ?? 'Untitled Course';
  final String? subject = course['subject'];
  final bool hasEmbeddings = course['hasEmbeddings'] ?? false;
  final int totalSaves = course['savedCount'] ?? 0;
  final int totalLessons = course['lessonCount'] ?? course['totalLessons'] ?? 0;
  final String createdByName = course['createdByName'] ?? 'Anonymous';
  final String? createdById = course['createdById'] ?? course['createdBy'];

  // Add subject tag if hasEmbeddings is true and subject is available
  if (hasEmbeddings && subject != null && subject.isNotEmpty) {
    displayTags.insert(0, subject);
  } else if (displayTags.isEmpty) {
    // Only show default tags when no subject and no other tags
    displayTags = ['#Classic'];
  }

  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: "Course Confirm",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink(); // required but unused
    },
    transitionBuilder: (context, animation, _, __) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent outside tap
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          if (createdById != null) {
                            _navigateToUserProfile(createdById);
                          }
                        },
                        child: Text(
                          'Created by: $createdByName',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: createdById != null
                                ? Colors.white70
                                : Colors.white54,
                            decoration: createdById != null
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: displayTags
                            .map((tag) => TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border,
                              color: Colors.white60, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$totalSaves',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.menu_book_rounded,
                              color: Colors.white60, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$totalLessons lesson${totalLessons != 1 ? 's' : ''}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Close dialog
                            _navigateToCourse(
                                course, courseController); // Proceed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Start Learning'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _navigateToCourse(
    Map<String, dynamic> course, CourseController courseController) async {
  if (course['loading'] == true) return;

  // Check if course is already saved
  bool isAlreadySaved = courseController.courses
      .any((savedCourse) => savedCourse['id'] == course['id']);

  if (!isAlreadySaved) {
    // Only check slots and save if it's not already saved
    if (!courseController.checkCourseSlotAvailable()) {
      return;
    }

    bool saved =
        await courseController.saveSharedCourse(course['id'], course['title']);
    if (!saved) return;
  }

  // Always proceed to navigation regardless of save status
  courseController.setSelectedCourseId(
      course['id'], course['title'], course['hasEmbeddings'] ?? false);

  Get.to(
    () => LoadingScreen(),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 500),
  );

  await Future.wait([
    Future.delayed(const Duration(milliseconds: 1000)),
    precacheImage(
      const AssetImage('assets/images/milky_way.png'),
      Get.context!,
    ),
  ]);

  while (courseController.isLoading.value) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Get.offAll(
    () => const CourseOverviewScreen(),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 500),
  );
}

// Galaxy assignment function (copied from category_list.dart)
String getGalaxyForCourse(String courseId) {
  final galaxies = [
    'assets/galaxies/galaxy1.png',
    'assets/galaxies/galaxy2.png',
    'assets/galaxies/galaxy3.png',
    'assets/galaxies/galaxy4.png',
    'assets/galaxies/galaxy5.png',
    'assets/galaxies/galaxy6.png',
    'assets/galaxies/galaxy7.png',
    'assets/galaxies/galaxy8.png',
    'assets/galaxies/galaxy9.png',
    'assets/galaxies/galaxy10.png',
    'assets/galaxies/galaxy11.png',
    'assets/galaxies/galaxy12.png',
    'assets/galaxies/galaxy13.png',
    'assets/galaxies/galaxy14.png',
    'assets/galaxies/galaxy15.png',
    'assets/galaxies/galaxy16.png',
    'assets/galaxies/galaxy17.png',
  ];

  // Use the course ID hash to pick a consistent galaxy
  int hash = courseId.hashCode.abs();
  return galaxies[hash % galaxies.length];
}

class _SubjectSelector extends StatelessWidget {
  final Subject? selectedSubject;
  final List<Subject> subjects;
  final Function(Subject) onSubjectSelected;

  const _SubjectSelector({
    Key? key,
    required this.selectedSubject,
    required this.subjects,
    required this.onSubjectSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showSubjectSelector(context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTabletOrBigger ? 16 : 12,
              horizontal: isTabletOrBigger ? 16 : 14,
            ),
            child: Row(
              children: [
                Icon(
                  selectedSubject?.icon ?? Icons.apps,
                  color: Colors.white,
                  size: isTabletOrBigger ? 20 : 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedSubject?.name ?? 'Select Subject',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isTabletOrBigger ? 16 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: isTabletOrBigger ? 24 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubjectSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SubjectSelectionModal(
        subjects: subjects,
        selectedSubject: selectedSubject,
        onSubjectSelected: onSubjectSelected,
      ),
    );
  }
}

class _SubjectSelectionModal extends StatefulWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final Function(Subject) onSubjectSelected;

  const _SubjectSelectionModal({
    Key? key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
  }) : super(key: key);

  @override
  State<_SubjectSelectionModal> createState() => _SubjectSelectionModalState();
}

class _SubjectSelectionModalState extends State<_SubjectSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Subject> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = widget.subjects;
  }

  void _filterSubjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = widget.subjects;
      } else {
        // When searching, show only matching subjects (no headers)
        _filteredSubjects = widget.subjects
            .where((subject) =>
                !subject.isHeader &&
                subject.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double modalHeight = screenHeight * 0.75;

    return Material(
      child: Container(
        height: modalHeight,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSubjects,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  hintStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Subject list
            Expanded(
              child: _filteredSubjects.isEmpty
                  ? _buildEmptySearchState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _filteredSubjects[index];
                        final isSelected =
                            widget.selectedSubject?.id == subject.id;

                        // If this is a header item
                        if (subject.isHeader) {
                          return Container(
                            margin: EdgeInsets.only(
                                top: index == 0 ? 0 : 16, bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  subject.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  subject.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white30,
                                    indent: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Regular subject item
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8, left: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.white30 : Colors.white10,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                subject.icon,
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                size: 20,
                              ),
                              title: Text(
                                subject.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                              onTap: () {
                                widget.onSubjectSelected(subject);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.white60,
          ),
          SizedBox(height: 16),
          Text(
            'No subjects found',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavedCoursesToggle extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onToggle;

  const _SavedCoursesToggle({
    Key? key,
    required this.isSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white24,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTabletOrBigger ? 16 : 12,
              horizontal: isTabletOrBigger ? 16 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.bookmark : Icons.bookmark_border,
                  color: isSelected ? Colors.black : Colors.white,
                  size: isTabletOrBigger ? 20 : 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Saved',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTabletOrBigger ? 18 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
