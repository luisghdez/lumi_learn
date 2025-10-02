import 'package:flutter/material.dart';

class PfpViewer extends StatefulWidget {
  final double offsetUp;
  final bool isEditing;
  final Function(bool)? onEditModeChange;
  final Function(int)? onAvatarChanged;
  final int selectedIndex; //pfp id

  const PfpViewer({
    super.key,
    this.offsetUp = 0,
    this.isEditing = false,
    this.onEditModeChange,
    this.onAvatarChanged,
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
  ];

  late int currentIndex;

  void _next() {
    setState(() {
      currentIndex = (currentIndex + 1) % avatars.length;
      widget.onAvatarChanged?.call(currentIndex + 1); // 1-based
    });
  }

  void _prev() {
    setState(() {
      currentIndex = (currentIndex - 1 + avatars.length) % avatars.length;
      widget.onAvatarChanged?.call(currentIndex + 1); // 1-based
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex.clamp(0, avatars.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    const double imageHeight = 350.0;

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
                    child: Icon(
                      Icons.edit,
                      color: widget.isEditing ? Colors.grey : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (widget.isEditing)
                Positioned(
                  left: 10,
                  top: imageHeight / 2 - 16, // Center vertically
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 32),
                    onPressed: _prev,
                  ),
                ),
              if (widget.isEditing)
                Positioned(
                  right: 10,
                  top: imageHeight / 2 - 16, // Center vertically
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 32),
                    onPressed: _next,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
