import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

Map<String, Object> sanitizeAnalyticsProperties(Map<String, Object?> properties) {
  final safe = <String, Object>{};
  for (final entry in properties.entries) {
    if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(entry.key)) continue;
    if (RegExp(r'email|username|display_name|token|transcript|raw_answer|raw_content|filename|file_path|message_body|raw_text|url|path')
        .hasMatch(entry.key)) continue;
    final value = entry.value;
    if (value is num) { safe[entry.key] = value; }
    if (value is bool) { safe[entry.key] = value ? 1 : 0; }
    if (value is String) { safe[entry.key] = value.substring(0, value.length.clamp(0, 100)); }
  }
  return safe;
}

/// Small, privacy-conscious analytics boundary for product events.
class AnalyticsService with WidgetsBindingObserver {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashes = FirebaseCrashlytics.instance;
  final String sessionId = const Uuid().v4();
  DateTime? _foregroundAt;
  String currentScreen = 'launch';

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    _foregroundAt = DateTime.now();
    await log('session_started');
  }

  Future<void> identify(String? uid) async {
    try {
      await _analytics.setUserId(id: uid);
      await _crashes.setUserIdentifier(uid ?? '');
    } catch (error) {
      debugPrint('Analytics identity update failed: $error');
    }
  }

  Future<void> log(String name, [Map<String, Object?> properties = const {}]) async {
    if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(name)) return;
    final safe = <String, Object>{
      'event_schema_version': 1,
      'session_id': sessionId,
      'screen_name': currentScreen,
    };
    safe.addAll(sanitizeAnalyticsProperties(properties));
    try {
      await _analytics.logEvent(name: name, parameters: safe);
    } catch (error) {
      debugPrint('Analytics event failed: $name ($error)');
    }
  }

  Future<void> screen(String name) async {
    currentScreen = name;
    try {
      await _crashes.setCustomKey('screen_name', name);
    } catch (error) {
      debugPrint('Analytics screen context failed: $error');
    }
    await log('screen_viewed', {'view_name': name});
  }

  Future<void> failure(String code, String action, Object error, StackTrace stack) async {
    await log('action_failed', {'error_code': code, 'action': action});
    try {
      await _crashes.setCustomKey('action', action);
      // Error messages can contain prompts, file names or responses. Keep the
      // stack for diagnosis without transmitting the raw exception text.
      await _crashes.recordError(StateError('$action:$code'), stack, reason: code, fatal: false);
    } catch (reportingError) {
      debugPrint('Error reporting failed: $reportingError');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foregroundAt = DateTime.now();
      unawaited(log('session_resumed'));
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final elapsed = DateTime.now().difference(_foregroundAt ?? DateTime.now());
      unawaited(log('session_paused', {'duration_ms': elapsed.inMilliseconds}));
    }
  }
}
