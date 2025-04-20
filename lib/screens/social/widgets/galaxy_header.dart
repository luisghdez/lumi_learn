import 'package:flutter/material.dart';

class GalaxyHeader extends StatelessWidget {
  const GalaxyHeader({super.key, required Padding child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        children: [
          // 🌌 Galaxy Image
          Image.asset(
            'assets/galaxies/galaxyDefault.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
