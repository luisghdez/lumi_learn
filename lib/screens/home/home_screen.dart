import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/search_controller.dart';
import 'package:lumi_learn_app/app_features.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/screens/aiScanner/ai_scanner_main.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/home/components/feature_card.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_list.dart';
import 'package:lumi_learn_app/screens/ap_catalog/ap_catalog_screen.dart';
import 'package:lumi_learn_app/screens/home/components/ap_courses_card.dart';
import 'package:lumi_learn_app/screens/home/components/lumi_tutor_card.dart';
import 'package:lumi_learn_app/screens/search/search_main.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:lumi_learn_app/screens/lumiTutor/lumi_tutor_main.dart';

import 'components/category_list.dart';
import 'components/top_picks_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const double _tabletBreakpoint = 800.0;
  static const bool _showLumiTutorSection = false;
  List<CameraDescription>? _cameras;
  late AnimationController _animationController;
  late AnimationController _courseSearchOverlayController;
  final LayerLink _courseSearchLayerLink = LayerLink();
  OverlayEntry? _courseSearchOverlayEntry;
  bool _courseSearchFiltersOpen = false;
  bool _courseSearchTypeMenuOpen = false;
  bool _courseSearchSubjectMenuOpen = false;
  late CourseCollection _courseSearchCollection = courseCollections.first;
  Subject? _courseSearchSubject;
  bool _courseSearchSavedOnly = !AppFeatures.publicCourseDiscoveryEnabled;

  Subject get _effectiveSearchSubject =>
      _courseSearchSubject ?? _courseSearchCollection.defaultSubject;

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _courseSearchOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    // Trigger animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _removeCourseSearchOverlay();
    _animationController.dispose();
    _courseSearchOverlayController.dispose();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    final cameras = await availableCameras();
    setState(() {
      _cameras = cameras;
    });
  }

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > _tabletBreakpoint ? 32.0 : 16.0;
  }

  void _toggleCourseSearchFilters() {
    if (_courseSearchFiltersOpen) {
      _hideCourseSearchFilters();
    } else {
      _showCourseSearchFilters();
    }
  }

  void _showCourseSearchFilters() {
    if (_courseSearchOverlayEntry != null) return;
    _courseSearchTypeMenuOpen = false;
    _courseSearchSubjectMenuOpen = false;
    setState(() => _courseSearchFiltersOpen = true);
    _courseSearchOverlayEntry = OverlayEntry(
      builder: (context) {
        final double horizontalPadding = _getHorizontalPadding(context);
        final double panelWidth =
            MediaQuery.of(context).size.width - horizontalPadding * 2;
        return AnimatedBuilder(
          animation: _courseSearchOverlayController,
          builder: (context, _) {
            final double progress = Curves.easeOutCubic
                .transform(_courseSearchOverlayController.value);
            return Stack(
              children: [
                // Scrim: a dimmed, gently blurred backdrop so the surrounding
                // content recedes while the search surface stays in focus.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _hideCourseSearchFilters,
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 6 * progress,
                        sigmaY: 6 * progress,
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45 * progress),
                      ),
                    ),
                  ),
                ),
                CompositedTransformFollower(
                  link: _courseSearchLayerLink,
                  showWhenUnlinked: false,
                  offset: Offset.zero,
                  child: SizedBox(
                    width: panelWidth,
                    child: _CourseSearchExpandedPanel(
                      progress: progress,
                      collection: _courseSearchCollection,
                      collections: courseCollections,
                      selectedSubject: _effectiveSearchSubject,
                      savedOnly: _courseSearchSavedOnly,
                      typeMenuOpen: _courseSearchTypeMenuOpen,
                      subjectMenuOpen: _courseSearchSubjectMenuOpen,
                      onClose: _hideCourseSearchFilters,
                      onToggleTypeMenu: () {
                        setState(() {
                          _courseSearchTypeMenuOpen =
                              !_courseSearchTypeMenuOpen;
                          if (_courseSearchTypeMenuOpen) {
                            _courseSearchSubjectMenuOpen = false;
                          }
                        });
                        _courseSearchOverlayEntry?.markNeedsBuild();
                      },
                      onTypeChanged: (collection) {
                        setState(() {
                          _courseSearchCollection = collection;
                          _courseSearchSubject = collection.defaultSubject;
                          _courseSearchTypeMenuOpen = false;
                          _courseSearchSubjectMenuOpen = false;
                        });
                        _courseSearchOverlayEntry?.markNeedsBuild();
                      },
                      onToggleSubjectMenu: () {
                        setState(() {
                          _courseSearchSubjectMenuOpen =
                              !_courseSearchSubjectMenuOpen;
                          if (_courseSearchSubjectMenuOpen) {
                            _courseSearchTypeMenuOpen = false;
                          }
                        });
                        _courseSearchOverlayEntry?.markNeedsBuild();
                      },
                      onSubjectChanged: (subject) {
                        setState(() {
                          _courseSearchSubject = subject;
                          _courseSearchSubjectMenuOpen = false;
                        });
                        _courseSearchOverlayEntry?.markNeedsBuild();
                      },
                      onSavedOnlyChanged: (savedOnly) {
                        setState(() => _courseSearchSavedOnly = savedOnly);
                        _courseSearchOverlayEntry?.markNeedsBuild();
                      },
                      onSearch: _openCourseSearch,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_courseSearchOverlayEntry!);
    _courseSearchOverlayController.forward(from: 0);
  }

  void _hideCourseSearchFilters() {
    if (_courseSearchOverlayEntry == null) {
      if (mounted) {
        setState(() => _courseSearchFiltersOpen = false);
      }
      return;
    }
    _courseSearchOverlayController.reverse().whenComplete(() {
      _removeCourseSearchOverlay();
      if (mounted) {
        setState(() => _courseSearchFiltersOpen = false);
      }
    });
  }

  void _removeCourseSearchOverlay() {
    _courseSearchOverlayEntry?.remove();
    _courseSearchOverlayEntry = null;
  }

  void _openCourseSearch() {
    _removeCourseSearchOverlay();
    _courseSearchOverlayController.value = 0;
    if (mounted) {
      setState(() => _courseSearchFiltersOpen = false);
    }
    final searchController = Get.find<LumiSearchController>();
    searchController.showCourseSearch(
      subject: _effectiveSearchSubject,
      savedOnly: _courseSearchSavedOnly,
    );
    Get.to(
      () => const SearchMain(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final CourseController courseController = Get.find();

    final double horizontalPadding = _getHorizontalPadding(context);
    final double topScrollViewPadding =
        MediaQuery.of(context).padding.top + horizontalPadding;
    const double bottomScrollViewPadding = 40.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= _tabletBreakpoint;

    final TextStyle sectionTitleStyle = isTablet
        ? Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            )
        : const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          );

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
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.0, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: CompositedTransformTarget(
                                link: _courseSearchLayerLink,
                                child: _CourseSearchEntry(
                                  isExpanded: _courseSearchFiltersOpen,
                                  onTap: _toggleCourseSearchFilters,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Feature Cards - Index 1
                          // FadeTransition(
                          //   opacity: CurvedAnimation(
                          //     parent: _animationController,
                          //     curve: const Interval(0.1, 1.0,
                          //         curve: Curves.easeOut),
                          //   ),
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: horizontalPadding),
                          //     child: Container(
                          //       height: 130,
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(20),
                          //         border: Border.all(color: greyBorder),
                          //         gradient: const LinearGradient(
                          //           colors: [
                          //             Color(0x9900012D),
                          //             Color(0x993A005A),
                          //           ],
                          //           begin: Alignment.centerLeft,
                          //           end: Alignment.centerRight,
                          //         ),
                          //       ),
                          //       child: Row(
                          //         children: [
                          // FeatureCard(
                          //   gradientColors: const [],
                          //   icon: Symbols.document_scanner,
                          //   title: 'AI Scanner',
                          //   subtitle: 'Scan & learn instantly',
                          //   onTap: () {
                          //     if (_cameras != null) {
                          //       Get.to(() => AiScannerMain(
                          //           cameras: _cameras!));
                          //     } else {
                          //       Get.snackbar('Camera Error',
                          //           'Cameras not ready yet');
                          //     }
                          //   },
                          // ),
                          // const SizedBox(width: 12),
                          // FeatureCard(
                          //   gradientColors: const [],
                          //   icon: Symbols.note_add,
                          //   title: 'Add Course',
                          //   subtitle: 'Create new course',
                          //   onTap: () {
                          //     Get.to(() => const CourseCreation(),
                          //         transition: Transition.fadeIn,
                          //         duration: const Duration(
                          //             milliseconds: 500));
                          //   },
                          // ),
                          // const SizedBox(width: 12),
                          // FeatureCard(
                          //   gradientColors: const [],
                          //   icon: Symbols.forum,
                          //   title: 'LumiTutor',
                          //   subtitle: 'AI study companion',
                          //   onTap: () {
                          //     Get.to(
                          //       () => const LumiTutorMain(
                          //         initialArgs: {
                          //           'type': 'text',
                          //           'paths': [],
                          //           'category': 'Anything',
                          //         },
                          //       ),
                          //       transition: Transition.fadeIn,
                          //       duration:
                          //           const Duration(milliseconds: 300),
                          //     );
                          //   },
                          // ),
                          // ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          // Suggested Courses Header - Index 2
                          // FadeTransition(
                          //   opacity: CurvedAnimation(
                          //     parent: _animationController,
                          //     curve: const Interval(0.2, 1.0,
                          //         curve: Curves.easeOut),
                          //   ),
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: horizontalPadding),
                          //     child: Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Text(
                          //           'Suggested Courses',
                          //           style: sectionTitleStyle,
                          //         ),
                          //         GestureDetector(
                          //           onTap: () {
                          //             Get.to(
                          //               () => const SearchMain(),
                          //               transition: Transition.fadeIn,
                          //               duration:
                          //                   const Duration(milliseconds: 300),
                          //             );
                          //           },
                          //           child: Row(
                          //             children: [
                          //               Text(
                          //                 'Search',
                          //                 style: sectionTitleStyle.copyWith(
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.w400,
                          //                   color: Colors.white
                          //                       .withValues(alpha: 0.8),
                          //                 ),
                          //               ),
                          //               const SizedBox(width: 4),
                          //               const Icon(Icons.arrow_forward,
                          //                   size: 16, color: Colors.white),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 8),
                          // // Horizontal Category List - Index 3
                          // FadeTransition(
                          //   opacity: CurvedAnimation(
                          //     parent: _animationController,
                          //     curve: const Interval(0.3, 1.0,
                          //         curve: Curves.easeOut),
                          //   ),
                          //   child: HorizontalCategoryList(
                          //       initialPadding: horizontalPadding),
                          // ),
                          // const SizedBox(height: 18),
                          // Flip [_showLumiTutorSection] back on when the tutor
                          // card belongs on the Home surface again.
                          if (_showLumiTutorSection) ...[
                            // LumiTutor Section - Index 4
                            FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.4, 1.0,
                                    curve: Curves.easeOut),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LumiTutor',
                                      style: sectionTitleStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    const LumiTutorCard(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          // AP Courses Card
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.45, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: ApCoursesCard(
                                onBrowseTap: () {
                                  Get.to(
                                    () => const ApCatalogScreen(),
                                    transition: Transition.fadeIn,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Top Picks Header - Index 5
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.5, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Obx(
                                () => TopPicksHeader(
                                  onAddTap: () {
                                    if (courseController
                                        .checkCourseSlotAvailable()) {
                                      Get.to(() => const CourseCreation(),
                                          transition: Transition.fadeIn);
                                    }
                                  },
                                  slotsUsed:
                                      authController.courseSlotsUsed.value,
                                  maxSlots: authController.maxCourseSlots.value,
                                  isPremium: authController.isPremium.value,
                                  titleStyle: sectionTitleStyle,
                                ),
                              ),
                            ),
                          ),
                          // Category List - Index 6
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.6, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: CategoryList(),
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

class _CourseSearchEntry extends StatelessWidget {
  const _CourseSearchEntry({
    required this.isExpanded,
    required this.onTap,
  });

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.72),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppFeatures.publicCourseDiscoveryEnabled
                      ? 'Search courses, topics, or subjects'
                      : 'Search saved courses',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The expanded search surface. Its header is an exact match of
/// [_CourseSearchEntry] so it reads as the *same* component growing in place,
/// while the filter body reveals beneath it on a single continuous surface.
class _CourseSearchExpandedPanel extends StatelessWidget {
  const _CourseSearchExpandedPanel({
    required this.progress,
    required this.collection,
    required this.collections,
    required this.selectedSubject,
    required this.savedOnly,
    required this.typeMenuOpen,
    required this.subjectMenuOpen,
    required this.onClose,
    required this.onToggleTypeMenu,
    required this.onTypeChanged,
    required this.onToggleSubjectMenu,
    required this.onSubjectChanged,
    required this.onSavedOnlyChanged,
    required this.onSearch,
  });

  final double progress;
  final CourseCollection collection;
  final List<CourseCollection> collections;
  final Subject selectedSubject;
  final bool savedOnly;
  final bool typeMenuOpen;
  final bool subjectMenuOpen;
  final VoidCallback onClose;
  final VoidCallback onToggleTypeMenu;
  final ValueChanged<CourseCollection> onTypeChanged;
  final VoidCallback onToggleSubjectMenu;
  final ValueChanged<Subject> onSubjectChanged;
  final ValueChanged<bool> onSavedOnlyChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 18 * progress,
            sigmaY: 18 * progress,
          ),
          child: Container(
            width: double.infinity,
            // Same fill + border as the collapsed search bar so the surface
            // feels like one continuous piece of the component.
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header — pixel-matched to the collapsed bar.
                InkWell(
                  onTap: onClose,
                  child: SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.72),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppFeatures.publicCourseDiscoveryEnabled
                                  ? 'Search courses, topics, or subjects'
                                  : 'Search saved courses',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.62),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Transform.rotate(
                            angle: progress * 3.14159265,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Body — clipped + scaled vertically so it grows out of the
                // header rather than popping in as a detached card.
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: progress,
                    child: Opacity(
                      opacity: progress.clamp(0.0, 1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                // Drop 1 — course type (All Courses / AP Courses).
                                _HomeDropdownButton(
                                  icon: collection.icon,
                                  label: collection.label,
                                  isOpen: typeMenuOpen,
                                  onTap: onToggleTypeMenu,
                                ),
                                _HomeSubjectMenu(
                                  isOpen: typeMenuOpen,
                                  selectedId: collection.id,
                                  subjects: collections
                                      .map((c) => Subject(
                                            id: c.id,
                                            name: c.label,
                                            icon: c.icon,
                                          ))
                                      .toList(),
                                  onSubjectChanged: (subject) => onTypeChanged(
                                    collections
                                        .firstWhere((c) => c.id == subject.id),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Drop 2 — subject, scoped to the chosen type.
                                Row(
                                  children: [
                                    Expanded(
                                      child: _HomeDropdownButton(
                                        icon: selectedSubject.icon,
                                        label: selectedSubject.name,
                                        isOpen: subjectMenuOpen,
                                        onTap: onToggleSubjectMenu,
                                      ),
                                    ),
                                    if (AppFeatures
                                        .publicCourseDiscoveryEnabled) ...[
                                      const SizedBox(width: 10),
                                      _HomeSavedToggle(
                                        isSelected: savedOnly,
                                        onTap: () =>
                                            onSavedOnlyChanged(!savedOnly),
                                      ),
                                    ],
                                  ],
                                ),
                                // Inline subject list — lives inside this same
                                // overlay so it always renders above the panel
                                // and open/close is fully controlled.
                                _HomeSubjectMenu(
                                  isOpen: subjectMenuOpen,
                                  selectedId: selectedSubject.id,
                                  subjects: collection.subjects,
                                  onSubjectChanged: onSubjectChanged,
                                ),
                                const SizedBox(height: 12),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onSearch,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Ink(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            savedOnly ||
                                                    !AppFeatures
                                                        .publicCourseDiscoveryEnabled
                                                ? Icons.bookmark_rounded
                                                : Icons.travel_explore_rounded,
                                            color: Colors.black,
                                            size: 19,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            savedOnly ||
                                                    !AppFeatures
                                                        .publicCourseDiscoveryEnabled
                                                ? 'Search saved courses'
                                                : 'Search courses',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _HomeDropdownButton extends StatelessWidget {
  const _HomeDropdownButton({
    required this.icon,
    required this.label,
    required this.isOpen,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isOpen ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: isOpen ? 0.22 : 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.78),
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.56),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline, animated subject picker rendered inside the search overlay so it is
/// always above the panel and its open/close state is fully controlled.
class _HomeSubjectMenu extends StatelessWidget {
  const _HomeSubjectMenu({
    required this.isOpen,
    required this.selectedId,
    required this.subjects,
    required this.onSubjectChanged,
  });

  final bool isOpen;
  final String selectedId;
  final List<Subject> subjects;
  final ValueChanged<Subject> onSubjectChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !isOpen
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    if (subject.isHeader) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                        child: Text(
                          subject.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      );
                    }
                    final bool selected = subject.id == selectedId;
                    return InkWell(
                      onTap: () => onSubjectChanged(subject),
                      child: Container(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            Icon(
                              subject.icon,
                              color: selected ? Colors.white : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subject.name,
                                style: TextStyle(
                                  color:
                                      selected ? Colors.white : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _HomeSavedToggle extends StatelessWidget {
  const _HomeSavedToggle({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSelected ? Colors.black : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Saved',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
