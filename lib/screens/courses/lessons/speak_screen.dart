import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/application/controllers/talk_lesson_controller.dart';
import 'package:lumi_learn_app/application/models/question.dart';

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key, required this.question});
  final Question question;
  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  late final TalkLessonController _lesson;
  final CourseController _course = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    final speech = Get.find<SpeakController>();
    unawaited(speech.audioPlayer.stop());
    final index = _course.activeLessonIndex.value;
    final lessonId = index >= 0 && index < _course.lessons.length
        ? _course.lessons[index]['id'] as String?
        : null;
    _lesson = TalkLessonController(
        courseId: _course.selectedCourseId.value,
        lessonId: lessonId ?? '',
        tokenProvider: speech.authController.getIdToken);
  }

  @override
  void dispose() {
    _lesson.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF101A30),
              title: const Text('Leave this conversation?',
                  style: TextStyle(color: Colors.white)),
              content: const Text(
                  'Your reviewed topics are saved. You can come back to finish.',
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep talking')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Leave')),
              ],
            ));
    if (leave == true) {
      await _lesson.stop();
      if (mounted) _course.nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _lesson,
        builder: (context, _) {
          final progress = _lesson.progress;
          final topics = progress?.topics ??
              widget.question.flashcards
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => TalkTopicProgress(
                      term: entry.value.term,
                      definition: entry.value.definition,
                      score: 0,
                      attempts: 0,
                      status: entry.key == 0 ? 'active' : 'pending'))
                  .toList();
          final current = progress?.currentTermIndex ?? 0;
          final reviewed = progress?.reviewedCount ?? 0;
          final complete = _lesson.complete;
          final busy = _lesson.starting || _lesson.assessing;
          return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF000000), Color(0xFF000B3B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: SafeArea(
                top: true,
                child: Padding(
                    padding: const EdgeInsets.only(top: 52),
                    child: Center(
                        child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: LayoutBuilder(
                          builder:
                              (context, constraints) => SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 10, 24, 22),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(children: [
                                            const Expanded(
                                                child: Text('Speak to Lumi',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                            TextButton(
                                                onPressed: busy ? null : _skip,
                                                child: const Text('Skip',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.white60))),
                                          ]),
                                          Row(children: [
                                            Expanded(
                                                child: Text(
                                                    complete
                                                        ? 'All ${topics.length} topics reviewed'
                                                        : 'Topic ${current + 1} of ${topics.length}',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF89D4FF),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            Text(
                                                '$reviewed / ${topics.length} reviewed',
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                          ]),
                                          const SizedBox(height: 10),
                                          Row(
                                              children: List.generate(
                                                  topics.length,
                                                  (index) => Expanded(
                                                          child: Padding(
                                                        padding: EdgeInsets.only(
                                                            right: index ==
                                                                    topics.length -
                                                                        1
                                                                ? 0
                                                                : 6),
                                                        child: AnimatedContainer(
                                                            duration: const Duration(milliseconds: 350),
                                                            height: 4,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(6),
                                                                color: topics[index].reviewed
                                                                    ? const Color(0xFF9AF0CD)
                                                                    : index == current
                                                                        ? const Color(0xFF70C9FF)
                                                                        : Colors.white12)),
                                                      )))),
                                          const SizedBox(height: 16),
                                          Center(
                                              child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            width: constraints.maxHeight < 650
                                                ? 86
                                                : 120,
                                            height: constraints.maxHeight < 650
                                                ? 86
                                                : 120,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: _lesson.speaking
                                                        ? const Color(
                                                            0xFF89D4FF)
                                                        : Colors.white24,
                                                    width: 2),
                                                boxShadow: _lesson.speaking
                                                    ? [
                                                        BoxShadow(
                                                            color: const Color(
                                                                    0xFF70C9FF)
                                                                .withValues(
                                                                    alpha: .2),
                                                            blurRadius: 24)
                                                      ]
                                                    : [],
                                                image: const DecorationImage(
                                                    image: AssetImage(
                                                        'assets/astronaut/thinking.png'),
                                                    fit: BoxFit.cover)),
                                          )),
                                          const SizedBox(height: 14),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 76, maxHeight: 150),
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: .06),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: Colors.white12)),
                                            child: SingleChildScrollView(
                                                child: Text(
                                                    _lesson.reply.isNotEmpty
                                                        ? _lesson.reply
                                                        : 'Let’s work through these ${topics.length} topics together. Tap the microphone once, then explain each idea in your own words.',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        height: 1.45))),
                                          ),
                                          const SizedBox(height: 14),
                                          ...topics.asMap().entries.map(
                                              (entry) => _TopicProgressRow(
                                                  topic: entry.value,
                                                  number: entry.key + 1,
                                                  active: !complete &&
                                                      entry.key == current)),
                                          if (_lesson.caption.isNotEmpty)
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                    'You: ${_lesson.caption}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 12,
                                                        height: 1.4))),
                                          const SizedBox(height: 14),
                                          if (_lesson.error != null) ...[
                                            Text(_lesson.error!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Color(0xFFFFC59C),
                                                    fontSize: 13)),
                                            if (_lesson.canRetryTurn)
                                              TextButton(
                                                  onPressed: busy
                                                      ? null
                                                      : _lesson.retryTurn,
                                                  child: const Text('Retry')),
                                            const SizedBox(height: 8),
                                          ],
                                          if (complete)
                                            FilledButton(
                                              onPressed: _lesson.connected ||
                                                      busy
                                                  ? null
                                                  : () =>
                                                      _course.nextQuestion(),
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF9AF0CD),
                                                  foregroundColor:
                                                      const Color(0xFF071626),
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          48)),
                                              child: Text(_lesson.connected
                                                  ? 'Finishing with Lumi…'
                                                  : 'Continue'),
                                            )
                                          else
                                            Center(
                                                child: Column(children: [
                                              Semantics(
                                                button: true,
                                                label: _lesson.connected
                                                    ? (_lesson.speaking
                                                        ? 'Interrupt Lumi'
                                                        : _lesson.paused
                                                            ? 'Resume microphone'
                                                            : 'Pause microphone')
                                                    : 'Start speaking to Lumi',
                                                child: SizedBox(
                                                    width: 72,
                                                    height: 72,
                                                    child: FilledButton(
                                                      style: FilledButton.styleFrom(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          shape:
                                                              const CircleBorder(),
                                                          backgroundColor:
                                                              _lesson.connected
                                                                  ? const Color(
                                                                      0xFF85D2FF)
                                                                  : Colors
                                                                      .white,
                                                          foregroundColor:
                                                              const Color(
                                                                  0xFF091D37)),
                                                      onPressed: busy
                                                          ? null
                                                          : _lesson.connected
                                                              ? (_lesson
                                                                      .speaking
                                                                  ? _lesson
                                                                      .interrupt
                                                                  : _lesson
                                                                      .toggleMicrophone)
                                                              : _lesson.start,
                                                      child: busy
                                                          ? const SizedBox(
                                                              width: 26,
                                                              height: 26,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2))
                                                          : Icon(
                                                              _lesson.paused
                                                                  ? Icons
                                                                      .mic_off_rounded
                                                                  : Icons
                                                                      .mic_rounded,
                                                              size: 30),
                                                    )),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(_lesson.status,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 13)),
                                              if (!_lesson.connected && !busy)
                                                const Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 4),
                                                    child: Text(
                                                        'No stop button needed between answers',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white38,
                                                            fontSize: 11))),
                                              if (_lesson.connected)
                                                TextButton(
                                                    onPressed: busy
                                                        ? null
                                                        : _lesson.stop,
                                                    child: const Text(
                                                        'End session',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white38,
                                                            fontSize: 12))),
                                            ])),
                                        ]),
                                  )),
                    )))),
          );
        },
      );
}

class _TopicProgressRow extends StatelessWidget {
  const _TopicProgressRow(
      {required this.topic, required this.number, required this.active});
  final TalkTopicProgress topic;
  final int number;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final color = topic.status == 'mastered'
        ? const Color(0xFF9AF0CD)
        : active
            ? const Color(0xFF89D4FF)
            : Colors.white54;
    final label = topic.status == 'mastered'
        ? 'Mastered'
        : topic.status == 'review_later'
            ? 'Review later'
            : active
                ? 'Current topic'
                : 'Up next';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: active
              ? const Color(0xFF122941)
              : Colors.white.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? const Color(0xFF427C9E) : Colors.white10)),
      child: Row(children: [
        SizedBox(
            width: 26,
            child: topic.reviewed
                ? Icon(
                    topic.status == 'mastered'
                        ? Icons.check_circle_outline
                        : Icons.bookmark_border,
                    color: color,
                    size: 20)
                : Text('$number',
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(topic.term,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color:
                      active || topic.reviewed ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
                child:
                    Text(label, style: TextStyle(color: color, fontSize: 10))),
            Text('${topic.score}%',
                style: TextStyle(color: color, fontSize: 11))
          ]),
          const SizedBox(height: 5),
          TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 450),
              tween: Tween(begin: 0, end: topic.score / 100),
              builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: value,
                      minHeight: 3,
                      backgroundColor: Colors.white10,
                      color: color))),
        ])),
      ]),
    );
  }
}
