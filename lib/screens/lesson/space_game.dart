import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpaceGame extends StatefulWidget {
  final String lessonName;
  final String subject;
  final String fileName;

  // Syllabus data
  final String className;
  final String school;
  final String crn;
  final String professorName;
  final String term;
  final String additionalInfo;

  const SpaceGame({
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
  State<SpaceGame> createState() => _SpaceGameState();
}

class _SpaceGameState extends State<SpaceGame> {
  late double screenWidth;
  late double screenHeight;

  // Spaceship position: -1 (left) to +1 (right)
  double shipX = 0;
  final double shipWidth = 100;
  final double shipHeight = 100;

  // Laser positions
  List<Offset> lasers = [];

  // Enemy positions
  List<Offset> enemies = [];
  final Random random = Random();

  late Timer _gameLoopTimer;
  Timer? _spawnTimer;

  @override
  void initState() {
    super.initState();
    // Start spawning enemies
    _spawnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _spawnEnemy();
    });

    // Start the game loop
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _updateGame();
    });
  }

  /// Spawns a new enemy at a random X coordinate at the top
  void _spawnEnemy() {
    if (screenWidth == 0) return;
    final double xPos = random.nextDouble() * (screenWidth - 30);
    enemies.add(Offset(xPos, 0));
    setState(() {});
  }

  /// Moves lasers up, enemies down, checks collisions
  void _updateGame() {
    // Move lasers up
    for (int i = 0; i < lasers.length; i++) {
      lasers[i] = Offset(lasers[i].dx, lasers[i].dy - 10);
    }
    // Remove lasers off-screen
    lasers.removeWhere((laser) => laser.dy < 0);

    // Move enemies down
    for (int i = 0; i < enemies.length; i++) {
      enemies[i] = Offset(enemies[i].dx, enemies[i].dy + 5);
    }
    // Remove enemies off-screen
    enemies.removeWhere((enemy) => enemy.dy > screenHeight);

    // Collision detection
    List<Offset> lasersToRemove = [];
    List<Offset> enemiesToRemove = [];

    for (var laser in lasers) {
      for (var enemy in enemies) {
        // If they are close enough, consider it a hit
        if ((laser.dx - enemy.dx).abs() < 30 && (laser.dy - enemy.dy).abs() < 30) {
          lasersToRemove.add(laser);
          enemiesToRemove.add(enemy);
        }
      }
    }
    // Remove collided lasers and enemies
    lasers.removeWhere((laser) => lasersToRemove.contains(laser));
    enemies.removeWhere((enemy) => enemiesToRemove.contains(enemy));

    setState(() {});
  }

  /// Move the ship horizontally by dragging
  void _moveShip(DragUpdateDetails details) {
    final dx = details.localPosition.dx;
    setState(() {
      // Convert local dx to range -1..1
      shipX = (dx / screenWidth) * 2 - 1;
      if (shipX < -1) shipX = -1;
      if (shipX > 1) shipX = 1;
    });
  }

  /// Fire a laser from the spaceship
  void _fireLaser() {
    final double realX = (shipX + 1) / 2 * (screenWidth - shipWidth);
    final double realY = screenHeight - shipHeight - 20;
    lasers.add(Offset(realX + shipWidth / 2, realY));
    setState(() {});
  }

  @override
  void dispose() {
    _gameLoopTimer.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size on each build
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/yellow.jpg', // your cosmic image
              // /Users/samlop/Desktop/LUMI/lumi_learn/assets/images/milky_way.png
              fit: BoxFit.cover,
            ),
          ),
          // Detect drag for spaceship movement & tap for shooting
          GestureDetector(
            onPanUpdate: _moveShip,
            onTap: _fireLaser,
            child: SafeArea(
              child: Stack(
                children: [
                  // Display some info at the top
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lesson: ${widget.lessonName}', style: const TextStyle(color: Colors.white)),
                        Text('Subject: ${widget.subject}', style: const TextStyle(color: Colors.white)),
                        Text('File: ${widget.fileName}', style: const TextStyle(color: Colors.white)),
                        Text('Class: ${widget.className}', style: const TextStyle(color: Colors.white)),
                        Text('School: ${widget.school}', style: const TextStyle(color: Colors.white)),
                        Text('CRN: ${widget.crn}', style: const TextStyle(color: Colors.white)),
                        Text('Professor: ${widget.professorName}', style: const TextStyle(color: Colors.white)),
                        Text('Term: ${widget.term}', style: const TextStyle(color: Colors.white)),
                        Text('Info: ${widget.additionalInfo}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  // Spaceship at bottom
                  Positioned(
                    bottom: 20,
                    left: (shipX + 1) / 2 * (screenWidth - shipWidth),
                    child: SizedBox(
                      width: shipWidth,
                      height: shipHeight,
                      // Provide your own spaceship asset
                      child: Image.asset('assets/images/spaceship.png'),
                    ),
                  ),

                  // Lasers
                  for (var laser in lasers)
                    Positioned(
                      left: laser.dx,
                      top: laser.dy,
                      child: Container(
                        width: 5,
                        height: 20,
                        color: Colors.red,
                      ),
                    ),

                  // Enemies (asteroids)
                  for (var enemy in enemies)
                    Positioned(
                      left: enemy.dx,
                      top: enemy.dy,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset('assets/images/asteroid.png'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
