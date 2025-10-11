import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Explosion {
  final Offset position;
  final DateTime startTime;
  Explosion({required this.position, required this.startTime});
}

class SpaceGame extends StatefulWidget {
  final String lessonName;
  final String subject;
  final String fileName;

  // Syllabus data.
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

  // Spaceship properties.
  late Offset shipPosition; // Base position controlled by joystick.
  final double shipWidth = 100;
  final double shipHeight = 100;
  double shipSpeed = 300; // pixels per second.
  bool _shipInitialized = false;

  // Virtual Joystick state.
  Offset joystickDirection = Offset.zero;
  bool _isJoystickActive = false;

  // Health.
  double maxHealth = 100;
  double currentHealth = 100;

  // Weapons lists.
  List<Offset> lasers = [];
  List<Offset> powerShots = [];
  List<Offset> missiles = [];

  // Enemies and explosions.
  List<Offset> enemies = [];
  List<Explosion> explosions = [];

  // Game state.
  int score = 0;
  int level = 1;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _hasGameStarted = false;

  // Speeds and timers for enemies.
  double enemySpeed = 5;
  Duration spawnInterval = const Duration(milliseconds: 800);
  Timer? _gameLoopTimer;
  Timer? _spawnTimer;

  final Random random = Random();

  // Audio players.
  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;

  @override
  void initState() {
    super.initState();
    // Initialize audio.
    _audioPlayer = AudioPlayer();
    _audioCache = AudioCache(prefix: 'assets/sounds/');
    // Note: We now wait for the user to press "Start Game" rather than auto-start.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // Define barrier position: ship cannot move below this line.
    double barrierY = screenHeight - 200; // Moved more up.
    if (!_shipInitialized) {
      // Start the ship 50 pixels above the lowest allowed position.
      shipPosition =
          Offset(screenWidth / 2 - shipWidth / 2, barrierY - shipHeight - 50);
      _shipInitialized = true;
    }
  }

  void _startSpawning() {
    _spawnTimer = Timer.periodic(spawnInterval, (timer) {
      if (!_isPaused && !_isGameOver && mounted) {
        _spawnEnemy();
      }
    });
  }

  void _stopSpawning() {
    _spawnTimer?.cancel();
  }

  void _restartSpawning() {
    _stopSpawning();
    _startSpawning();
  }

  void _spawnEnemy() {
    if (screenWidth == 0) return;
    final double enemySize = 60;
    final double xPos = random.nextDouble() * (screenWidth - enemySize);
    enemies.add(Offset(xPos, 0));
  }

  void _updateGame() {
    final double deltaTime = 0.03; // 30ms per frame.

    // Update ship movement via joystick.
    if (_isJoystickActive && joystickDirection != Offset.zero) {
      final Offset movement = joystickDirection * shipSpeed * deltaTime;
      _moveShip(movement);
    }

    // Update weapons.
    for (int i = 0; i < lasers.length; i++) {
      lasers[i] = Offset(lasers[i].dx, lasers[i].dy - 15);
    }
    lasers.removeWhere((laser) => laser.dy < 0);

    for (int i = 0; i < powerShots.length; i++) {
      powerShots[i] = Offset(powerShots[i].dx, powerShots[i].dy - 20);
    }
    powerShots.removeWhere((shot) => shot.dy < 0);

    for (int i = 0; i < missiles.length; i++) {
      missiles[i] = Offset(missiles[i].dx, missiles[i].dy - 8);
    }
    missiles.removeWhere((missile) => missile.dy < 0);

    // Update enemies.
    for (int i = 0; i < enemies.length; i++) {
      enemies[i] = Offset(enemies[i].dx, enemies[i].dy + enemySpeed);
    }
    enemies.removeWhere((enemy) => enemy.dy > screenHeight);

    // Collision detection for weapons.
    List<Offset> removeLasers = [];
    List<Offset> removePowerShots = [];
    List<Offset> removeMissiles = [];
    List<Offset> removeEnemies = [];

    for (var laser in lasers) {
      for (var enemy in enemies) {
        if ((laser.dx - enemy.dx).abs() < 40 &&
            (laser.dy - enemy.dy).abs() < 40) {
          removeLasers.add(laser);
          removeEnemies.add(enemy);
          explosions.add(Explosion(position: enemy, startTime: DateTime.now()));
          score++;
          _audioCache.play('hit.mp3');
        }
      }
    }
    for (var shot in powerShots) {
      for (var enemy in enemies) {
        if ((shot.dx - enemy.dx).abs() < 50 &&
            (shot.dy - enemy.dy).abs() < 50) {
          removePowerShots.add(shot);
          removeEnemies.add(enemy);
          explosions.add(Explosion(position: enemy, startTime: DateTime.now()));
          score += 2;
          _audioCache.play('hit.mp3');
        }
      }
    }
    for (var missile in missiles) {
      for (var enemy in enemies) {
        if ((missile.dx - enemy.dx).abs() < 60 &&
            (missile.dy - enemy.dy).abs() < 60) {
          removeMissiles.add(missile);
          removeEnemies.add(enemy);
          explosions.add(Explosion(position: enemy, startTime: DateTime.now()));
          score += 3;
          _audioCache.play('hit.mp3');
        }
      }
    }
    lasers.removeWhere((laser) => removeLasers.contains(laser));
    powerShots.removeWhere((shot) => removePowerShots.contains(shot));
    missiles.removeWhere((missile) => removeMissiles.contains(missile));
    enemies.removeWhere((enemy) => removeEnemies.contains(enemy));

    // Collision between enemies and spaceship.
    Rect shipRect =
        Rect.fromLTWH(shipPosition.dx, shipPosition.dy, shipWidth, shipHeight);
    List<Offset> enemiesHit = [];
    for (var enemy in enemies) {
      Rect enemyRect = Rect.fromLTWH(enemy.dx, enemy.dy, 60, 60);
      if (shipRect.overlaps(enemyRect)) {
        enemiesHit.add(enemy);
        explosions.add(Explosion(position: enemy, startTime: DateTime.now()));
        currentHealth -= 10;
        HapticFeedback.mediumImpact();
        _audioCache.play('hit.mp3');
      }
    }
    enemies.removeWhere((enemy) => enemiesHit.contains(enemy));

    // Level and difficulty scaling.
    int newLevel = (score ~/ 10) + 1;
    if (newLevel > level) {
      level = newLevel;
      enemySpeed = 5 + level.toDouble();
      spawnInterval = Duration(milliseconds: max(500, 1000 - level * 50));
      _restartSpawning();
      // Optionally trigger level-up sound.
      _audioCache.play('power_shot.mp3');
    }

    // Remove old explosions.
    explosions.removeWhere((explosion) =>
        DateTime.now().difference(explosion.startTime) >
        const Duration(milliseconds: 500));

    // Check for Game Over.
    if (currentHealth <= 0) {
      _isPaused = true;
      _stopGame();
      _isGameOver = true;
      _audioCache.play('game_over.mp3');
    }

    setState(() {});
  }

  void _moveShip(Offset delta) {
    double newX = shipPosition.dx + delta.dx;
    double newY = shipPosition.dy + delta.dy;
    // Compute barrier: ship cannot move below barrierY.
    double barrierY = screenHeight - 200; // Moved more up.
    newX = newX.clamp(0.0, screenWidth - shipWidth);
    newY = newY.clamp(0.0, barrierY - shipHeight);
    shipPosition = Offset(newX, newY);
  }

  void _fireLaser() {
    final Offset start = Offset(
      shipPosition.dx + shipWidth / 2,
      shipPosition.dy,
    );
    lasers.add(start);
    setState(() {});
    _audioCache.play('laser.mp3');
  }

  void _firePowerShot() {
    final Offset start = Offset(
      shipPosition.dx + shipWidth / 2,
      shipPosition.dy,
    );
    powerShots.add(start);
    setState(() {});
    _audioCache.play('power_shot.mp3');
  }

  void _fireMissile() {
    final Offset start = Offset(
      shipPosition.dx + shipWidth / 2,
      shipPosition.dy,
    );
    missiles.add(start);
    setState(() {});
    _audioCache.play('missile.mp3');
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _stopSpawning();
        _audioPlayer.pause();
      } else if (!_isGameOver) {
        _startSpawning();
        _audioPlayer.resume();
      }
    });
  }

  void _stopGame() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _audioPlayer.stop();
  }

  void _startGame() {
    setState(() {
      _hasGameStarted = true;
      _isPaused = false;
      _isGameOver = false;
      score = 0;
      level = 1;
      currentHealth = maxHealth;
      enemies.clear();
      lasers.clear();
      powerShots.clear();
      missiles.clear();
      explosions.clear();
      // Recalculate barrier and position ship accordingly.
      double barrierY = screenHeight - 200; // Moved more up.
      shipPosition =
          Offset(screenWidth / 2 - shipWidth / 2, barrierY - shipHeight - 50);
    });
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isPaused && !_isGameOver) _updateGame();
    });
    _startSpawning();
    _startBackgroundMusic();
  }

  void _restartGame() {
    _stopGame();
    setState(() {
      score = 0;
      level = 1;
      currentHealth = maxHealth;
      enemies.clear();
      lasers.clear();
      powerShots.clear();
      missiles.clear();
      explosions.clear();
      _isGameOver = false;
      _isPaused = false;
      double barrierY = screenHeight - 200; // Moved more up.
      shipPosition =
          Offset(screenWidth / 2 - shipWidth / 2, barrierY - shipHeight - 50);
    });
    _startGame();
  }

  Future<void> _startBackgroundMusic() async {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioCache.load('background.mp3');
  }

  // --- Virtual Joystick Widget ---
  Widget _buildJoystick() {
    const double joystickSize = 150;
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isJoystickActive = true;
          _updateJoystick(details.localPosition, joystickSize);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _updateJoystick(details.localPosition, joystickSize);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isJoystickActive = false;
          joystickDirection = Offset.zero;
        });
      },
      child: Container(
        width: joystickSize,
        height: joystickSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF3B3B98), Color(0xFF130f40)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: CustomPaint(
          painter: _JoystickPainter(joystickDirection),
        ),
      ),
    );
  }

  // Improved joystick with deadzone.
  void _updateJoystick(Offset localPosition, double size) {
    final Offset center = Offset(size / 2, size / 2);
    final Offset delta = localPosition - center;
    const double deadZone = 10; // pixels
    if (delta.distance < deadZone) {
      joystickDirection = Offset.zero;
    } else {
      double dx = delta.dx / (size / 2);
      double dy = delta.dy / (size / 2);
      dx = dx.clamp(-1.0, 1.0);
      dy = dy.clamp(-1.0, 1.0);
      joystickDirection = Offset(dx, dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update dimensions.
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // Define barrier line: ship cannot cross below this.
    double barrierY = screenHeight - 200; // Moved more up.

    return WillPopScope(
      onWillPop: () async => false, // Prevent back-swipe.
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background.
            Positioned.fill(
              child: Image.asset(
                'assets/images/hyper.jpg', // Cosmic background.
                fit: BoxFit.cover,
              ),
            ),
            // Top overlay: score, level, and pause button.
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Score and Level.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Score: $score',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      Text('Level: $level',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Pause Button.
                  IconButton(
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _togglePause,
                  ),
                ],
              ),
            ),
            // Health Bar overlay.
            Positioned(
              top: 100,
              left: screenWidth * 0.25,
              right: screenWidth * 0.25,
              child: LinearProgressIndicator(
                value: currentHealth / maxHealth,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ),
            // Barrier line and label.
            Positioned(
              left: 0,
              right: 0,
              top: barrierY - 5,
              child: Container(height: 5, color: Colors.white),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: barrierY - 30,
              child: const Center(
                child: Text(
                  "Move & Shot",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            // Explosion effects.
            ...explosions.map((explosion) {
              double opacity = (1 -
                      DateTime.now()
                              .difference(explosion.startTime)
                              .inMilliseconds /
                          500)
                  .clamp(0.0, 1.0);
              return Positioned(
                left: explosion.position.dx,
                top: explosion.position.dy,
                child: Opacity(
                  opacity: opacity,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset('assets/images/explosion.png'),
                  ),
                ),
              );
            }).toList(),
            // Game objects.
            Stack(
              children: [
                // Lasers.
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
                // Power Shots.
                for (var shot in powerShots)
                  Positioned(
                    left: shot.dx - 5,
                    top: shot.dy,
                    child: Container(
                      width: 15,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                // Missiles.
                for (var missile in missiles)
                  Positioned(
                    left: missile.dx - 4,
                    top: missile.dy,
                    child: Container(
                      width: 8,
                      height: 25,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orangeAccent, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                // Enemies.
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
                // Spaceship.
                Positioned(
                  left: shipPosition.dx,
                  top: shipPosition.dy,
                  child: SizedBox(
                    width: shipWidth,
                    height: shipHeight,
                    child: Image.asset('assets/images/spaceship.png'),
                  ),
                ),
              ],
            ),
            // Virtual Joystick: Bottom left.
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildJoystick(),
            ),
            // Firing Buttons arranged in a zigzag layout (container resized to 150x150).
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  children: [
                    // Laser button at top center.
                    Positioned(
                      top: 0,
                      left: 40,
                      child: _buildFiringButton(
                        icon: Icons.circle,
                        gradient: const LinearGradient(
                            colors: [Colors.redAccent, Colors.red]),
                        onPressed: _fireLaser,
                      ),
                    ),
                    // Power shot button at bottom left.
                    Positioned(
                      bottom: 15,
                      left: 0,
                      child: _buildFiringButton(
                        icon: Icons.star,
                        gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue]),
                        onPressed: _firePowerShot,
                      ),
                    ),
                    // Missile button at bottom right.
                    Positioned(
                      bottom: 15,
                      right: 0,
                      child: _buildFiringButton(
                        icon: Icons.adjust,
                        gradient: const LinearGradient(
                            colors: [Colors.orangeAccent, Colors.deepOrange]),
                        onPressed: _fireMissile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Game Over Overlay.
            if (_isGameOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _restartGame,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                          ),
                          child: const Text(
                            'Restart',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Start Screen Overlay.
            if (!_hasGameStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a custom firing button with a gradient background.
  Widget _buildFiringButton(
      {required IconData icon,
      required Gradient gradient,
      required VoidCallback onPressed}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

extension on AudioCache {
  void play(String s) {}
}

/// A custom painter for the joystick.
class _JoystickPainter extends CustomPainter {
  final Offset direction;
  _JoystickPainter(this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final Paint knobPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw outer circle.
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, outerPaint);

    // Calculate knob position with a maximum movement radius.
    final double maxKnobMovement = size.width / 2 - 15;
    final Offset knobOffset =
        Offset(direction.dx * maxKnobMovement, direction.dy * maxKnobMovement);

    // Draw knob.
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2) + knobOffset, 25, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.direction != direction;
  }
}
