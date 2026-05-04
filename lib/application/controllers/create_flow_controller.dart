import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';

/// Create wizard overlay above the tab shell.
/// [sessionKey] bumps to remount video UI after [discard].
class CreateFlowController extends GetxController {
  final NavigationController _nav = Get.find<NavigationController>();

  final RxBool visible = false.obs;

  /// Legacy: was used when course opened via [Get.to]. Course is now [shellPage]
  /// == 2 inside the same shell as video; kept false for compatibility.
  final RxBool courseCreationRouteOpen = false.obs;

  /// 0 = type chooser, 1 = create video, 2 = create course (same [AnimatedSwitcher]).
  final RxInt shellPage = 0.obs;

  /// Bumps when entering embedded course so [CourseCreation] remounts fresh.
  final RxInt courseSessionKey = 0.obs;

  /// 0 = pick media, 1 = details / publish.
  final RxInt videoSubStep = 0.obs;

  /// True when overlay was hidden because the user switched tabs (draft may exist).
  final RxBool minimized = false.obs;

  /// Child [CreateVideoScreen] registers: return true if it handled back.
  bool Function()? onVideoEmbeddedBack;

  /// Child [CourseCreation] (embedded) registers: return true if it handled back.
  bool Function()? onCourseEmbeddedBack;

  /// Bump to force a fresh [CreateVideoScreen] (e.g. after discard).
  final RxInt sessionKey = 0.obs;

  /// Persisted across tab switches / remounts (paths must still exist on disk).
  final RxnString persistedVideoPath = RxnString();
  final RxList<String> persistedSlidePaths = <String>[].obs;
  final RxString persistedCaption = ''.obs;
  final RxString persistedSubject = ''.obs;

  /// Bottom nav tab was tapped (including same tab, e.g. Profile while already
  /// on Profile). [NavigationController.updateIndex] calls this so the create
  /// overlay closes even when [NavigationController.currentIndex] does not change
  /// (GetX `ever` on index would not fire in that case).
  void onMainTabBarSelection() {
    if (!visible.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!visible.value) return;
      visible.value = false;
      minimized.value = shellPage.value > 0 || videoSubStep.value > 0;
      _nav.showNavBar();
    });
  }

  bool get hasDraft => shellPage.value > 0 || videoSubStep.value > 0;

  void open() {
    _nav.showNavBar();
    minimized.value = false;
    visible.value = true;
  }

  void close() {
    visible.value = false;
    minimized.value = false;
    shellPage.value = 0;
    videoSubStep.value = 0;
    courseCreationRouteOpen.value = false;
    onVideoEmbeddedBack = null;
    onCourseEmbeddedBack = null;
    _nav.showNavBar();
  }

  void discard() {
    shellPage.value = 0;
    videoSubStep.value = 0;
    courseCreationRouteOpen.value = false;
    onVideoEmbeddedBack = null;
    onCourseEmbeddedBack = null;
    minimized.value = false;
    visible.value = false;
    _nav.showNavBar();
    persistedVideoPath.value = null;
    persistedSlidePaths.clear();
    persistedCaption.value = '';
    persistedSubject.value = '';
    sessionKey.value++;
  }

  void clearPersistedMedia() {
    persistedVideoPath.value = null;
    persistedSlidePaths.clear();
  }

  void snapshotVideoDraft({
    String? videoPath,
    List<String>? slidePaths,
    String? caption,
    String? subject,
  }) {
    if (videoPath != null) {
      persistedVideoPath.value = videoPath;
      persistedSlidePaths.clear();
    } else if (slidePaths != null) {
      persistedVideoPath.value = null;
      persistedSlidePaths.assignAll(slidePaths);
    }
    if (caption != null) persistedCaption.value = caption;
    if (subject != null) persistedSubject.value = subject;
  }

  void goToVideoFlow() {
    shellPage.value = 1;
    videoSubStep.value = 0;
    // Tab bar is hidden for full-bleed video; leave via X/back or a tab tap
    // ([NavigationController.updateIndex] still dismisses the overlay).
    _nav.hideNavBar();
  }

  /// Embedded course: same shell transition as [goToVideoFlow] (no [Get.to]).
  void goToCourseFlow() {
    courseSessionKey.value++;
    shellPage.value = 2;
    videoSubStep.value = 0;
    courseCreationRouteOpen.value = false;
    _nav.hideNavBar();
  }

  void goToTypeChoice() {
    shellPage.value = 0;
    videoSubStep.value = 0;
    courseCreationRouteOpen.value = false;
    onCourseEmbeddedBack = null;
    _clearVideoDraftSnapshots();
    sessionKey.value++;
    _nav.showNavBar();
  }

  /// Pop embedded course from step 0 (replaces [Get.back] when there is no route).
  void goBackFromEmbeddedCourseToType() {
    shellPage.value = 0;
    videoSubStep.value = 0;
    courseCreationRouteOpen.value = false;
    onCourseEmbeddedBack = null;
    courseSessionKey.value++;
    _nav.showNavBar();
  }

  void _clearVideoDraftSnapshots() {
    clearPersistedMedia();
    persistedCaption.value = '';
    persistedSubject.value = '';
  }

  void setVideoSubStep(int step) {
    videoSubStep.value = step.clamp(0, 1);
  }

  /// System back while overlay is focused.
  bool handleOverlayWillPop() {
    if (shellPage.value == 1) {
      final handled = onVideoEmbeddedBack?.call() ?? false;
      if (handled) return true;
      shellPage.value = 0;
      videoSubStep.value = 0;
      _clearVideoDraftSnapshots();
      sessionKey.value++;
      _nav.showNavBar();
      return true;
    }
    if (shellPage.value == 2) {
      final handled = onCourseEmbeddedBack?.call() ?? false;
      if (handled) return true;
      shellPage.value = 0;
      videoSubStep.value = 0;
      courseCreationRouteOpen.value = false;
      onCourseEmbeddedBack = null;
      courseSessionKey.value++;
      _nav.showNavBar();
      return true;
    }
    visible.value = false;
    minimized.value = hasDraft;
    _nav.showNavBar();
    return true;
  }

}
