import 'package:flutter/material.dart';

class PfpViewer extends StatefulWidget {
  final double offsetUp;
  final bool isEditing;
  final Function(bool)? onEditModeChange;
  final Function(int)? onAvatarChanged;
  final Function()? onDone;
  final int selectedIndex; //pfp id

  const PfpViewer({
    super.key,
    this.offsetUp = 0,
    this.isEditing = false,
    this.onEditModeChange,
    this.onAvatarChanged,
    this.onDone,
    this.selectedIndex = 0,
  });

  @override
  State<PfpViewer> createState() => _PfpViewerState();
}

class _PfpViewerState extends State<PfpViewer> {
  final List<String> avatars = [
    'assets/pfp/pfp1.png',
    'assets/pfp/pfp2.png',
    'assets/pfp/pfp3.png',
    'assets/pfp/pfp4.png',
    'assets/pfp/pfp5.png',
    'assets/pfp/pfp6.png',
    'assets/pfp/pfp7.png',
    'assets/pfp/pfp8.png',
    'assets/pfp/pfp9.png',
    'assets/pfp/pfp10.png',
    'assets/pfp/pfp11.png',
    'assets/pfp/pfp12.png',
    'assets/pfp/pfp13.png',
    'assets/pfp/pfp14.png',
    'assets/pfp/pfp15.png',
    'assets/pfp/pfp16.png',
    'assets/pfp/pfp17.png',
    'assets/pfp/pfp18.png',
    'assets/pfp/pfp19.png',
    'assets/pfp/pfp20.png',
    'assets/pfp/pfp21.png',
    'assets/pfp/pfp22.png',
    'assets/pfp/pfp23.png',
    'assets/pfp/pfp24.png',
    'assets/pfp/pfp25.png',
    'assets/pfp/pfp26.png',
    'assets/pfp/pfp27.png',
    'assets/pfp/pfp28.png',
    'assets/pfp/pfp29.png',
    'assets/pfp/pfp30.png',
    'assets/pfp/pfp31.png',
    'assets/pfp/pfp32.png',
    'assets/pfp/pfp33.png',
    'assets/pfp/pfp34.png',
    'assets/pfp/pfp35.png',
    'assets/pfp/pfp36.png',
    'assets/pfp/pfp37.png',
    'assets/pfp/pfp38.png',
    'assets/pfp/pfp39.png',
    'assets/pfp/pfp40.png',
    'assets/pfp/pfp41.png',
    'assets/pfp/pfp42.png',
    'assets/pfp/pfp43.png',
    'assets/pfp/pfp44.png',
    'assets/pfp/pfp45.png',
    'assets/pfp/pfp46.png',
    'assets/pfp/pfp47.png',
    'assets/pfp/pfp48.png',
    // Add more avatars here as they become available
  ];

  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex.clamp(0, avatars.length - 1);
  }

  @override
  void didUpdateWidget(PfpViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        currentIndex = widget.selectedIndex.clamp(0, avatars.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double imageHeight = 400.0;

    return Transform.translate(
      offset: Offset(0, -widget.offsetUp),
      child: GestureDetector(
        onLongPress: () => widget.onEditModeChange?.call(true),
        child: SizedBox(
          height: imageHeight,
          child: Stack(
            children: [
              Center(
                child: Image.asset(avatars[currentIndex], height: imageHeight),
              ),
              // Edit icon in top-right corner
              Positioned(
                top: 10,
                right: 90,
                child: GestureDetector(
                  onTap: () => widget.onEditModeChange?.call(true),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 91, 91, 91)
                          .withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
