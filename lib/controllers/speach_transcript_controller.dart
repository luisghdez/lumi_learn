import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechTranscriptController extends GetxController {
  late stt.SpeechToText _speech;
  RxString transcript = ''.obs;
  RxBool isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    if (!available) {
      print('Speech recognition not available on this device.');
    }
  }

  Future<void> startListening() async {
    transcript.value = '';
    isListening.value = true;
    _speech.listen(
      onResult: (result) {
        transcript.value = result.recognizedWords;
        print('Current transcript: ${result.recognizedWords}');
      },
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "en_US",
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening.value = false;
  }
}
