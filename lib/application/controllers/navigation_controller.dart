import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isNavBarVisible = true.obs;

  /// Ignore tiny deltas from high-DPI trackers / settle jitter.
  static const double _scrollDeltaThreshold = 4.0;

  /// Max distance from the top where we always show the bar (pull-to-refresh).
  /// Capped relative to scroll range so short pages (e.g. profile) can still hide.
  static const double _topRevealPaddingMax = 28.0;

  void updateIndex(int index) {
    if (Get.isRegistered<CreateFlowController>()) {
      Get.find<CreateFlowController>().onMainTabBarSelection();
    }
    final previousIndex = currentIndex.value;
    currentIndex.value = index;
    showNavBar();

    // When returning to the home tab, refresh the short “my courses” strip.
    if (index == 0 && previousIndex != 0) {
      try {
        final CourseController courseController = Get.find<CourseController>();
        courseController.fetchCoursesForHome();
      } catch (_) {
        // Silently handle error if CourseController is not yet initialized
      }
    }
  }

  void hideNavBar() {
    if (isNavBarVisible.value) {
      isNavBarVisible.value = false;
    }
  }

  void showNavBar() {
    if (!isNavBarVisible.value) {
      isNavBarVisible.value = true;
    }
  }

  /// Vertical scroll: hide on scroll down, show on scroll up / near top.
  /// Used by [NotificationListener] on the main shell and on the profile scroll.
  void applyVerticalScrollForNavBar({
    required double pixels,
    required double minExtent,
    required double maxExtent,
    required double scrollDelta,
  }) {
    if (pixels < minExtent) {
      showNavBar();
      return;
    }
    if (pixels > maxExtent) {
      return;
    }

    final span = maxExtent - minExtent;
    final topReveal = span <= 0
        ? 0.0
        : math.min(_topRevealPaddingMax, span * 0.45);
    if (pixels <= minExtent + topReveal) {
      showNavBar();
      return;
    }

    if (scrollDelta.abs() < _scrollDeltaThreshold) {
      return;
    }

    if (scrollDelta > 0) {
      hideNavBar();
    } else {
      showNavBar();
    }
  }

  /// Vertical scroll from feed / home (via [NotificationListener]).
  /// Profile (tab index 2) is excluded: it uses its own listener above the
  /// scroll view so [RefreshIndicator] does not skew metrics.
  /// Return false so the notification continues to propagate.
  bool handleMainScrollNotification(ScrollNotification notification) {
    if (currentIndex.value == 2) {
      return false;
    }

    final metrics = notification.metrics;
    if (!metrics.hasPixels || metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is! ScrollUpdateNotification) {
      return false;
    }

    applyVerticalScrollForNavBar(
      pixels: metrics.pixels,
      minExtent: metrics.minScrollExtent,
      maxExtent: metrics.maxScrollExtent,
      scrollDelta: notification.scrollDelta ?? 0,
    );
    return false;
  }
}
