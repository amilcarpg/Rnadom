import 'package:flutter/services.dart';

import '../domain/settings.dart';

class FeedbackService {
  Future<void> playResult(Settings settings) async {
    try {
      if (settings.hapticsOn) await HapticFeedback.mediumImpact();
    } catch (_) {/* Optional platform capability. */}
    try {
      if (settings.soundOn) await SystemSound.play(SystemSoundType.click);
    } catch (_) {/* Optional platform capability. */}
  }
}
