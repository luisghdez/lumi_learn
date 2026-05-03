import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/create/create_flow_transitions.dart';
import 'package:lumi_learn_app/screens/videos/create_video_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart'
    show floatingNavbarBottomReserve;
import 'package:lumi_learn_app/widgets/lumi_cosmic_backdrop.dart';

/// Settings-style glass tiles (see [SettingsScreen._glassOptionTile]).
class CreateFlowShell extends StatelessWidget {
  const CreateFlowShell({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = Get.find<CreateFlowController>();
    final bottomPad = floatingNavbarBottomReserve(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        flow.handleOverlayWillPop();
      },
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: LumiCosmicBackdrop()),
            Positioned.fill(
              child: Obx(() {
                final page = flow.shellPage.value;
                final courseKey = flow.courseSessionKey.value;
                final Widget switchChild = switch (page) {
                  0 => Padding(
                        key: const ValueKey('type'),
                        padding: EdgeInsets.only(bottom: bottomPad),
                        child: _TypeChoicePage(flow: flow),
                      ),
                  1 => CreateVideoScreen(
                        key: ValueKey('video_${flow.sessionKey.value}'),
                        embeddedInCreateFlow: true,
                      ),
                  2 => CourseCreation(
                        key: ValueKey('course_$courseKey'),
                        embeddedInCreateFlow: true,
                      ),
                  _ => Padding(
                        key: const ValueKey('type_fallback'),
                        padding: EdgeInsets.only(bottom: bottomPad),
                        child: _TypeChoicePage(flow: flow),
                      ),
                };
                return AnimatedSwitcher(
                  duration: kCreateFlowFadeDuration,
                  switchInCurve: kCreateFlowFadeCurve,
                  switchOutCurve: kCreateFlowFadeCurve,
                  transitionBuilder: kCreateFlowFadeTransition,
                  layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: switchChild,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChoicePage extends StatelessWidget {
  const _TypeChoicePage({required this.flow});

  final CreateFlowController flow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text(
                  'Create',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to make?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 26),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              children: [
                _settingsStyleTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Create course',
                  subtitle: 'Lessons, flashcards, and quizzes',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    flow.goToCourseFlow();
                  },
                ),
                const SizedBox(height: 18),
                _settingsStyleTile(
                  icon: Icons.videocam_rounded,
                  title: 'Create video',
                  subtitle: 'Share a clip or photo slideshow',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    flow.goToVideoFlow();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _settingsStyleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.38),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
