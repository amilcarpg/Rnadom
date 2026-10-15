import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

typedef AnalyticsWriter = Future<void> Function(
    String name, Map<String, Object> parameters);

class AnalyticsService {
  AnalyticsService({AnalyticsWriter? writer}) : _writer = writer;

  AnalyticsWriter? _writer;
  Future<void>? _initializing;

  /// Analytics is opt-in until the deployment supplies Firebase configuration.
  Future<void> init() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    if (!const bool.fromEnvironment('ANALYTICS_ENABLED')) return;
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      await Firebase.initializeApp(
        options: apiKey.isEmpty
            ? null
            : const FirebaseOptions(
                apiKey: apiKey,
                appId: String.fromEnvironment('FIREBASE_APP_ID'),
                messagingSenderId:
                    String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
                projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
                measurementId:
                    String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
                iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
              ),
      ).timeout(const Duration(seconds: 3));
      await FirebaseAnalytics.instance
          .setAnalyticsCollectionEnabled(true)
          .timeout(const Duration(seconds: 3));
      _writer = (name, parameters) => FirebaseAnalytics.instance
          .logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Missing configuration or SDK availability never prevents a play.
    }
  }

  Future<void> logEvent(String name, Map<String, Object?> params) async {
    try {
      await _initializing;
      final parameters = <String, Object>{};
      for (final entry in params.entries) {
        final value = entry.value;
        if (value is bool) {
          parameters[entry.key] = value ? 1 : 0;
        } else if (value is String) {
          parameters[entry.key] =
              value.length > 100 ? value.substring(0, 100) : value;
        } else if (value is num) {
          parameters[entry.key] = value;
        }
      }
      await _writer?.call(name, parameters);
    } catch (_) {
      // Analytics stays independent of the game and storage.
    }
  }
}
