import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int startSeconds;
  final VoidCallback onComplete;

  const CountdownTimer({
    Key? key,
    this.startSeconds = 60,
    required this.onComplete,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.startSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _secondsRemaining / widget.startSeconds;

    return SizedBox(
      width: 100, // Increased overall size
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Enlarged Circular Progress Bar
          Transform.scale(
            scale: 2.5, // Makes the progress indicator circle bigger
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 2, // Increased stroke width for a bolder circle
                  backgroundColor: Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),

          // Countdown Text (Centered)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 0,
            children: [
              Text(
                '$_secondsRemaining',
                style: const TextStyle(
                  fontSize: 36, // Adjusted font size to match the bigger circle
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8), // Moves "sec" up
                child: const Text(
                  'sec',
                  style: TextStyle(
                    fontSize: 12, // Smaller text
                    height: 0.8, // Reduce default height
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
