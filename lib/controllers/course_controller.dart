import 'package:get/get.dart';

class CourseController extends GetxController {
  // Reactive variable to store the selected lesson index
  RxInt selectedLessonIndex = 0.obs;

  // Method to set the selected lesson index
  void setSelectedLesson(int index) {
    selectedLessonIndex.value = index;
  }
}
