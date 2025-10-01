import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';


class DeepLinkHandler {
  StreamSubscription? _sub;

  final FriendsController controller = Get.find<FriendsController>();

  void init() async {
    // Handle cold start (app launched from a link)
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) _handleUri(initialUri);
    } on PlatformException {
      // Couldn’t get initial uri, ignore
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

    // ✅ Only handle www.lumilearnapp.com/invite/<uid>
    if (uri.host == "www.lumilearnapp.com" &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == "invite" &&
        uri.pathSegments.length > 1) {
      final uid = uri.pathSegments[1];
      print("Navigating to FriendProfile with UID: $uid");

      controller.setActiveFriend(uid);

      // Navigate and pass userId
      Get.to(() => const FriendProfile());
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}