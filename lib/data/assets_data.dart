// lib/data/assets_data.dart

class Planet {
  final String imagePath;
  final String name;
  final bool hasRings;
  final List<String> backgroundPaths;

  Planet({
    required this.imagePath,
    required this.name,
    required this.hasRings,
    required this.backgroundPaths,
  });
}

// List of planets with their associated backgrounds
final List<Planet> planets = [
  Planet(
    imagePath: 'assets/planets/firering1.png',
    name: 'Red Planet 1',
    hasRings: true,
    backgroundPaths: [
      'assets/backgrounds/fire1.png',
      // 'assets/backgrounds/fire2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/red1.png',
    name: 'Circle Planet 2',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/red1.png',
      // 'assets/backgrounds/red2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/red2.png',
    name: 'Red Planet 3',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/red1.png',
      // 'assets/backgrounds/red2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/cyanring1.png',
    name: 'Red Planet 4',
    hasRings: true,
    backgroundPaths: [
      'assets/backgrounds/cyan1.png',
      // 'assets/backgrounds/cyan2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/green1.png',
    name: 'Red Planet 5',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/trees1.png',
      // 'assets/backgrounds/trees3.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/purple1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/purple1.png',
      // 'assets/backgrounds/purple1.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/tech1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/ship1.png',
      // 'assets/backgrounds/ship2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/ice1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/ice1.png',
      // 'assets/backgrounds/ice2.png',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/ocean1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/ocean1.png',
      // 'assets/backgrounds/ocean2.png',
    ],
  ),
];
