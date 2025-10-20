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

  Future<T?> runLocked<T>(Future<T> Function() action) async {
    if (_playing) return null; // ignora si ya está en ejecución
    
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