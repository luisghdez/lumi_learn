import 'package:get/get.dart';
import 'package:vibra_app/data/assets_data.dart'; // Import the data file

class CourseController extends GetxController {
  // Reactive variable to store the active planet
  var activePlanet = Rxn<Planet>();

  // Method to set the active planet
  void setActivePlanet(int index) {
    activePlanet.value = planets[index];
  }
}
