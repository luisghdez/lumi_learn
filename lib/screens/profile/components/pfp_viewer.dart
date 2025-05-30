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
    return Transform.translate(
      offset: Offset(0, -widget.offsetUp),
      child: GestureDetector(
        onLongPress: () => widget.onEditModeChange?.call(true),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(avatars[currentIndex], height: 350),
            if (widget.isEditing)
              Positioned(
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 32),
                  onPressed: _prev,
                ),
              ),
            if (widget.isEditing)
              Positioned(
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 32),
                  onPressed: _next,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
