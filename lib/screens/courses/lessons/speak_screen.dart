import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/models/question.dart';

class SpeakScreen extends StatelessWidget {
  SpeakScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

  final Question question;

  @override
  Widget build(BuildContext context) {
    final SpeakController speakController = Get.find<SpeakController>();
    speakController.setTerms(question.options);
    speakController.playIntroAudio();

    print("SpeakScreen: ${question.options}");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 0, 11, 59),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top - 25),

            // Large Circle Contact Avatar
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white30, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/astronaut/thinking.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Obx(() => TypewriterSpeechBubbleMessage(
                  key: ValueKey(speakController.feedbackMessage.value),
                  message: speakController.feedbackMessage.value.isEmpty
                      ? "Hey there! Ready to share what you know about these three terms? Hit 'Record' and explain each one out loud!"
                      : speakController.feedbackMessage.value,
                  speed: const Duration(milliseconds: 50),
                  maxHeight: 100,
                  onFinished: () {
                    // Optionally, do something when typing finishes.
                  },
                )),
            const Spacer(),

            // Wrap each TermMasteryItem in an Obx so it rebuilds when the Rx changes
            Column(
              children: List.generate(question.options.length, (index) {
                return Obx(() => TermMasteryItem(
                      term: question.options[index],
                      progress: speakController.termProgress[index],
                    ));
              }),
            ),

            const SizedBox(height: 16),

            // The Record Button
            Center(
              child: Obx(
                () => RecordButton(
                  onStartRecording: speakController.startListening,
                  onStopRecording: () {
                    speakController.isLoading.value = true;
                    speakController.stopListening();
                  },
                  isLoading: speakController.isLoading.value,
                  // disable if *either* audio is playing or isLoading
                  isDisabled: speakController.isAudioPlaying.value ||
                      speakController.isLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isLoading;

  /// If true, user cannot press
  final bool isDisabled;

  const RecordButton({
    Key? key,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isLoading,
    required this.isDisabled,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  void _toggleRecording() {
    // If disabled, do nothing.
    if (widget.isDisabled) return;

    if (isRecording) {
      widget.onStopRecording();
      setState(() {
        isRecording = false;
      });
    } else {
      setState(() {
        isRecording = true;
      });
      widget.onStartRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Visually fade out if disabled
    final double opacityValue = widget.isDisabled ? 0.5 : 1.0;

    return GestureDetector(
      onTap: _toggleRecording,
      child: Opacity(
        opacity: opacityValue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDisabled
                    ? Colors.grey.withOpacity(0.3)
                    : widget.isLoading
                        ? Colors.white.withOpacity(0.3)
                        : isRecording
                            ? Colors.redAccent.withOpacity(0.5)
                            : Colors.white.withOpacity(0.9),
              ),
              child: widget.isLoading
                  ? const Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(greyBorder),
                          ),
                        ),
                        Icon(
                          Icons.mic_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    )
                  : Icon(
                      isRecording ? Icons.mic_off : Icons.mic_outlined,
                      color: isRecording ? Colors.white : Colors.black87,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isDisabled
                  ? ""
                  : widget.isLoading
                      ? "Loading..."
                      : (isRecording ? "Tap to stop" : "Tap to record"),
              style: const TextStyle(
                color: Color.fromARGB(129, 255, 255, 255),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermMasteryItem extends StatelessWidget {
  final String term;
  final double progress;

  const TermMasteryItem({
    Key? key,
    required this.term,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMastered = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMastered
              ? const Color.fromARGB(99, 255, 217, 0)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(
              isMastered ? Icons.star_border : Icons.psychology,
              color: isMastered
                  ? const Color.fromARGB(255, 181, 154, 0)
                  : Colors.white70,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Term + Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      term,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMastered
                            ? const Color(0x33FFD700)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMastered ? Icons.check : null,
                            size: isMastered ? 16 : 0,
                            color: isMastered
                                ? const Color.fromARGB(255, 181, 154, 0)
                                : Colors.transparent,
                          ),
                          if (isMastered) const SizedBox(width: 4),
                          Text(
                            isMastered ? '' : '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: isMastered
                                  ? const Color(0xFFFFD700)
                                  : const Color.fromARGB(129, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 5,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, animatedProgress, child) {
                        return LinearProgressIndicator(
                          value: animatedProgress,
                          backgroundColor:
                              const Color.fromARGB(113, 158, 158, 158),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMastered
                                ? const Color.fromARGB(255, 225, 191, 0)
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypewriterSpeechBubbleMessage extends StatelessWidget {
  final String message;
  final TextStyle? textStyle;
  final Duration speed;
  final VoidCallback? onFinished;
  final double maxHeight;

  const TypewriterSpeechBubbleMessage({
    Key? key,
    required this.message,
    this.textStyle,
    this.speed = const Duration(milliseconds: 30),
    this.onFinished,
    this.maxHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          reverse: true,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                message,
                textStyle: textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                speed: speed,
                cursor: '',
              ),
            ],
            totalRepeatCount: 1,
            isRepeatingAnimation: false,
            onFinished: onFinished,
          ),
        ),
      ),
    );
  }
}
