import 'package:flutter/foundation.dart';

import '../core/constants.dart';

class PlayProvider extends ChangeNotifier {
  bool _playing = false;
  final Map<ModeId, Future<void> Function()> _actions = {};
  final Map<ModeId, bool> _availability = {};

  bool get playing => _playing;

  void register(ModeId mode, Future<void> Function() action,
      {bool available = true}) {
    _actions[mode] = action;
    _availability[mode] = available;
    notifyListeners();
  }

  void unregister(ModeId mode) {
    _actions.remove(mode);
    _availability.remove(mode);
  }

  void setAvailable(ModeId mode, bool available) {
    if (_availability[mode] == available) return;
    _availability[mode] = available;
    notifyListeners();
  }

  bool canPlay(ModeId mode) => !_playing && (_availability[mode] ?? false);

  Future<void> requestPlay(ModeId mode) async {
    if (!canPlay(mode)) return;
    final action = _actions[mode];
    if (action == null) return;
    await runLocked(action);
  }

  Future<T?> runLocked<T>(Future<T> Function() action) async {
    if (_playing) return null;
    try {
      _playing = true;
      notifyListeners();
      return await action();
    } catch (e) {
      // Log error if needed
      rethrow;
    } finally {
      _playing = false;
      notifyListeners();
    }
  }
}
