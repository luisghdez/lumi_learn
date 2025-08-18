import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/application/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/flash_card_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/lesson_screen_main.dart';
import 'package:lumi_learn_app/screens/courses/lessons/note_screen.dart';
import 'package:lumi_learn_app/screens/lumiTutor/lumi_tutor_main.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_panel.dart';
import 'package:lumi_learn_app/widgets/course_overview_header.dart';
import 'package:lumi_learn_app/widgets/star_painter.dart';
import 'package:lumi_learn_app/widgets/starry_app_scaffold.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart'; // <--- Import your AuthController
import 'package:lumi_learn_app/widgets/rocket_animation.dart';
import 'package:lumi_learn_app/widgets/embeddings_popup.dart';

const exampleMarkdown = """
# Unlocking International Business: A Student’s Guide to Key Terms 🌎\n\nReady to understand the risks, strategies, and incentives involved with investing abroad? Let’s break down these essential concepts—no confusing jargon, just clear explanations.\n\n---\n\n## 1. Understanding the Risks\n\n### **Country Risk**\n*The big-picture risk that comes with investing in or lending to a foreign country.*  \n- Can include political, economic, or social problems\n- Example: Sudden economic collapse or government changes\n\n### **Political Risk**\n*Risks specifically caused by government actions or instability.*  \n- Can lead to laws that hurt foreign businesses\n\n**Relationship:**  \n*Political risk is a form of country risk.*\n\n---\n\n## 2. How Host Governments Affect Investment\n\n### **Attitude of Host Government**\n*How welcoming or hostile a country is to foreign investors.*\n- Supportive governments help businesses thrive; hostile ones create obstacles\n\n### **Host Government Incentives for DFI**\n*Perks a country offers to attract foreign investors.*\n- Can include tax breaks, land, subsidies\n\n### **Host Government Barriers to DFI**\n*Rules or actions that make investing harder.*\n- High taxes, quotas, licensing, or outright bans\n\n---\n\n## 3. Common Political/Economic Challenges\n\n| Term                       | Meaning                                                                           |\n|----------------------------|-----------------------------------------------------------------------------------|\n| Blockage of fund transfers | Not being able to send profits/money out of the host country                      |\n| Currency inconvertibility  | Unable to exchange local currency for another; hard to repatriate funds           |\n| War and internal conflict  | Armed conflict or unrest disrupts business                                        |\n| Corruption                 | Bribery or dishonest practices; can raise costs or cause unfair treatment         |\n| Bureaucracy                | Slow and complicated government procedures; delaying business decisions           |\n| Political Instability Risk | The chance that sudden political changes will hurt business interests             |\n\n**Connections:**  \n- War, corruption, and bureaucracy are major factors in country and political risk.\n\n---\n\n## 4. Direct Foreign Investment (DFI) & Motivations\n\n### **Direct Foreign Investment (DFI)**\n*When a business from one country builds or buys operations in another country (like a factory, office, or company).*\n\n### **Forms of DFI**\n- **Joint Venture:** Partnering with a local firm\n- **Acquisition:** Buying a local company\n- **New Facilities:** Building from scratch (\"greenfield investment\")\n\n### **Why Do Companies Invest Abroad?**\n#### **Revenue-related Motives for DFI**\n- Enter new markets to sell more products\n- Get closer to customers\n- Bypass trade barriers\n\n#### **Cost-related Motives for DFI**\n- Find cheaper labor/materials\n- Benefit from economies of scale\n- Lower taxes\n\n#### **Exchange Rate Motives for DFI**\n- Invest where currency value may increase, boosting profits when converted back home\n\n#### **International Diversification**\n- Spreading investments across countries to reduce overall risk\n\n#### **Portfolio Variance**\n- A measure of how much the return on an investment might change; diversification lowers variance and risk\n\n---\n\n## 5. Making & Measuring Investment Decisions\n\n### **FDI Confidence Index**\n*A global survey ranking countries by how attractive they are to foreign investors.*\n- Considers economic outlook, stability, policies\n\n---\n\n## 6. See How It All Connects\n\n```mermaid\ngraph TD\n    DFI -- can be blocked by --> CountryRisk\n    CountryRisk -- includes --> PoliticalRisk\n    PoliticalRisk -- is raised by --> PoliticalInstabilityRisk\n    PoliticalRisk -- increases --> BlockageOfFundTransfers\n    PoliticalRisk -- increases --> CurrencyInconvertibility\n    DFI -- motivated by --> RevenueMotives\n    DFI -- motivated by --> CostMotives\n    DFI -- motivated by --> ExchangeRateMotives\n    DFI -- improves --> InternationalDiversification\n    InternationalDiversification -- reduces --> PortfolioVariance\n    HostGovAttitude -- can give --> Incentives\n    HostGovAttitude -- can create --> Barriers\n    Corruption -- increases --> PoliticalRisk\n    Bureaucracy -- increases --> CountryRisk\n```\n\n---\n\n## 7. Key Takeaways\n\n- **Country & political risks** can spoil foreign investment plans.\n- **Host governments** can attract or discourage investors through incentives or barriers.\n- **DFI** helps companies grow, lower costs, and spread risk, but brings challenges like currency issues and instability.\n- **Diversification** is important: it lowers risk in the investment portfolio.\n- The **FDI Confidence Index** helps investors spot safer, more promising locations.\n\n**Keep thinking:**  \nHow would a company decide where to invest next? What’s riskier—expanding into a new country, or missing out on its market?\n\n---
""";

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.find();
  final AuthController authController =
      Get.find(); // <--- Grab the AuthController here

  final ScrollController _scrollController = ScrollController();

  bool _isPanelVisible = false;
  int? _selectedLessonIndex;
  String? _selectedLessonPlanetName;
  String? _lessonDescription;

  // Track which planet to highlight (when user taps a locked planet)
  int? _highlightedPlanetIndex;

  // Key to detect taps outside the panel
  final GlobalKey _panelKey = GlobalKey();
  final StarPainter _starPainter = StarPainter(starCount: 200);

  // Capturing each lesson’s center (for planet positioning)
  final List<Offset> _lessonCenters = [];

  double _glowOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Schedule the auto-scroll after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lessons = courseController.lessons;
      int lastCompletedIndex = -1;
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i]['completed'] == true) {
          lastCompletedIndex = i;
        }
      }
      int nextLessonIndex = lastCompletedIndex + 1;

      // Only auto-scroll if we're past the first lesson.
      if (nextLessonIndex == 0) return;

      // Define the planet size as used in your layout.
      const double planetSize = 100.0;

      // Calculate the center of the next lesson planet.
      double planetCenterX = nextLessonIndex * 200.0 + planetSize / 2;
      double screenWidth = MediaQuery.of(context).size.width;

      // Adjust the target offset so that the planet's center is aligned in the middle.
      double targetOffset = planetCenterX - screenWidth / 2;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;

    // Horizontal wave layout parameters (optional for the “orbit” effect)
    const double amplitude = 180.0;
    const double frequency = pi / 3;

    // Clear & recalculate lesson centers each build
    _lessonCenters.clear();

    return Obx(() {
      final courseId = courseController.selectedCourseId;
      final lessons = courseController.lessons;
      final lessonCount = lessons.length;
      final totalWidth = lessonCount * 200.0; // Space out lessons horizontally
      int completedCount = lessons.where((l) => l['completed'] == true).length;
      double progress = (lessonCount == 0) ? 0 : completedCount / lessonCount;

      Planet? previousPlanet;

      // Find the last completed lesson index
      int lastCompletedIndex = -1;
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i]['completed'] == true) {
          lastCompletedIndex = i;
        }
      }
      // The next lesson is right after the last completed
      int nextLessonIndex = lastCompletedIndex + 1;

      // Convert raw flashcards to Flashcard models
      final flashcards = courseController.flashcards
          .map((item) => Flashcard.fromMap(item))
          .toList();

      return StarryAppScaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) => _handleTapDown(context, details),
          child: Stack(
            children: [
              // 1) Scrollable horizontal region
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  height: screenHeight,
                  child: Stack(
                    children: [
                      // Background stars
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _starPainter,
                        ),
                      ),

                      // 2) Lessons as “Planets”
                      ...List.generate(lessonCount, (index) {
                        final lesson = lessons[index];
                        final bool shouldBlur = index > nextLessonIndex;

                        final lessonPlanetName = lesson['planetName'];
                        final lessonTitle =
                            lesson['title'] ?? 'Lesson ${index + 1}';
                        final lessonId = lesson['id']; // Unique lesson ID

                        // Assign a planet image based on the lesson
                        final lessonPlanet = getPlanetForLesson(
                          courseId.value,
                          lessonId,
                          previousPlanet,
                        );
                        previousPlanet = lessonPlanet;

                        // Wave offset for a fun orbit effect
                        final offsetY =
                            amplitude * sin(index * frequency + pi / 2);
                        final planetLeft = index * 200.0;
                        final planetTop = screenHeight / 2 - offsetY - 60;
                        const planetSize = 100.0;

                        // Save the center of each planet for rocket animation
                        final lessonCenter = Offset(
                          planetLeft + planetSize / 2,
                          planetTop + planetSize / 2,
                        );
                        _lessonCenters.add(lessonCenter);

                        const double flagSize = 30.0;

                        return Positioned(
                          left: planetLeft,
                          top: planetTop,
                          child: GestureDetector(
                            onTap: () => _onLessonTap(index, lessonPlanet),
                            child: SizedBox(
                              width: planetSize,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipOval(
                                            child: Image.asset(
                                              lessonPlanet.imagePath,
                                              width: planetSize,
                                              height: planetSize,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          // If the lesson is completed, show a flag.
                                          if (lesson['completed'] == true)
                                            Positioned(
                                              top: lessonPlanet.hasRings
                                                  ? -2
                                                  : -12,
                                              left:
                                                  (planetSize - flagSize) / 2 +
                                                      6,
                                              child: Image.asset(
                                                'assets/astronaut/flag.png',
                                                width: flagSize,
                                                height: flagSize,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        lessonPlanetName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          height: 0.9,
                                        ),
                                      ),
                                      Text(
                                        lessonTitle,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Lock & blur for future lessons
                                  if (shouldBlur)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: planetSize,
                                        height: planetSize,
                                        child: Stack(
                                          children: [
                                            // Blur overlay
                                            ClipOval(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 4.0,
                                                  sigmaY: 4.0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: greyBorder,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Lock icon
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Gray lock (base)
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Color.fromARGB(
                                                        255, 158, 158, 158),
                                                    size: 24,
                                                  ),
                                                  // White lock that fades in/out using _glowOpacity
                                                  AnimatedOpacity(
                                                    opacity:
                                                        (_highlightedPlanetIndex ==
                                                                index)
                                                            ? _glowOpacity
                                                            : 0.0,
                                                    duration: const Duration(
                                                        milliseconds: 0),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Animated glowing border (fades in then out)
                                            if (_highlightedPlanetIndex ==
                                                index)
                                              AnimatedOpacity(
                                                opacity: _glowOpacity,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        blurRadius: 12,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // 3) Rocket Animation
                      Positioned.fill(
                        child: _selectedLessonIndex == null
                            ? const SizedBox()
                            : RocketAnimation(
                                planetCenter:
                                    _lessonCenters[_selectedLessonIndex!],
                                planetRadius: 20.0,
                                isActive: _isPanelVisible,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4) Bottom Panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isPanelVisible ? 0 : -250,
                left: 0,
                right: 0,
                child: BottomPanel(
                  key: _panelKey,
                  selectedLessonIndex: _selectedLessonIndex,
                  selectedLessonPlanetName: _selectedLessonPlanetName,
                  selectedLessonDescription: _lessonDescription,
                  onStartPressed: () {
                    courseController.loadQuestions();
                    Get.to(() => LessonScreenMain());
                    _closePanel();
                  },
                  onClose: _closePanel,
                ),
              ),

              // 5) Top Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16,
                  vertical: isTablet ? 32 : 0,
                ),
                child: CourseOverviewHeader(
                  onBack: () => Get.offAll(
                    () => MainScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 1000),
                  ),
                  courseTitle: "${courseController.selectedCourseTitle}",
                  progress: progress,
                  onViewFlashcards: () {
                    Get.to(
                      () => FlashcardScreen(flashcards: flashcards),
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  onViewNotes: () {
                    if (!courseController.selectedCourseHasEmbeddings.value) {
                      Get.dialog(
                        const EmbeddingsPopup(),
                        barrierDismissible: true,
                      );
                      return;
                    }
                    Get.to(
                      () => const NoteScreen(
                        markdownText: exampleMarkdown,
                      ),
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  onViewLumiTutor: () {
                    if (!courseController.selectedCourseHasEmbeddings.value) {
                      Get.dialog(
                        const EmbeddingsPopup(),
                        barrierDismissible: true,
                      );
                      return;
                    }
                    Get.to(
                      // send with chat id
                      () => LumiTutorMain(courseId: courseId.value),
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Planet getPlanetForLesson(
    String courseId,
    String lessonId, [
    Planet? previousPlanet,
  ]) {
    // Combine course ID + lesson ID for a unique hash
    final combinedId = courseId + lessonId;
    final bytes = utf8.encode(combinedId);
    final hash = md5.convert(bytes).toString();

    // Convert part of the hash to a number, pick a planet from the list
    final numericHash = int.parse(hash.substring(0, 6), radix: 16);
    int planetIndex = numericHash % planets.length;
    Planet chosenPlanet = planets[planetIndex];

    // If the chosen planet is the same as the previous one, pick the next
    if (previousPlanet != null &&
        chosenPlanet.imagePath == previousPlanet.imagePath) {
      planetIndex = (planetIndex + 1) % planets.length;
      chosenPlanet = planets[planetIndex];
    }
    return chosenPlanet;
  }

  // **Handling Lesson Taps**
  void _onLessonTap(int index, Planet planet) {
    final lessons = courseController.lessons;
    final isPremium = authController.isPremium.value;

    // Count total lessons
    final lessonCount = lessons.length;

    // Find the last completed lesson index
    int lastCompletedIndex = -1;
    for (int i = 0; i < lessons.length; i++) {
      if (lessons[i]['completed'] == true) {
        lastCompletedIndex = i;
      }
    }
    final nextLessonIndex = lastCompletedIndex + 1;

    // 1) If this lesson is locked (index > nextLessonIndex), show glow + snackbar
    if (index > nextLessonIndex) {
      setState(() {
        _highlightedPlanetIndex = index;
        _glowOpacity = 1.0; // Start with fully visible glow (fade in)
      });

      Get.snackbar(
        "Locked!",
        "Complete previous lessons to start this lesson!",
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: const Color.fromARGB(140, 0, 0, 0),
        colorText: Colors.white,
        borderColor: Colors.white.withOpacity(0.2),
        borderWidth: 1,
        borderRadius: 30.0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
        margin: const EdgeInsets.all(10.0),
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _highlightedPlanetIndex == index) {
          setState(() => _glowOpacity = 0.0);
        }
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _highlightedPlanetIndex == index) {
          setState(() => _highlightedPlanetIndex = null);
        }
      });
      return;
    }

    // 2) If user is NOT premium, block from:
    //    - 3rd lesson (index=2) onward if course has <= 4 lessons
    //    - 4th lesson (index=3) onward if course has > 4 lessons
    if (!isPremium) {
      if (lessonCount <= 4 && index >= 2) {
        // Non-premium block for "small" course
        courseController.showUpgradePopup(
          title: "Discover all planets with premium!",
          subtitle: "Upgrade to Lumi Premium for unlimited courses.",
        );
        return;
      } else if (lessonCount > 4 && index >= 3) {
        // Non-premium block for "larger" course
        courseController.showUpgradePopup(
          title: "Discover all planets with premium!",
          subtitle: "Upgrade to Lumi Premium for unlimited courses.",
        );
        return;
      }
    }

    // 3) For unlocked & allowed lessons, open the bottom panel (or re-open if switching lessons)
    if (_selectedLessonIndex == index && _isPanelVisible) {
      // If user taps the same planet while panel is open, ignore
      return;
    }

    // Close any open panel (also close any snackbars)
    setState(() {
      Get.closeAllSnackbars();
      _isPanelVisible = false;
      _highlightedPlanetIndex = null;
    });

    // Delay to let rocket animate away
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _selectedLessonIndex = index;
        _selectedLessonPlanetName = lessons[index]['planetName'];
        _lessonDescription = lessons[index]['planetDescription'];
        _isPanelVisible = true;
      });
      // Also update the CourseController’s active lesson & planet
      courseController.setActiveLessonIndex(index);
      courseController.setActivePlanet(planet);
    });
  }

  // **Close the bottom panel when tapping outside, also remove highlight**
  void _handleTapDown(BuildContext context, TapDownDetails details) {
    // Close any snackbars
    Get.closeAllSnackbars();

    setState(() {
      _highlightedPlanetIndex = null;
    });

    if (!_isPanelVisible) return;

    final tapPosition = details.globalPosition;
    if (_panelKey.currentContext != null) {
      final renderBox =
          _panelKey.currentContext!.findRenderObject() as RenderBox;
      final panelOffset = renderBox.localToGlobal(Offset.zero);
      final panelSize = renderBox.size;
      final panelRect = Rect.fromLTWH(
        panelOffset.dx,
        panelOffset.dy,
        panelSize.width,
        panelSize.height,
      );
      if (!panelRect.contains(tapPosition)) {
        _closePanel();
      }
    }
  }

  // **Hides the panel & rocket animation**
  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
      _highlightedPlanetIndex = null;
    });
  }
}
