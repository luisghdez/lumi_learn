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
      'assets/backgrounds/fire1.jpg',
      // 'assets/backgrounds/fire2.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/red1.png',
    name: 'Circle Planet 2',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/red1.jpg',
      'assets/backgrounds/red2.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/red2.png',
    name: 'Red Planet 3',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/red1.jpg',
      'assets/backgrounds/red2.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/cyanring1.png',
    name: 'Red Planet 4',
    hasRings: true,
    backgroundPaths: [
      'assets/backgrounds/cyan1.jpg',
      'assets/backgrounds/cyan2.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/green1.png',
    name: 'Red Planet 5',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/trees1.jpg',
      'assets/backgrounds/trees2.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/purple1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/purple1.jpg',
      'assets/backgrounds/purple1.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/tech1.png',
    name: 'Red Planet 6',
    hasRings: false,
    backgroundPaths: [
      'assets/backgrounds/ship1.jpg',
      'assets/backgrounds/ship2.jpg',
    ],
  ),
];
