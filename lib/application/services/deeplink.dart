import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';

class DeepLinkHandler {
  static DeepLinkHandler? _instance;
  StreamSubscription? _sub;
  FriendsController? _controller;

  // Singleton pattern
  static DeepLinkHandler get instance {
    _instance ??= DeepLinkHandler._internal();
    return _instance!;
  }

  DeepLinkHandler._internal();

  // Factory constructor
  factory DeepLinkHandler() => instance;

  void init() async {
    // Ensure we have the FriendsController before initializing
    if (!Get.isRegistered<FriendsController>()) {
      print(
          "DeepLinkHandler: FriendsController not registered yet, skipping initialization");
      return;
    }

    _controller = Get.find<FriendsController>();

    // Handle cold start (app launched from a link)
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) _handleUri(initialUri);
    } on PlatformException {
      // Couldn't get initial uri, ignore
    }

    // Handle links while app is running / resumed
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleUri(uri);
    }, onError: (err) {
      print("Deep link error: $err");
    });
  }

  void _handleUri(Uri uri) {
    print("Received deep link: $uri");

    // Ensure we have the controller before handling the URI
    if (_controller == null) {
      print(
          "DeepLinkHandler: Controller not available, cannot handle deep link");
      return;
    }

    // ✅ Only handle www.lumilearnapp.com/invite/<uid>
    if (uri.host == "www.lumilearnapp.com" &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == "invite" &&
        uri.pathSegments.length > 1) {
      final uid = uri.pathSegments[1];
      print("Navigating to FriendProfile with UID: $uid");

      _controller!.setActiveFriend(uid);

      // Navigate and pass userId
      Get.to(() => const FriendProfile());
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _controller = null;
  }

  // Method to reinitialize after controllers are available
  void reinitialize() {
    dispose(); // Clean up existing subscription
    init(); // Reinitialize with new controllers
  }
}
