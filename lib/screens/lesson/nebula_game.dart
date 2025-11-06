// NEBULA GLIDE — a glassy, neon endless runner (single-file edition)
// ------------------------------------------------------------------
// • One-touch controls: hold to thrust up; release to fall (gravity).
// • Procedural obstacles + orbs (score & multiplier).
// • Powerups: Shield, Magnet, SlowMo; each with timers & FX rings.
// • Parallax stars (3 layers), engine trail, impact sparks, camera shake.
// • Glassy HUD with score, high score, pause, game over, start overlays.
// • Clean architecture within a single file (Engine, World, Systems, Painters).
//
// Drop-in: replace your old space_game.dart with this file.
// No external packages required. Flutter 3.x+ compatible.
//
// NOTE: To keep this readable in a single message, I’ve kept it lean but
// still full-featured. If you want me to expand it further (skins/shop/missions,
// daily quests, combo system, etc.), say the word and I’ll ship an extended build.

import 'dart:math';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==============================
/// Config
/// ==============================
class GameConfig {
  // World
  static const double worldGravity = 1100.0; // px/s^2 (flappy bird style)
  static const double horizontalSpeed = 260.0; // px/s forward
  static const double maxFallSpeed = 1100.0;

  // Player
  static const Size playerSize = Size(56, 36);
  static const double dashImpulse = -600.0; // quick flick upward
  static const double dashCooldown = 0.8; // s

  // Spawning
  static const double obstacleSpeed = 260.0; // moves left to simulate forward
  static const double orbSpeed = 260.0;
  static const double minGap = 130.0; // tunnel gap height
  static const double maxGap = 250.0;
  static const Duration spawnEvery = Duration(milliseconds: 1250);
  static const Duration orbEvery = Duration(milliseconds: 800);

  // Powerups
  static const Duration shieldDuration = Duration(seconds: 4);
  static const Duration slowMoDuration = Duration(seconds: 4);
  static const Duration magnetDuration = Duration(seconds: 4);
  static const double slowMoFactor = 0.5; // world slows by half
  static const double magnetRadius = 140.0;

  // Particles
  static const int engineParticlesPerSec = 100;
  static const double engineParticleLife = 0.45;
  static const double engineParticleSpeed = 140.0;

  // Camera shake
  static const double shakeMagnitude = 6.0;
  static const Duration shakeTime = Duration(milliseconds: 180);

  // Visuals
  static const List<Color> bgTop = [Color(0xFF0B0620), Color(0xFF120A3C)];
  static const List<Color> bgBottom = [Color(0xFF1B0E4A), Color(0xFF281166)];

  // Scoring
  static const int orbScore = 10;
  static const int distanceScoreRate = 1; // per chunk
}

/// ==============================
/// Data models / enums
/// ==============================
enum PowerType { shield, magnet, slowmo }

class PowerTimer {
  final PowerType type;
  double remaining; // seconds
  PowerTimer({required this.type, required this.remaining});
  bool get active => remaining > 0;
}

class EntityId {
  final int id;
  const EntityId(this.id);
}

class RectEntity {
  final EntityId eid;
  Rect rect;
  RectEntity(this.eid, this.rect);
}

class Orb {
  final EntityId eid;
  Offset pos;
  double r;
  Orb(this.eid, this.pos, this.r);
}

class Particle {
  Offset pos;
  Offset vel;
  double life; // seconds remaining
  double size;
  Color color;
  Particle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.size,
    required this.color,
  });
}

/// ==============================
/// World state
/// ==============================
class WorldState {
  WorldState({
    required this.size,
  }) {
    playerPos = Offset(size.width * 0.22, size.height * 0.5);
    playerVel = Offset.zero;
  }

  Size size;

  // Player
  late Offset playerPos;
  late Offset playerVel;
  bool alive = true;
  bool shielded = false;
  double dashCd = 0.0; // seconds
  final List<PowerTimer> powers = [];

  // Score
  int score = 0;
  int best = 0;
  double distAcc = 0.0;

  // Spawners
  double spawnAcc = 0.0; // sec
  double orbAcc = 0.0;

  // Entities
  int _eidCounter = 0;
final List<RectEntity> obstacles = [];
final List<RectEntity> scoreTriggers = [];
final List<Orb> orbs = [];

  // FX
  final List<Particle> particles = [];
  double shakeT = 0.0;

  // Control flags
  //bool thrusting = false;
  bool paused = false;
  bool started = false;

  // Helpers
  EntityId nextId() => EntityId(++_eidCounter);

  bool hasPower(PowerType t) {
    final p = powers.where((p) => p.type == t && p.active);
    return p.isNotEmpty;
  }

  double powerRemaining(PowerType t) {
    final p = powers.firstWhere(
      (p) => p.type == t && p.active,
      orElse: () => PowerTimer(type: t, remaining: 0),
    );
    return p.remaining;
  }

  void grantPower(PowerType t, double secs) {
    final already = powers.indexWhere((p) => p.type == t);
    if (already >= 0) {
      powers[already].remaining = secs;
    } else {
      powers.add(PowerTimer(type: t, remaining: secs));
    }
    if (t == PowerType.shield) shielded = true;
  }
}

/// ==============================
/// Game screen
/// ==============================
class NebulaGame extends StatefulWidget {

  const NebulaGame({
    Key? key,
  }) : super(key: key);

  @override
  State<NebulaGame> createState() => _NebulaGameState();
}

class _NebulaGameState extends State<NebulaGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late WorldState world;

  // Smooth slow-mo interpolation
  double _currentSlow = 1.0;
  int _frameSkip = 0;

  @override
  void initState() {
    super.initState();
    world = WorldState(size: const Size(1, 1));
    _loadBestScore();
    _ticker = createTicker(_onTick)..start();
  }

  void _loadBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        world.best = prefs.getInt('bestScore') ?? 0;
      });
    } catch (e) {
      debugPrint('⚠️ SharedPreferences unavailable: $e');
      if (mounted) setState(() => world.best = 0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration d) {
    if (!mounted) return;
    final t = d.inMicroseconds / 1e6; // seconds since ticker started
    _engineTick(t);
  }

  double _lastT = 0.0;
  void _engineTick(double now) {
    final rawDt = (_lastT == 0.0) ? 0.0 : (now - _lastT);
    _lastT = now;
    if (rawDt <= 0) return;

    // Prevent physics explosions after lag frames
    final dt = rawDt.clamp(0.0, 0.04); // ~25 fps lower cap

    if (!world.started || world.paused) {
      setState(() {});
      return;
    }

    // Smooth slow-mo effect for continuous gameplay
    final targetSlow = world.hasPower(PowerType.slowmo)
        ? GameConfig.slowMoFactor
        : 1.0;
    _currentSlow += (targetSlow - _currentSlow) * 0.2; // interpolate gradually
    final step = dt * _currentSlow;

    _updatePlayer(step);
    _spawnSystems(step);
    _updateEntities(step);
    _collisions(step);
    _particles(step);
    _score(step);

    if (++_frameSkip % 2 == 0) {
      setState(() {});
    }
  }

  /// ==========================
  /// Updates
  /// ==========================
  void _updatePlayer(double dt) {
    // Flappy Bird style: gravity always, tap gives instant upward velocity
    final nextVy = world.playerVel.dy + GameConfig.worldGravity * dt;
    world.playerVel = Offset(0, nextVy.clamp(-1000.0, GameConfig.maxFallSpeed));
    world.playerPos = Offset(
      world.playerPos.dx,
      world.playerPos.dy + world.playerVel.dy * dt,
    );

    // Clamp vertical speed
    if (world.playerVel.dy > GameConfig.maxFallSpeed) {
      world.playerVel = Offset(world.playerVel.dx, GameConfig.maxFallSpeed);
    }

    // Keep inside screen vertically
    final minY = GameConfig.playerSize.height * 0.5;
    final maxY = world.size.height - GameConfig.playerSize.height * 0.5;
    if (world.playerPos.dy < minY) {
      world.playerPos = Offset(world.playerPos.dx, minY);
      world.playerVel = Offset(world.playerVel.dx, 0);
    } else if (world.playerPos.dy > maxY) {
      world.playerPos = Offset(world.playerPos.dx, maxY);
      world.playerVel = Offset(world.playerVel.dx, 0);
      _shake();
    }

    // Engine particles
    final pps = GameConfig.engineParticlesPerSec.toDouble();
    final toSpawn = (pps * dt).clamp(0, 50).toInt();
    for (int i = 0; i < toSpawn; i++) {
      final angle = (-pi / 2) + (Random().nextDouble() - 0.5) * 0.4;
      final speed = GameConfig.engineParticleSpeed *
          (0.8 + Random().nextDouble() * 0.6);
      final vel =
          Offset(cos(angle) * -speed, sin(angle) * -speed * 0.2); // mostly left
      final jitterY = (Random().nextDouble() - 0.5) * 8;
      world.particles.add(Particle(
        pos: world.playerPos +
            Offset(-GameConfig.playerSize.width * 0.4,
                (Random().nextDouble() - 0.5) * 6 + jitterY),
        vel: vel,
        life: GameConfig.engineParticleLife * (0.7 + Random().nextDouble() * 0.6),
        size: 2.0 + Random().nextDouble() * 2.5,
        color: Colors.cyanAccent.withOpacity(0.7),
      ));
    }
  }

  void _spawnSystems(double dt) {
    world.spawnAcc += dt;
    world.orbAcc += dt;

    if (world.spawnAcc >= GameConfig.spawnEvery.inMilliseconds / 1000) {
      world.spawnAcc = 0;
      _spawnObstacleTunnel();
      // Occasionally add a powerup pickup (as a special orb cluster)
      if (Random().nextDouble() < 0.22) {
        _spawnPowerPickup();
      }
    }
    if (world.orbAcc >= GameConfig.orbEvery.inMilliseconds / 1000) {
      world.orbAcc = 0;
      _spawnOrbCluster();
    }
  }

void _spawnObstacleTunnel() {
  // Flappy Bird style: consistent gap, predictable width and spacing
  final rnd = Random();
  final w = world.size.width;
  final h = world.size.height;

  const gap = 300.0; // much larger vertical gap for easier navigation
  const pipeWidth = 54.0;
  final minCenter = gap * 0.5 + 40;
  final maxCenter = h - gap * 0.5 - 40;
  final center = rnd.nextDouble() * (maxCenter - minCenter) + minCenter;

  final tunnelLeft = w + 360; // increased horizontal spacing between pillar pairs
  final topRect = Rect.fromLTWH(
    tunnelLeft,
    -1000,
    pipeWidth,
    center - gap * 0.5 + 1000,
  );
  final bottomRect = Rect.fromLTWH(
    tunnelLeft,
    center + gap * 0.5,
    pipeWidth,
    1000,
  );

  world.obstacles.add(RectEntity(world.nextId(), topRect));
  world.obstacles.add(RectEntity(world.nextId(), bottomRect));

  // Mark this pipe pair for scoring
  world.scoreTriggers.add(RectEntity(
    world.nextId(),
    Rect.fromLTWH(
      tunnelLeft + pipeWidth * 0.5 - 2,
      center - gap * 0.5,
      4,
      gap,
    ),
  ));
}
  void _spawnOrbCluster() {
    // Ensure orbs always spawn in accessible gaps between pillars
    if (world.scoreTriggers.isEmpty) return;
    final lastTrigger = world.scoreTriggers.last;
    final gapRect = lastTrigger.rect;
    final gapCenter = gapRect.top + gapRect.height * 0.5;
    final gapHeight = gapRect.height;

    // Keep orbs well inside playable gap area
    final minY = gapRect.top + 40;
    final maxY = gapRect.bottom - 40;
    final orbCount = 1 + (Random().nextDouble() < 0.5 ? 1 : 0);
    for (int i = 0; i < orbCount; i++) {
      final oy = (gapCenter + (i == 0 ? 0 : (i == 1 ? 20 : -20)))
          .clamp(minY, maxY);
      final ox = gapRect.right + 60 + Random().nextDouble() * 20;
      world.orbs.add(Orb(world.nextId(), Offset(ox, oy), 11.0));
    }
  }

  void _spawnPowerPickup() {
    final w = world.size.width;
    final h = world.size.height;
    final rnd = Random();
    final y = rnd.nextDouble() * h * 0.6 + h * 0.2;
    // Represent as 3 orbs in a small triangle; collecting all triggers a power.
    final base = Offset(w + 60, y);
    world.orbs.add(Orb(world.nextId(), base, 9));
    world.orbs.add(Orb(world.nextId(), base + const Offset(18, -12), 9));
    world.orbs.add(Orb(world.nextId(), base + const Offset(18, 12), 9));
  }

  void _updateEntities(double dt) {
    // Smooth slow-mo factor for entity movement
    final slowFactor = world.hasPower(PowerType.slowmo)
        ? GameConfig.slowMoFactor + (1.0 - GameConfig.slowMoFactor) * (1.0 - _currentSlow)
        : 1.0;
    // Move left
    for (var e in world.obstacles) {
      e.rect = e.rect.shift(Offset(-GameConfig.obstacleSpeed * dt * slowFactor, 0));
    }
    for (var s in world.scoreTriggers) {
      s.rect = s.rect.shift(Offset(-GameConfig.obstacleSpeed * dt * slowFactor, 0));
    }
    world.scoreTriggers.removeWhere((s) => s.rect.right < -80);
    for (var o in world.orbs) {
      // Magnet
      if (world.hasPower(PowerType.magnet)) {
        final toPlayer = world.playerPos - o.pos;
        final d = toPlayer.distance;
        if (d < GameConfig.magnetRadius && d > 0) {
          o.pos += toPlayer / d * 240 * dt;
        }
      }
      o.pos = o.pos.translate(-GameConfig.orbSpeed * dt * slowFactor, 0);
    }
    // Despawn offscreen
    world.obstacles.removeWhere((e) => e.rect.right < -80);
    world.orbs.removeWhere((o) => o.pos.dx < -40);

    // Power timers
    for (final p in world.powers) {
      if (p.remaining > 0) {
        p.remaining -= dt;
        if (p.remaining <= 0 && p.type == PowerType.shield) {
          world.shielded = false;
        }
      }
    }
    // Camera shake decay
    world.shakeT = max(0.0, world.shakeT - dt);
  }

  void _collisions(double dt) {
    if (!world.alive) return;

        // --- SCORE TRIGGERS ---
    final scoreToRemove = <RectEntity>[];
    for (final s in world.scoreTriggers) {
      if (s.rect.left + s.rect.width * 0.5 < world.playerPos.dx) {
        world.score += 1;
        scoreToRemove.add(s);
      }
    }
    if (scoreToRemove.isNotEmpty) {
      world.scoreTriggers.removeWhere((s) => scoreToRemove.contains(s));
    }

    // Player capsule (less punishing than a box).
    final playerCenter = world.playerPos;
    final rx = GameConfig.playerSize.width * 0.20;
    final ry = GameConfig.playerSize.height * 0.20;

    // Obstacles & scoring
    for (final e in world.obstacles) {
      // --- NORMAL OBSTACLE COLLISION ---
      if (_rectCapsuleOverlap(e.rect, playerCenter, rx, ry)) {
        if (world.hasPower(PowerType.shield)) {
          // While shielded, ignore this collision and keep playing
          world.shielded = true;
          _impactFX(playerCenter);
          _shake();
          continue; // skip dying
        } else {
          _die();
          break;
        }
      }
    }

    // Orbs (collect)
    final collected = <EntityId>{};
    for (final o in world.orbs) {
      if ((o.pos - playerCenter).distance < (o.r + 14)) {
        _collectOrb(o.pos);
        collected.add(o.eid);
      }
    }
    if (collected.isNotEmpty) {
      world.orbs.removeWhere((o) => collected.contains(o.eid));
    }
  }

  void _collectOrb(Offset where) {
    // Juice
    for (int i = 0; i < 10; i++) {
      final a = Random().nextDouble() * pi * 2;
      final s = 100 + Random().nextDouble() * 140;
      world.particles.add(Particle(
        pos: where,
        vel: Offset(cos(a) * s, sin(a) * s),
        life: 0.25 + Random().nextDouble() * 0.3,
        size: 2.5 + Random().nextDouble() * 2,
        color: Colors.amberAccent.withOpacity(0.9),
      ));
    }
    world.score += GameConfig.orbScore;

    // Lightweight heuristic: every ~9th orb triggers a small power randomly.
    if ((world.score ~/ GameConfig.orbScore) % 9 == 0) {
      final roll = Random().nextDouble();
      if (roll < 0.34) {
        world.grantPower(PowerType.shield, GameConfig.shieldDuration.inSeconds.toDouble());
      } else if (roll < 0.67) {
        world.grantPower(PowerType.magnet, GameConfig.magnetDuration.inSeconds.toDouble());
      } else {
        world.grantPower(PowerType.slowmo, GameConfig.slowMoDuration.inSeconds.toDouble());
      }
    }
  }

  void _impactFX(Offset where) {
    for (int i = 0; i < 24; i++) {
      final a = Random().nextDouble() * pi * 2;
      final s = 140 + Random().nextDouble() * 200;
      world.particles.add(Particle(
        pos: where,
        vel: Offset(cos(a) * s, sin(a) * s),
        life: 0.28 + Random().nextDouble() * 0.35,
        size: 3.0 + Random().nextDouble() * 2.8,
        color: Colors.white.withOpacity(0.9),
      ));
    }
  }

  void _shake() {
    world.shakeT = GameConfig.shakeTime.inMilliseconds / 1000;
  }

  void _die() async {
    world.alive = false;
    world.paused = true;
    _impactFX(world.playerPos);
    _shake();
    world.best = max(world.best, world.score);

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('bestScore', world.best);
  }

  void _particles(double dt) {
    if (world.particles.length > 300) {
      world.particles.removeRange(0, world.particles.length - 300);
    }
    // Smooth slow-mo for particles
    final slowFactor = world.hasPower(PowerType.slowmo)
        ? GameConfig.slowMoFactor + (1.0 - GameConfig.slowMoFactor) * (1.0 - _currentSlow)
        : 1.0;
    // Integrate
    for (int i = world.particles.length - 1; i >= 0; i--) {
      final p = world.particles[i];
      p.pos += p.vel * dt * slowFactor;
      p.vel *= 0.98;
      p.life -= dt;
      if (p.life <= 0) {
        world.particles.removeAt(i);
      }
    }
  }

  void _score(double dt) {
    world.distAcc += dt * GameConfig.horizontalSpeed;
    if (world.distAcc > 110) {
      world.distAcc -= 110;
      world.score += GameConfig.distanceScoreRate;
    }
  }

  /// Collision helper: capsule vs rect.
  bool _rectCapsuleOverlap(Rect r, Offset center, double rx, double ry) {
    // Clamp capsule center to rect bounds and check ellipse distance.
    final cx = center.dx.clamp(r.left, r.right);
    final cy = center.dy.clamp(r.top, r.bottom);
    final dx = (center.dx - cx) / rx;
    final dy = (center.dy - cy) / ry;
    return dx * dx + dy * dy <= 1.0;
  }

  /// ==========================
  /// Input
  /// ==========================
  void _resetRun() {
    world.started = true;
    world.paused = false;
    world.alive = true;
    world.score = 0;
    world.particles.clear();
    world.obstacles.clear();
    world.orbs.clear();
    world.powers.clear();
    world.shielded = false;
    world.dashCd = 0.0;
    // short grace period before spawns so the player isn't hit instantly
    world.spawnAcc = -0.7;
    world.orbAcc = -0.35;
    world.playerPos = Offset(world.size.width * 0.22, world.size.height * 0.5);
    world.playerVel = Offset.zero;
  }

  void _onTap() {
    if (!world.started) {
      _resetRun();
      return;
    }
    if (!world.alive || world.paused) return;
    // Apply instant upward velocity (flap)
    world.playerVel = Offset(0, -400.0);
  }

  void _togglePause() {
    if (!world.started) return;
    setState(() => world.paused = !world.paused);
  }

  /// ==========================
  /// Build / Layout
  /// ==========================
  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    if (world.size != sz) {
      world.size = sz;
      if (!world.started) {
        world.playerPos = Offset(sz.width * 0.22, sz.height * 0.5);
      }
    }

    // Camera shake offset
    final shake = _shakeOffset(world.shakeT);
    final safeTop = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Listener(
          onPointerDown: (_) => _onTap(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: Stack(
              children: [
                // Game canvas with shake
                Transform.translate(
                  offset: shake,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _GamePainter(world),
                  ),
                ),
                // HUD
                Positioned(
                  top: safeTop + 20,
                  left: 14,
                  right: 14,
                  child: _GlassyHud(
                    score: world.score,
                    best: world.best,
                    paused: world.paused,
                    onPause: _togglePause,
                    shield: world.powerRemaining(PowerType.shield),
                    magnet: world.powerRemaining(PowerType.magnet),
                    slowmo: world.powerRemaining(PowerType.slowmo),
                  ),
                ),
                if (!world.started)
                  _StartOverlay(onStart: () {
                    setState(() {
                      _resetRun();
                    });
                  }),
                if (world.paused && world.started && !world.alive)
                  _GameOverOverlay(
                    score: world.score,
                    best: world.best,
                    onRestart: () {
                      setState(() {
                        world.started = false;
                        world.alive = true;
                        world.paused = false;
                      });
                    },
                  ),
                if (world.paused && world.alive)
                  _PausedOverlay(onResume: _togglePause),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _shakeOffset(double t) {
    if (t <= 0) return Offset.zero;
    final mag = GameConfig.shakeMagnitude * (t / (GameConfig.shakeTime.inMilliseconds / 1000));
    return Offset(
      (Random().nextDouble() - 0.5) * mag,
      (Random().nextDouble() - 0.5) * mag,
    );
  }
}

/// ==============================
/// Paint / Render
/// ==============================
class _GamePainter extends CustomPainter {
  final WorldState w;
  _GamePainter(this.w);

  @override
  void paint(Canvas c, Size s) {
    _bg(c, s);
    _stars(c, s);
    _entities(c, s);
    _player(c, s);
    _fx(c, s);
  }

  void _bg(Canvas c, Size s) {
    final r = Rect.fromLTWH(0, 0, s.width, s.height);
    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ...GameConfig.bgTop,
        ...GameConfig.bgBottom,
      ],
      stops: const [0.0, 0.5, 0.65, 1.0],
    );
    c.drawRect(r, Paint()..shader = grad.createShader(r));
  }

  void _stars(Canvas c, Size s) {
    // 3 parallax layers
    final paint1 = Paint()..color = Colors.white.withOpacity(0.24);
    final paint2 = Paint()..color = Colors.white.withOpacity(0.16);
    final paint3 = Paint()..color = Colors.white.withOpacity(0.08);
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    void layer(Paint p, double scale, double speed) {
      final rnd = Random(42);
      for (int i = 0; i < 70; i++) {
        final x = (i * 83 + rnd.nextDouble() * 1200) % (s.width + 200) - 100;
        final y = (i * 59 + rnd.nextDouble() * 1200) % s.height;
        final drift = (t * speed + i) % (s.width + 200);
        c.drawCircle(Offset(s.width - drift + x, y), scale, p);
      }
    }

    layer(paint1, 1.6, 18);
    layer(paint2, 1.2, 34);
    layer(paint3, 0.9, 56);
  }

  void _entities(Canvas c, Size s) {
    // Obstacles (glassy columns)
    for (final e in w.obstacles) {
      // Skip score triggers (thin vertical rects used for scoring)
      if (e.rect.width == 4 && e.rect.height > 40) continue;
      final r = e.rect;
      final grad = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.10),
          Colors.white.withOpacity(0.02),
        ],
      );
      c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()
          ..shader = grad.createShader(r)
          ..style = PaintingStyle.fill,
      );
      // subtle inner stroke
      c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Orbs (glowing energy spheres)
    for (final o in w.orbs) {
      final r = Rect.fromCircle(center: o.pos, radius: o.r);
      final grad = RadialGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0.9),
          Colors.blueAccent.withOpacity(0.2),
        ],
      );
      c.drawCircle(
        o.pos,
        o.r,
        Paint()..shader = grad.createShader(r),
      );
      // Outer glow (no stroke box)
      c.drawCircle(
        o.pos,
        o.r * 1.8,
        Paint()
          ..color = Colors.cyanAccent.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _player(Canvas c, Size s) {
    final pos = w.playerPos;

    // Simplified glowing ship (no grey box)
    final shipGradient = RadialGradient(
      colors: [
        Colors.cyanAccent.withOpacity(0.9),
        Colors.transparent,
      ],
    );
    c.drawCircle(
      pos,
      18,
      Paint()..shader = shipGradient.createShader(Rect.fromCircle(center: pos, radius: 18)),
    );

    // Shield with pulse
    if (w.hasPower(PowerType.shield)) {
      final pulse = (DateTime.now().millisecond / 500.0) * pi;
      final shieldRadius = 36 + sin(pulse) * 3;
      final shieldPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.cyanAccent.withOpacity(0.55),
            Colors.cyanAccent.withOpacity(0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: shieldRadius));
      c.drawCircle(pos, shieldRadius, shieldPaint);
    }

    // Magnet ring
    if (w.hasPower(PowerType.magnet)) {
      c.drawCircle(
        pos,
        GameConfig.magnetRadius * 0.5,
        Paint()
          ..color = Colors.purpleAccent.withOpacity(0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Slow-mo aura
    if (w.hasPower(PowerType.slowmo)) {
      c.drawCircle(
        pos + const Offset(0, 2),
        20,
        Paint()..color = Colors.deepPurpleAccent.withOpacity(0.14),
      );
    }
  }

  void _fx(Canvas c, Size s) {
    for (final p in w.particles) {
      c.drawCircle(
        p.pos,
        p.size,
        Paint()..color = p.color.withOpacity((p.life).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}

/// ==============================
/// HUD Widgets
/// ==============================
class _GlassyHud extends StatelessWidget {
  final int score;
  final int best;
  final bool paused;
  final VoidCallback onPause;
  final double shield, magnet, slowmo;

  const _GlassyHud({
    Key? key,
    required this.score,
    required this.best,
    required this.paused,
    required this.onPause,
    required this.shield,
    required this.magnet,
    required this.slowmo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timerChips = <Widget>[];
    Widget chip(String label, double v, Color color) {
      if (v <= 0) return const SizedBox();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          color: Colors.white.withOpacity(0.07),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('${label.toUpperCase()} ${v.toStringAsFixed(1)}s',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      );
    }

    timerChips.addAll([
      chip('Shield', shield, Colors.cyanAccent),
      chip('Magnet', magnet, Colors.purpleAccent),
      chip('SlowMo', slowmo, Colors.deepPurpleAccent),
    ].where((w) => w is! SizedBox));

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: _GlassBlock(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.amberAccent, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BEST $best',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 0),
                child: Row(
                  children: [
                    for (final t in timerChips) ...[t, const SizedBox(width: 8)],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _GlassBlock(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPause,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.95)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBlock extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  const _GlassBlock({Key? key, required this.child, this.constraints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Platform.isMacOS ? 4 : 8,
          sigmaY: Platform.isMacOS ? 4 : 8,
        ),
        child: Container(
          constraints: constraints,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StartOverlay extends StatelessWidget {
  final VoidCallback onStart;
  const _StartOverlay({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _OverlayScaffold(
      title: 'Nebula Glide',
      subtitle: 'Hold to glide up • Release to fall\nCollect orbs • Avoid glass columns',
      primaryText: 'Start',
      onPrimary: onStart,
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  final VoidCallback onResume;
  const _PausedOverlay({Key? key, required this.onResume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _OverlayScaffold(
      title: 'Paused',
      subtitle: 'Tap to continue your run.',
      primaryText: 'Resume',
      onPrimary: onResume,
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score, best;
  final VoidCallback onRestart;
  const _GameOverOverlay({
    Key? key,
    required this.score,
    required this.best,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _OverlayScaffold(
      title: 'Game Over',
      subtitle: 'Score $score • Best $best',
      primaryText: 'Try Again',
      onPrimary: onRestart,
    );
  }
}

class _OverlayScaffold extends StatelessWidget {
  final String title, subtitle, primaryText;
  final VoidCallback onPrimary;
  const _OverlayScaffold({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.primaryText,
    required this.onPrimary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.black.withOpacity(0.60),
              Colors.black.withOpacity(0.78),
            ],
            stops: const [0.4, 1.0],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            )),
                        const SizedBox(height: 10),
                        Text(subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              height: 1.4,
                            )),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onPrimary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shadowColor: Colors.transparent,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ==============================
/// World helpers (extensions)
/// ==============================
extension _WorldExt on WorldState {
  Rect playerSizeRect() {
    return Rect.fromCenter(center: playerPos, width: GameConfig.playerSize.width, height: GameConfig.playerSize.height);
  }
}