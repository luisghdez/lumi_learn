import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isNavBarVisible = true.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
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
