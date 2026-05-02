import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/videos/create_video_screen.dart';

import '../application/controllers/navigation_controller.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  final NavigationController navigationController = Get.find();
  final GlobalKey _createKey = GlobalKey();

  late final AnimationController _menuController;
  OverlayEntry? _menuOverlay;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _menuOverlay?.remove();
    _menuOverlay = null;
    _menuController.dispose();
    super.dispose();
  }

  bool get _menuOpen => _menuOverlay != null;

  void _toggleMenu() {
    if (_menuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final renderBox =
        _createKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final anchorPosition = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;

    _menuOverlay = OverlayEntry(
      builder: (context) => _CreateMenuOverlay(
        animation: _menuController,
        anchorPosition: anchorPosition,
        anchorSize: anchorSize,
        onDismiss: _closeMenu,
        onCreateVideo: () => _selectAndClose(
          () => Get.to(
            () => const CreateVideoScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          ),
        ),
        onCreateCourse: () => _selectAndClose(
          () => Get.to(
            () => const CourseCreation(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_menuOverlay!);
    _menuController.forward(from: 0);
    setState(() {});
  }

  Future<void> _closeMenu() async {
    if (!_menuOpen) return;
    try {
      await _menuController.reverse();
    } finally {
      _menuOverlay?.remove();
      _menuOverlay = null;
      if (mounted) setState(() {});
    }
  }

  void _selectAndClose(VoidCallback action) async {
    await _closeMenu();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildAnimatedNavBar(),
    );
  }

  Widget _buildAnimatedNavBar() {
    return Obx(() {
      final currentIndex = navigationController.currentIndex.value;
      final visible = navigationController.isNavBarVisible.value;
      // Index 0 == Feed/video screen — bar collapses flush to the bottom
      // so the focus stays on the videos.
      final flushMode = currentIndex == 0;

      return AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.6),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: flushMode ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              final radius = lerpDouble(40, 0, t)!;
              final hPad = lerpDouble(28, 0, t)!;
              final bgAlpha = lerpDouble(0.06, 0.18, t)!;
              final borderAlpha = lerpDouble(0.12, 0.0, t)!;
              final shadowAlpha = lerpDouble(0.45, 0.0, t)!;
              final safeBottom = MediaQuery.of(context).padding.bottom;
              // In floating mode the safe inset goes OUTSIDE the pill, in
              // flush mode it goes INSIDE so the bar background extends
              // edge-to-edge while keeping icons above the home indicator.
              final outerBottomPad = lerpDouble(10 + safeBottom, 0, t)!;
              final innerBottomPad = lerpDouble(0, safeBottom, t)!;
              // Bar shrinks in flush mode so videos take more vertical space.
              final barHeight = lerpDouble(68, 52, t)!;
              final navTapSize = lerpDouble(48, 42, t)!;
              final navIconSize = lerpDouble(24, 22, t)!;
              final createSize = lerpDouble(54, 42, t)!;
              final createIconSize = lerpDouble(30, 24, t)!;

              final row = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavIcon(
                    icon: Icons.home_rounded,
                    isSelected: currentIndex == 0,
                    onTap: () => navigationController.updateIndex(0),
                    tapSize: navTapSize,
                    iconSize: navIconSize,
                  ),
                  _NavIcon(
                    icon: Icons.auto_stories_rounded,
                    isSelected: currentIndex == 1,
                    onTap: () => navigationController.updateIndex(1),
                    tapSize: navTapSize,
                    iconSize: navIconSize,
                  ),
                  _CreateButton(
                    key: _createKey,
                    onTap: _toggleMenu,
                    size: createSize,
                    iconSize: createIconSize,
                    flushProgress: t,
                    rotation: _menuController,
                  ),
                  _NavIcon(
                    icon: Icons.person_rounded,
                    isSelected: currentIndex == 2,
                    onTap: () => navigationController.updateIndex(2),
                    tapSize: navTapSize,
                    iconSize: navIconSize,
                  ),
                ],
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, outerBottomPad),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: bgAlpha),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: borderAlpha),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: shadowAlpha),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashFactory: NoSplash.splashFactory,
                          highlightColor: Colors.transparent,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            innerBottomPad,
                          ),
                          child: SizedBox(
                            height: barHeight,
                            child: row,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tapSize,
    required this.iconSize,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double tapSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: tapSize,
        height: tapSize,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: tapSize,
            height: tapSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55),
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    super.key,
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.flushProgress,
    required this.rotation,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;
  // 0 = floating pill, 1 = flush video bar. Used to soften the glow as the
  // bar collapses so the + matches the slimmer aesthetic.
  final double flushProgress;
  // Drives the + → × rotation while the create menu is open.
  final Animation<double> rotation;

  @override
  Widget build(BuildContext context) {
    final glowAlpha = lerpDouble(0.22, 0.10, flushProgress)!;
    final glowBlur = lerpDouble(18, 10, flushProgress)!;
    final dropAlpha = lerpDouble(0.35, 0.20, flushProgress)!;
    final dropBlur = lerpDouble(14, 8, flushProgress)!;
    final dropOffset = lerpDouble(6, 3, flushProgress)!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE4E4E4),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: glowAlpha),
              blurRadius: glowBlur,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: dropAlpha),
              blurRadius: dropBlur,
              offset: Offset(0, dropOffset),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: rotation,
          builder: (context, _) {
            // 0° → 135° rotates a + into a clean ×.
            final angle = rotation.value * 0.75 * 3.14159265;
            return Transform.rotate(
              angle: angle,
              child: Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: iconSize,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create menu — overlays two glass bubbles above the + when tapped.
// ---------------------------------------------------------------------------

class _CreateMenuOverlay extends StatelessWidget {
  const _CreateMenuOverlay({
    required this.animation,
    required this.anchorPosition,
    required this.anchorSize,
    required this.onDismiss,
    required this.onCreateVideo,
    required this.onCreateCourse,
  });

  final Animation<double> animation;
  final Offset anchorPosition;
  final Size anchorSize;
  final VoidCallback onDismiss;
  final VoidCallback onCreateVideo;
  final VoidCallback onCreateCourse;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final anchorCenterX = anchorPosition.dx + anchorSize.width / 2;
    final anchorTop = anchorPosition.dy;

    // Stagger curves: backdrop fades first, then bubbles pop with overshoot.
    final backdropAnim = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );
    final firstBubbleAnim = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.05, 0.85, curve: Curves.easeOutBack),
      reverseCurve: const Interval(0.15, 1.0, curve: Curves.easeInCubic),
    );
    final secondBubbleAnim = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.18, 1.0, curve: Curves.easeOutBack),
      reverseCurve: const Interval(0.0, 0.85, curve: Curves.easeInCubic),
    );

    const bubbleWidth = 210.0;
    const bubbleSpacing = 12.0;
    const gapAboveAnchor = 16.0;

    // Center bubbles horizontally on the +, but keep them inside the screen
    // with a comfortable side margin.
    const horizontalMargin = 16.0;
    final desiredLeft = anchorCenterX - bubbleWidth / 2;
    final maxLeft = screenSize.width - bubbleWidth - horizontalMargin;
    final clampedLeft = desiredLeft.clamp(horizontalMargin, maxLeft);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: FadeTransition(
                opacity: backdropAnim,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          Positioned(
            left: clampedLeft,
            width: bubbleWidth,
            bottom: screenSize.height - anchorTop + gapAboveAnchor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CreateBubble(
                  animation: secondBubbleAnim,
                  icon: Icons.menu_book_rounded,
                  label: 'Create course',
                  accentColor: const Color(0xFF39D98A),
                  onTap: onCreateCourse,
                ),
                const SizedBox(height: bubbleSpacing),
                _CreateBubble(
                  animation: firstBubbleAnim,
                  icon: Icons.videocam_rounded,
                  label: 'Create video',
                  accentColor: const Color(0xFF8E5CFF),
                  onTap: onCreateVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateBubble extends StatelessWidget {
  const _CreateBubble({
    required this.animation,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final Animation<double> animation;
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Slide up ~16px while scaling and fading in. Origin pinned to the
    // bottom-center so it visually erupts from the + button.
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: Transform.scale(
              scale: 0.85 + 0.15 * t,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
