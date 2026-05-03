import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
import '../application/controllers/navigation_controller.dart';

/// Visible height of the floating-pill navbar row (icon tap targets).
const double kFloatingNavbarHeight = 68;

/// Bottom padding used under the pill in [BottomNavbar] (floating layout).
const double kFloatingNavbarOuterBottomPad = 30;

/// Full bottom inset for full-bleed pages (e.g. feed) so content clears the
/// same floating nav used on every tab: bar height + outer pad + safe area.
double floatingNavbarBottomReserve(BuildContext context) {
  final safeBottom = MediaQuery.of(context).padding.bottom;
  return kFloatingNavbarHeight + kFloatingNavbarOuterBottomPad + safeBottom;
}

/// Bottom inset for create-flow: full reserve when the tab bar is shown (type
/// chooser); smaller inset when the bar is hidden (embedded video / course).
double createFlowContentBottomInset(BuildContext context) {
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  if (!Get.isRegistered<CreateFlowController>()) {
    return floatingNavbarBottomReserve(context);
  }
  final flow = Get.find<CreateFlowController>();
  if (createFlowHidesTabNavBar(flow)) {
    return safeBottom + 24;
  }
  return floatingNavbarBottomReserve(context);
}

/// Hide the floating tab bar during embedded create video or full-screen course.
bool createFlowHidesTabNavBar(CreateFlowController flow) {
  return flow.visible.value &&
      (flow.shellPage.value > 0 || flow.courseCreationRouteOpen.value);
}

/// Bottom padding for full-bleed video overlays (caption + action rail).
/// Matches [ProfileUserVideoFeedScreen] so feed and profile video share the
/// same layout; uses only the home indicator inset, not the floating nav band.
double feedVideoOverlayBottomPadding(BuildContext context) {
  return MediaQuery.paddingOf(context).bottom + 14;
}

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  void _openCreateHub() {
    if (!Get.isRegistered<CreateFlowController>()) return;
    Get.find<CreateFlowController>().open();
  }

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildAnimatedNavBar(context, navigationController),
    );
  }

  Widget _buildAnimatedNavBar(
    BuildContext context,
    NavigationController navigationController,
  ) {
    return Obx(() {
      final currentIndex = navigationController.currentIndex.value;
      final scrollVisible = navigationController.isNavBarVisible.value;
      final createFlow = Get.isRegistered<CreateFlowController>()
          ? Get.find<CreateFlowController>()
          : null;
      final createOpen = createFlow?.visible.value ?? false;
      if (createFlow != null) {
        createFlow.shellPage.value;
        createFlow.courseCreationRouteOpen.value;
      }
      final hideForCreateDeep = createFlow != null &&
          createFlowHidesTabNavBar(createFlow);
      final visible = scrollVisible && !hideForCreateDeep;

      const double radius = 40;
      const double hPad = 28;
      const double bgAlpha = 0.06;
      const double borderAlpha = 0.12;
      const double shadowAlpha = 0.45;
      const double barHeight = kFloatingNavbarHeight;
      const double navTapSize = 48;
      const double navIconSize = 24;

      final safeBottom = MediaQuery.of(context).padding.bottom;
      final outerBottomPad = kFloatingNavbarOuterBottomPad + safeBottom;

      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_rounded,
            isSelected: currentIndex == 0 && !createOpen,
            onTap: () => navigationController.updateIndex(0),
            tapSize: navTapSize,
            iconSize: navIconSize,
          ),
          _NavIcon(
            icon: Icons.dynamic_feed_rounded,
            isSelected: currentIndex == 1 && !createOpen,
            onTap: () => navigationController.updateIndex(1),
            tapSize: navTapSize,
            iconSize: navIconSize,
          ),
          _CreateButton(
            onTap: _openCreateHub,
            tapSize: navTapSize,
            iconSize: navIconSize,
            isSelected: createOpen,
          ),
          _NavIcon(
            icon: Icons.person_rounded,
            isSelected: currentIndex == 2 && !createOpen,
            onTap: () => navigationController.updateIndex(2),
            tapSize: navTapSize,
            iconSize: navIconSize,
          ),
        ],
      );

      return IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          offset: visible ? Offset.zero : const Offset(0, 1.6),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            opacity: visible ? 1 : 0,
            child: Padding(
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
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: SizedBox(
                          height: barHeight,
                          child: row,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    required this.onTap,
    required this.tapSize,
    required this.iconSize,
    required this.isSelected,
  });

  final VoidCallback onTap;
  final double tapSize;
  final double iconSize;
  final bool isSelected;

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
                Icons.add_rounded,
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
