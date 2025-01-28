import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Reactive variable for currentIndex
  var currentIndex = 0.obs; // .obs makes it observable

  // Method to update the index
  void updateIndex(int newIndex) {
    if (newIndex != currentIndex.value) {
      currentIndex.value = newIndex;
    }
  }
}
