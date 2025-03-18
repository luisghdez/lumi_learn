import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class SpeakController extends GetxController {
  final List<String> terms;
  // Track progress by index: each term has its progress stored in a list.
  final RxList<double> termProgress = <double>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();

  SpeakController({required this.terms}) {
    // Initialize the list with a default value (0.0) for each term.
    termProgress.assignAll(List<double>.filled(terms.length, 0.0));

    // For our expected 3 terms, set custom initial values.
    termProgress[0] = 0.0;
    termProgress[1] = 0.0;
    termProgress[2] = 0.0;

    print(
        "SpeakController initialized with terms: $terms and progress: $termProgress");
  }

  @override
  void onInit() {
    super.onInit();
    playIntroAudio();
  }

  /// Plays the introductory audio.
  Future<void> playIntroAudio() async {
    // Assumes your mark_intro.mp3 is in your assets folder and declared in pubspec.yaml
    await audioPlayer.play(AssetSource("sounds/mark_intro2.mp3"));
  }

  /// When recording starts, simulate marking the first term as mastered.
  void startRecording() {
    if (termProgress.isNotEmpty) {
      termProgress[0] = 1.0;
    }
    print("Recording started, term at index 0 mastered");
  }

  void stopRecording() {
    print("Recording stopped");
  }

  /// Example method to simulate a backend update.
  Future<void> fetchDataFromBackend() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      // if (terms.length > 1) {
      //   termProgress[1] = 0.8;
      // }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
}
