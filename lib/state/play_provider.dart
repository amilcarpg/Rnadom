import 'package:flutter/foundation.dart';

class PlayProvider extends ChangeNotifier {
  bool _playing = false;
  int _token = 0;

  bool get playing => _playing;
  int get token => _token;

  void triggerPlay() {
    if (_playing) return; // ignorar si ya está jugando
    _token++;
    notifyListeners();
  }

  Future<T> runLocked<T>(Future<T> Function() action) async {
    if (_playing) throw StateError('Already playing');
    _playing = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _playing = false;
      notifyListeners();
    }
  }
}
