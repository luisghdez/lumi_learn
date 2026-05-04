import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/create/create_flow_transitions.dart';
import 'package:lumi_learn_app/screens/create/create_flow_shell.dart';
import 'package:lumi_learn_app/screens/feed/feed_screen.dart';
import 'package:lumi_learn_app/screens/home/home_screen.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Obx(() {
            final tabIndex = navigationController.currentIndex.value;
            final overlayOn = Get.isRegistered<CreateFlowController>() &&
                Get.find<CreateFlowController>().visible.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification:
                      navigationController.handleMainScrollNotification,
                  child: Stack(
                    fit: StackFit.expand,
                    children: _mainTabStackChildren(tabIndex),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: kCreateFlowFadeDuration,
                    switchInCurve: kCreateFlowFadeCurve,
                    switchOutCurve: kCreateFlowFadeCurve,
                    transitionBuilder: kCreateFlowFadeTransition,
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: overlayOn
                        ? const CreateFlowShell(
                            key: ValueKey<String>('create_flow_on'),
                          )
                        : const IgnorePointer(
                            key: ValueKey<String>('create_flow_off'),
                            child: SizedBox.shrink(),
                          ),
                  ),
                ),
              ],
            );
          }),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavbar(),
          ),
        ],
      ),
    );
  }
}

/// Bottom-nav tabs stay mounted (like [IndexedStack]); selected page fades in
/// and others fade out together. Selected child is last so it paints on top.
List<Widget> _mainTabStackChildren(int tabIndex) {
  final specs = <(int, Widget)>[
    (0, const HomeScreen()),
    (1, const FeedScreen()),
    (2, const ProfileScreen()),
  ];
  specs.sort((a, b) {
    final aSel = tabIndex == a.$1;
    final bSel = tabIndex == b.$1;
    if (aSel != bSel) return aSel ? 1 : -1;
    return a.$1.compareTo(b.$1);
  });
  return [
    for (final s in specs)
      Positioned.fill(
        child: _FadingMainTab(
          tabIndex: tabIndex,
          pageIndex: s.$1,
          child: s.$2,
        ),
      ),
  ];
}

class _FadingMainTab extends StatelessWidget {
  const _FadingMainTab({
    required this.tabIndex,
    required this.pageIndex,
    required this.child,
  });

  final int tabIndex;
  final int pageIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selected = tabIndex == pageIndex;
    return IgnorePointer(
      ignoring: !selected,
      child: AnimatedOpacity(
        duration: kCreateFlowFadeDuration,
        curve: kCreateFlowFadeCurve,
        opacity: selected ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}
