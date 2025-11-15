import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/screens/aiScanner/ai_scanner_main.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/home/components/feature_card.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_list.dart';
import 'package:lumi_learn_app/screens/home/components/lumi_tutor_card.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:lumi_learn_app/screens/lumiTutor/lumi_tutor_main.dart';

import 'components/category_list.dart';
import 'components/top_picks_header.dart';
import 'components/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const double _tabletBreakpoint = 800.0;
  List<CameraDescription>? _cameras;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Trigger animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final CourseController courseController = Get.find();
    final NavigationController navigationController = Get.find();

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
                          // Header - Index 0
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.0, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Obx(() => HomeHeader(
                                    streakCount:
                                        authController.streakCount.value,
                                    xpCount: authController.xpCount.value,
                                    isPremium: authController.isPremium.value,
                                  )),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Feature Cards - Index 1
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.1, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Container(
                                height: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: greyBorder),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x9900012D),
                                      Color(0x993A005A),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    FeatureCard(
                                      gradientColors: const [],
                                      icon: Symbols.document_scanner,
                                      title: 'AI Scanner',
                                      subtitle: 'Scan & learn instantly',
                                      onTap: () {
                                        if (_cameras != null) {
                                          Get.to(() => AiScannerMain(
                                              cameras: _cameras!));
                                        } else {
                                          Get.snackbar('Camera Error',
                                              'Cameras not ready yet');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    FeatureCard(
                                      gradientColors: const [],
                                      icon: Symbols.note_add,
                                      title: 'Add Course',
                                      subtitle: 'Create new course',
                                      onTap: () {
                                        Get.to(() => const CourseCreation(),
                                            transition: Transition.fadeIn,
                                            duration: const Duration(
                                                milliseconds: 500));
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    FeatureCard(
                                      gradientColors: const [],
                                      icon: Symbols.forum,
                                      title: 'LumiTutor',
                                      subtitle: 'AI study companion',
                                      onTap: () {
                                        Get.to(
                                          () => const LumiTutorMain(
                                            initialArgs: {
                                              'type': 'text',
                                              'paths': [],
                                              'category': 'Anything',
                                            },
                                          ),
                                          transition: Transition.fadeIn,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Suggested Courses Header - Index 2
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Suggested Courses',
                                    style: sectionTitleStyle,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      navigationController.updateIndex(1);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Search',
                                          style: sectionTitleStyle.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward,
                                            size: 16, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Horizontal Category List - Index 3
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.3, 1.0,
                                  curve: Curves.easeOut),
                            ),
                            child: HorizontalCategoryList(
                                initialPadding: horizontalPadding),
                          ),
                          const SizedBox(height: 18),
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
