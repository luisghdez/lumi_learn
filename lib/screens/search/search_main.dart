import 'package:flutter/material.dart';
import 'package:get/get.dart';

//controllers
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';

//widgets
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/widgets/custom_search_bar.dart';
import 'package:lumi_learn_app/widgets/regular_category_card.dart';

//screens
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';

class SearchMain extends StatefulWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  State<SearchMain> createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> {
  final Rx<Subject?> selectedSubject = Rx<Subject?>(null);
  final RxBool showSavedOnly = false.obs;
  final TextEditingController searchController = TextEditingController();
  final AuthController authController = Get.find();
  final ClassController classController = Get.put(ClassController());
  final CourseController courseController = Get.find<CourseController>();

  final List<Subject> subjects = const [
    Subject(id: 'all', name: 'All Subjects', icon: Icons.apps),
    Subject(id: 'math', name: 'Mathematics', icon: Icons.calculate),
    Subject(id: 'physics', name: 'Physics', icon: Icons.science),
    Subject(id: 'english', name: 'English', icon: Icons.menu_book),
    Subject(id: 'biology', name: 'Biology', icon: Icons.biotech),
    Subject(id: 'chemistry', name: 'Chemistry', icon: Icons.bubble_chart),
    Subject(id: 'history', name: 'History', icon: Icons.history_edu),
    Subject(
        id: 'computer_science', name: 'Computer Science', icon: Icons.computer),
    Subject(id: 'economics', name: 'Economics', icon: Icons.trending_up),
    Subject(id: 'psychology', name: 'Psychology', icon: Icons.psychology),
    Subject(id: 'sociology', name: 'Sociology', icon: Icons.groups),
    Subject(id: 'philosophy', name: 'Philosophy', icon: Icons.lightbulb),
    Subject(id: 'art', name: 'Art & Design', icon: Icons.palette),
    Subject(id: 'music', name: 'Music', icon: Icons.music_note),
    Subject(id: 'languages', name: 'Foreign Languages', icon: Icons.translate),
  ];

  @override
  void initState() {
    super.initState();
    selectedSubject.value = subjects.first; // Default to 'All Subjects'
  }

  double get horizontalPadding {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? 32.0 : 16.0;
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenContainer(
      onRefresh: _handleRefresh,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HomeHeader(
                //   title: 'Explore',
                //   streakCount: authController.streakCount.value,
                //   xpCount: authController.xpCount.value,
                //   isPremium: authController.isPremium.value,
                // ),
                // const SizedBox(height: 16),
                CustomSearchBar(
                  controller: searchController,
                  hintText: 'Search courses, topics or tags...',
                  onChanged: (query) {
                    // Search logic here
                  },
                ),
                const SizedBox(height: 20),
                // Subject and Saved Filters
                Row(
                  children: [
                    Expanded(
                      child: _SubjectSelector(
                        selectedSubject: selectedSubject.value,
                        subjects: subjects,
                        onSubjectSelected: (subject) {
                          selectedSubject.value = subject;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _SavedCoursesToggle(
                      isSelected: showSavedOnly.value,
                      onToggle: () {
                        showSavedOnly.value = !showSavedOnly.value;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Course List
                _buildCourseList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseList() {
    if (!showSavedOnly.value) {
      // When saved is not selected, show placeholder message
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.explore,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            Text(
              'Select "Saved" to view your courses',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toggle the saved filter to see all your saved courses',
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

    // Filter courses based on selected subject and saved status
    List<Map<String, dynamic>> filteredCourses =
        List<Map<String, dynamic>>.from(
            courseController.courses.where((course) {
      // Subject filter
      if (selectedSubject.value?.id != 'all') {
        final courseSubject = course['subject']?.toString().toLowerCase() ?? '';
        final selectedSubjectName =
            selectedSubject.value?.name.toLowerCase() ?? '';
        if (!courseSubject.contains(selectedSubjectName) &&
            !selectedSubjectName.contains(courseSubject)) {
          return false;
        }
      }
      return true;
    }));

    if (filteredCourses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            Text(
              selectedSubject.value?.id == 'all'
                  ? 'No saved courses found'
                  : 'No saved ${selectedSubject.value?.name.toLowerCase()} courses',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
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
    }

    return Column(
      children: filteredCourses.map<Widget>((course) {
        final galaxyImagePath = getGalaxyForCourse(course['id']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RegularCategoryCard(
            imagePath: galaxyImagePath,
            courseName: course['title'] ?? 'Untitled',
            tags: List<String>.from(course['tags'] ?? []),
            bookmarkCount: course['totalLessons'] ?? 0,
            lessonCount: course['totalLessons'] ?? 0,
            subject: course['subject'],
            hasEmbeddings: course['hasEmbeddings'] ?? false,
            onStartLearning: () async {
              // Navigate to course details - same logic as CategoryCard
              courseController.setSelectedCourseId(
                  course['id'], course['title'], course['hasEmbeddings']);

              Get.to(
                () => LoadingScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
              await Future.wait([
                Future.delayed(const Duration(milliseconds: 1000)),
                precacheImage(
                  const AssetImage('assets/images/milky_way.png'),
                  context,
                ),
              ]);

              while (courseController.isLoading.value) {
                await Future.delayed(const Duration(milliseconds: 100));
              }

              // Navigate to CourseOverviewScreen
              Get.offAll(
                () => const CourseOverviewScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            },
          ),
        );
      }).toList(),
    );
  }
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

class Subject {
  final String id;
  final String name;
  final IconData icon;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
  });
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
        _filteredSubjects = widget.subjects
            .where((subject) =>
                subject.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = screenHeight * 0.75;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Select Subject',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
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
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              itemCount: _filteredSubjects.length,
              itemBuilder: (context, index) {
                final subject = _filteredSubjects[index];
                final isSelected = widget.selectedSubject?.id == subject.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white30 : Colors.white10,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      subject.icon,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    title: Text(
                      subject.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
