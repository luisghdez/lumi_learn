import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isNavBarVisible = true.obs;

  void updateIndex(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;

    // When navigating back to home screen from another screen,
    // refetch the courses to show the 5 most recently accessed ones
    if (index == 0 && previousIndex != 0) {
      try {
        final CourseController courseController = Get.find<CourseController>();
        courseController.fetchCoursesForHome();
      } catch (_) {
        // Silently handle error if CourseController is not yet initialized
      }
    }
  }

  void hideNavBar() {
    if (isNavBarVisible.value) {
      isNavBarVisible.value = false;
    }
  }

  void showNavBar() {
    if (!isNavBarVisible.value) {
      isNavBarVisible.value = true;
    }
  }
}
