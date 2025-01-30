// lib/data/assets_data.dart

class Planet {
  final String imagePath;
  final String name;
  final List<String> backgroundPaths;

  Planet({
    required this.imagePath,
    required this.name,
    required this.backgroundPaths,
  });
}

// List of planets with their associated backgrounds
final List<Planet> planets = [
  Planet(
    imagePath: 'assets/planets/red1.png',
    name: 'Red Planet 1',
    backgroundPaths: [
      'assets/backgrounds/bgred1.jpg',
      'assets/backgrounds/bgred2.jpg',
      'assets/backgrounds/bgred3.jpg',
      'assets/backgrounds/bgred4.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/ring1.png',
    name: 'Circle Planet 2',
    backgroundPaths: [
      'assets/backgrounds/bgred1.jpg',
      'assets/backgrounds/bgred2.jpg',
      'assets/backgrounds/bgred3.jpg',
      'assets/backgrounds/bgred4.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/red1.png',
    name: 'Red Planet 3',
    backgroundPaths: [
      'assets/backgrounds/bgred1.jpg',
      'assets/backgrounds/bgred2.jpg',
      'assets/backgrounds/bgred3.jpg',
      'assets/backgrounds/bgred4.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/ring1.png',
    name: 'Circle Planet 2',
    backgroundPaths: [
      'assets/backgrounds/bgred1.jpg',
      'assets/backgrounds/bgred2.jpg',
      'assets/backgrounds/bgred3.jpg',
      'assets/backgrounds/bgred4.jpg',
    ],
  ),
  Planet(
    imagePath: 'assets/planets/ring1.png',
    name: 'Circle Planet 2',
    backgroundPaths: [
      'assets/backgrounds/bgred1.jpg',
      'assets/backgrounds/bgred2.jpg',
      'assets/backgrounds/bgred3.jpg',
      'assets/backgrounds/bgred4.jpg',
    ],
  ),
  // Planet(
  //   imagePath: 'assets/planets/blue1.png',
  //   name: 'Blue Planet 1',
  //   backgroundPaths: [
  //     'assets/backgrounds/bgblue1.jpg',
  //     'assets/backgrounds/bgblue2.jpg',
  //     'assets/backgrounds/bgblue3.jpg',
  //     'assets/backgrounds/bgblue4.jpg',
  //   ],
  // ),
  // Planet(
  //   imagePath: 'assets/planets/green1.png',
  //   name: 'Green Planet 1',
  //   backgroundPaths: [
  //     'assets/backgrounds/bggreen1.jpg',
  //     'assets/backgrounds/bggreen2.jpg',
  //     'assets/backgrounds/bggreen3.jpg',
  //     'assets/backgrounds/bggreen4.jpg',
  //   ],
  // ),
  // Add more planets as needed
];
