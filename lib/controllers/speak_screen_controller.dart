import 'package:get/get.dart';

class SpeakController extends GetxController {
  /// Observables for each term's progress
  final blackHoleProgress = 0.45.obs;
  final eventHorizonProgress = 0.2.obs;
  final gravitationalWavesProgress = 0.75.obs;

  /// Example: You could store your question or any other data as well
  // final question = Rxn<Question>();

  /// Example function: simulate a backend API call
  Future<void> fetchDataFromBackend() async {
    try {
      // For demonstration, we just wait 2s. Replace with real API logic.
      await Future.delayed(const Duration(seconds: 2));
      // Suppose we get new progress for 'Event Horizon' from the server
      eventHorizonProgress.value = 0.8;
    } catch (e) {
      // handle error
      print("Error fetching data: $e");
    }
  }

  /// Called when the user starts recording
  void startRecording() {
    print("Recording started from Controller");
    // For example, mark 'Black Holes' as mastered:
    blackHoleProgress.value = 1.0;
  }

  /// Called when the user stops recording
  void stopRecording() {
    print("Recording stopped from Controller");
    // Optionally revert or do some other logic
  }
}
