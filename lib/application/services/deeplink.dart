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
  String?
      _lastProcessedUri; // Track the last processed URI to prevent duplicates
  bool _isNavigating = false; // Prevent navigation while already navigating
  Timer? _debounceTimer; // Debounce rapid URI events

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

    // Prevent processing the same URI multiple times
    final uriString = uri.toString();
    if (_lastProcessedUri == uriString) {
      print("DeepLinkHandler: URI already processed, skipping: $uriString");
      return;
    }

    // Prevent processing if already navigating
    if (_isNavigating) {
      print("DeepLinkHandler: Already navigating, skipping: $uriString");
      return;
    }

    // Ensure we have the controller before handling the URI
    if (_controller == null) {
      print(
          "DeepLinkHandler: Controller not available, cannot handle deep link");
      return;
    }

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Debounce rapid URI events (wait 500ms before processing)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _processUri(uri, uriString);
    });
  }

  void _processUri(Uri uri, String uriString) {
    // Double-check we haven't processed this URI in the meantime
    if (_lastProcessedUri == uriString || _isNavigating) {
      return;
    }

    // ✅ Only handle www.lumilearnapp.com/invite/<uid>
    if (uri.host == "www.lumilearnapp.com" &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == "invite" &&
        uri.pathSegments.length > 1) {
      final uid = uri.pathSegments[1];
      print("Processing FriendProfile navigation with UID: $uid");

      // Mark this URI as processed and set navigation flag
      _lastProcessedUri = uriString;
      _isNavigating = true;

      _controller!.setActiveFriend(uid);

      // Navigate and pass userId
      Get.to(() => const FriendProfile())?.then((_) {
        // Reset navigation flag and processed URI when user returns
        _isNavigating = false;
        _lastProcessedUri = null; // Allow the same link to be processed again
        print("Navigation completed, reset navigation flag and processed URI");
      });
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _sub?.cancel();
    _sub = null;
    _controller = null;
    _lastProcessedUri = null; // Reset processed URI tracking
    _isNavigating = false; // Reset navigation flag
  }

  // Method to reinitialize after controllers are available
  void reinitialize() {
    // Store the last processed URI before disposing
    final lastUri = _lastProcessedUri;
    dispose(); // Clean up existing subscription
    _lastProcessedUri = lastUri; // Restore the last processed URI
    init(); // Reinitialize with new controllers
  }

  // Method to clear the last processed URI (useful for testing or when you want to allow reprocessing)
  void clearLastProcessedUri() {
    _lastProcessedUri = null;
  }

  // Method to reset navigation state (useful if navigation gets stuck)
  void resetNavigationState() {
    _isNavigating = false;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    print("DeepLinkHandler: Navigation state reset");
  }
}
