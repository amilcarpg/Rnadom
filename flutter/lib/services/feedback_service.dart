import 'package:flutter/services.dart';

import '../domain/settings.dart';

class FeedbackService {
  Future<void> playResult(Settings settings) async {
    if (settings.hapticsOn) await HapticFeedback.mediumImpact();
    if (settings.soundOn) await SystemSound.play(SystemSoundType.click);
  }
}
