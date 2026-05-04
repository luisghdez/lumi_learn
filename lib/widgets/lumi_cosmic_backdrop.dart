import 'package:flutter/material.dart';

/// Shared radial gradient used by create video and create course flows.
class LumiCosmicBackdrop extends StatelessWidget {
  const LumiCosmicBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.32, -0.62),
          radius: 1.65,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            const Color(0xFF050505),
          ],
          stops: const [0, 0.92],
        ),
      ),
    );
  }
}
