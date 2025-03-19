import 'package:flutter/material.dart';

class ProfilePictureSelector extends StatelessWidget {
  final Function(String) onPictureSelected;

  const ProfilePictureSelector({
    Key? key,
    required this.onPictureSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of profile pictures with titles
    final List<Map<String, String>> profilePictures = [
      {"path": "assets/galaxies/galaxy1.png", "title": "Mystic Galaxy"},
      {"path": "assets/galaxies/galaxy2.png", "title": "Cosmic Wonder"},
      {"path": "assets/galaxies/galaxy3.png", "title": "Nebula Dreams"},
      {"path": "assets/galaxies/galaxy4.png", "title": "Celestial Sphere"},
      {"path": "assets/galaxies/galaxy5.png", "title": "Stellar Radiance"},
      {"path": "assets/images/hyper.jpg", "title": "Hyperspace Voyage"},
      {"path": "assets/images/milky_way.png", "title": "Milky Way"},
      {"path": "assets/images/purple.jpg", "title": "Purple Haze"},
      {"path": "assets/images/yellow.jpg", "title": "Golden Horizon"},
      {"path": "assets/planets/planet1.png", "title": "Crimson Planet"},
      {"path": "assets/planets/planet2.png", "title": "Frozen World"},
      {"path": "assets/planets/planet3.png", "title": "Lush Exoplanet"},
      {"path": "assets/planets/planet4.png", "title": "Desert Dune"},
      {"path": "assets/planets/planet5.png", "title": "Ringed Giant"},
      {"path": "assets/planets/planet6.png", "title": "Gas Titan"},
      {"path": "assets/planets/planet7.png", "title": "Oceanic Planet"},
      {"path": "assets/stars/stars.png", "title": "Star Cluster"},
      {"path": "assets/worlds/cyan1.png", "title": "Cyan Dream"},
      {"path": "assets/worlds/cyan2.png", "title": "Blue Horizon"},
      {"path": "assets/worlds/purple1.png", "title": "Purple Nebula"},
      {"path": "assets/worlds/purple2.png", "title": "Cosmic Violet"},
      {"path": "assets/worlds/red1.png", "title": "Fiery Star"},
      {"path": "assets/worlds/red2.png", "title": "Burning Cosmos"},
      {"path": "assets/worlds/ship1.png", "title": "Space Explorer"},
      {"path": "assets/worlds/ship2.png", "title": "Starship Cruiser"},
      {"path": "assets/worlds/trees1.png", "title": "Ancient Forest"},
      {"path": "assets/worlds/trees2.png", "title": "Enchanted Grove"},
      {"path": "assets/worlds/trees3.png", "title": "Mystic Woods"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Profile Picture"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Three images per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: profilePictures.length,
        itemBuilder: (context, index) {
          final image = profilePictures[index];
          return GestureDetector(
            onTap: () {
              onPictureSelected(image["path"]!);
              Navigator.pop(context);
            },
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(image["path"]!, width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(height: 5),
                Text(
                  image["title"]!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
