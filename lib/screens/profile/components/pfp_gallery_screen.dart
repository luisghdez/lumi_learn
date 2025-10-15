import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class PfpGalleryScreen extends StatefulWidget {
  final int selectedIndex; // 1-based pfp id
  final Function(int)? onAvatarSelected;

  const PfpGalleryScreen({
    super.key,
    this.selectedIndex = 1,
    this.onAvatarSelected,
  });

  @override
  State<PfpGalleryScreen> createState() => _PfpGalleryScreenState();
}

class _PfpGalleryScreenState extends State<PfpGalleryScreen>
    with SingleTickerProviderStateMixin {
  // List of all available avatars
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

  late int selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool isHorizontalView = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;

    // Main fade/slide animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAvatar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _confirmSelection() {
    widget.onAvatarSelected?.call(selectedIndex);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    // Calculate grid properties
    final crossAxisCount = isTablet ? 5 : 4;
    final spacing = isTablet ? 14.0 : 12.0;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Moon background
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),

          // Purple accent orbs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3A005A).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00012D).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header with back button and save
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 22,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      const Spacer(),
                      // Save button
                      GestureDetector(
                        onTap: _confirmSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.grey.shade200.withOpacity(0.95),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: Colors.grey.shade900,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
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
            ),
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // Selected avatar preview - MUCH LARGER
                  Expanded(
                    child: _buildSelectedPreview(),
                  ),
                ],
              ),
            ),
          ),

          // Draggable bottom sheet for avatar gallery
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.42,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.42, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0x9900012D).withOpacity(0.3),
                            const Color(0x993A005A).withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Drag handle area - only this controls the sheet
                          SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                // Drag handle
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Container(
                                      width: 44,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),

                                // Gallery header
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: padding,
                                  ),
                                  child: Row(
                                    children: [
                                      // Container(
                                      //   padding: const EdgeInsets.all(8),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white.withOpacity(0.1),
                                      //     borderRadius:
                                      //         BorderRadius.circular(10),
                                      //     border: Border.all(
                                      //       color:
                                      //           Colors.white.withOpacity(0.2),
                                      //       width: 1,
                                      //     ),
                                      //   ),
                                      //   child: Icon(
                                      //     Icons.grid_view_rounded,
                                      //     color: Colors.white.withOpacity(0.9),
                                      //     size: 18,
                                      //   ),
                                      // ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isHorizontalView =
                                                !isHorizontalView;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            isHorizontalView
                                                ? Icons.grid_view_rounded
                                                : Icons.view_carousel_rounded,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Avatar Collection',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const Spacer(),
                                      // View toggle button
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                          ),
                                        ),
                                        child: Text(
                                          '${avatars.length}',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),
                              ],
                            ),
                          ),

                          // Gallery view - scrolls independently
                          Expanded(
                            child: isHorizontalView
                                ? _buildHorizontalView(padding)
                                : GridView.builder(
                                    padding: EdgeInsets.all(padding),
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: avatars.length,
                                    itemBuilder: (context, index) {
                                      return _buildAvatarCard(
                                        index + 1,
                                        avatars[index],
                                        index,
                                      );
                                    },
                                  ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A005A).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0x9900012D).withOpacity(0.3),
                  const Color(0x993A005A).withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // LARGE avatar showcase - fills most of the space
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Use most of the available space
                        final size = constraints.maxWidth;
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: size,
                            height: size * 1.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color:
                                      const Color(0xFF3A005A).withOpacity(0.4),
                                  blurRadius: 50,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatars[selectedIndex - 1],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Avatar number
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Avatar #$selectedIndex',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalView(double padding) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final isSelected = selectedIndex == (index + 1);
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _selectAvatar(index + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isSelected
                    ? Colors.white.withOpacity(0.14)
                    : Colors.black.withOpacity(0.25),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.18),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  // Avatar image
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        avatars[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Selected indicator
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.95),
                              Colors.grey.shade200.withOpacity(0.95),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.grey.shade900,
                          size: 14,
                        ),
                      ),
                    ),

                  // Subtle overlay for unselected
                  if (!isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarCard(int index, String assetPath, int gridIndex) {
    final isSelected = selectedIndex == index;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 250 + (gridIndex * 20)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.6 + (value * 0.4),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _selectAvatar(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isSelected
                ? Colors.white.withOpacity(0.14)
                : Colors.black.withOpacity(0.25),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.18),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Avatar image
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Selected indicator
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.grey.shade200.withOpacity(0.95),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.grey.shade900,
                        size: 14,
                      ),
                    ),
                  ),
                ),

              // Subtle overlay for unselected
              if (!isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.black.withOpacity(0.15),
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
