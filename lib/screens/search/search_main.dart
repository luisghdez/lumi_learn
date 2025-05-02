import 'package:flutter/material.dart';
import 'package:get/get.dart';


//controllers
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';

//widgets
import 'package:lumi_learn_app/widgets/app_header.dart'; 
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/widgets/custom_search_bar.dart';
import 'package:lumi_learn_app/widgets/tabs.dart';
import 'package:lumi_learn_app/widgets/glassy_card_image.dart';

class SearchMain extends StatefulWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  State<SearchMain> createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> {
  final RxInt selectedTabIndex = 0.obs;
  final TextEditingController searchController = TextEditingController();
  final AuthController authController = Get.find();
  final ClassController classController = Get.put(ClassController());

  final List<CustomTab> tabs = const [
    CustomTab(label: 'Math', icon: Icons.calculate),
    CustomTab(label: 'Physics', icon: Icons.science),
    CustomTab(label: 'English', icon: Icons.menu_book),
    CustomTab(label: 'Biology', icon: Icons.biotech),
    CustomTab(label: 'Chemistry', icon: Icons.bubble_chart),
    CustomTab(label: 'History', icon: Icons.history_edu),
    CustomTab(label: 'Computer Sci.', icon: Icons.computer),
  ];

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
                HomeHeader(
                  title: 'Explore',
                  streakCount: authController.streakCount.value,
                  xpCount: authController.xpCount.value,
                  isPremium: authController.isPremium.value,
                ),
                const SizedBox(height: 16),
                CustomSearchBar(
                  controller: searchController,
                  hintText: 'Search courses, topics or tags...',
                  onChanged: (query) {
                    // Search logic here
                  },
                ),
                const SizedBox(height: 20),
                CustomTabSelector(
                  tabs: tabs,
                  selectedIndex: selectedTabIndex.value,
                  onTabSelected: (index) {
                    selectedTabIndex.value = index;
                  },
                ),
                const SizedBox(height: 28),
                GlassyCardSideImage(
                  imagePath: 'assets/galaxies/galaxy9.png',
                  courseName: 'Advanced Mathematics 101',
                  description: 'Master calculus and more in this structured, guided program.',
                  tags: ['Calculus', 'UTEP', 'Math'],
                  bookmarkCount: 24,
                  lessonCount: 4,
                  onStartLearning: () {
                    // Navigate to course details
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
