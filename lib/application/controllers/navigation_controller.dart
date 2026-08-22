import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isNavBarVisible = true.obs;

  /// Incremented when the active Feed tab is tapped again.
  final RxInt feedRefreshRequests = 0.obs;

  /// Temporarily hides feed chrome during press-and-hold accelerated playback.
  final RxBool isFeedChromeHidden = false.obs;

  void setFeedChromeHidden(bool hidden) {
    if (isFeedChromeHidden.value != hidden) {
      isFeedChromeHidden.value = hidden;
    }
  }

  void updateIndex(int index) {
    if (Get.isRegistered<CreateFlowController>()) {
      Get.find<CreateFlowController>().onMainTabBarSelection();
    }
    final previousIndex = currentIndex.value;
    currentIndex.value = index;
    setFeedChromeHidden(false);
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

  void requestFeedRefresh() {
    feedRefreshRequests.value++;
  }

  void hideNavBar() {
    showNavBar();
  }

  void showNavBar() {
    if (!isNavBarVisible.value) {
      isNavBarVisible.value = true;
    }
  }

  /// Vertical scroll notifications keep the navbar visible.
  /// Used by [NotificationListener] on the main shell and on the profile scroll.
  void applyVerticalScrollForNavBar({
    required double pixels,
    required double minExtent,
    required double maxExtent,
    required double scrollDelta,
  }) {
    showNavBar();
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
