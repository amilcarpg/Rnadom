import 'package:flutter/foundation.dart';

class AnalyticsService {
  Future<void> logEvent(String name, Map<String, Object?> params) async {
    if (kDebugMode) {
      // Placeholder; integrar Firebase en entorno real
    }
  }
}
