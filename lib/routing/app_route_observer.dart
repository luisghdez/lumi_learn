import 'package:flutter/material.dart';

/// Shared with [GetMaterialApp.navigatorObservers] and [FeedScreen] (RouteAware).
final RouteObserver<PageRoute<void>> appRouteObserver =
    RouteObserver<PageRoute<void>>();
