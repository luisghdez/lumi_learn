import 'package:flutter/material.dart';
import 'dart:async';

class SlideshowScreen extends StatefulWidget {
  final String lessonName;
  final String subject;
  final String fileName;
  final String className;
  final String school;
  final String crn;
  final String professorName;
  final String term;
  final String additionalInfo;

  const SlideshowScreen({
    Key? key,
    required this.lessonName,
    required this.subject,
    required this.fileName,
    required this.className,
    required this.school,
    required this.crn,
    required this.professorName,
    required this.term,
    required this.additionalInfo,
  }) : super(key: key);

  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  final List<String> _imagePaths = [
    'assets/worlds/trees1.png',
    'assets/backgrounds/trees2.png',
    'assets/worlds/trees3.png',
  ];

  final List<String> _lumiFacts = [
    "LUMI helps you learn faster through smart lessons!",
    "LUMI adapts to your learning style for maximum efficiency.",
    "Experience learning like never before with LUMI.",
    "Study smarter, not harder with LUMI."
  ];

  int _currentImageIndex = 0;
  int _currentFactIndex = 0;
  double _progress = 0.0;
  Timer? _imageTimer;
  Timer? _factTimer;
  Timer? _progressTimer;
  Timer? _slideshowTimer;

  @override
  void initState() {
    super.initState();

    // Background image cycle (every 10 seconds)
    _imageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _imagePaths.length;
      });
    });

    // Fact text cycle (every 6 seconds)
    _factTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        _currentFactIndex = (_currentFactIndex + 1) % _lumiFacts.length;
      });
    });

    // Progress bar animation (smoothly updates)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.0167; // (1.0 / 30 seconds)
        }
      });
    });

    // End slideshow after 30 seconds
    _slideshowTimer = Timer(const Duration(seconds: 30), () {
      Navigator.of(context).pop(); // Closes the screen
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _factTimer?.cancel();
    _progressTimer?.cancel();
    _slideshowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Fade Transition
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Container(
              key: ValueKey<int>(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_imagePaths[_currentImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Dark Overlay for Readability
          Container(color: Colors.black.withOpacity(0.3)),

          // Centered Text Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        "Creating\nLesson..",
                        key: ValueKey<int>(_currentImageIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // "Loading" Text
                const Text(
                  "Loading",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 12,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // "Lumi Helps You Learn..." Animated Fact Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _lumiFacts[_currentFactIndex],
                      key: ValueKey<int>(_currentFactIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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
