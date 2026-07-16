import 'package:flutter/foundation.dart';

import '../domain/settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService storage;
  Settings _settings =
      const Settings(soundOn: true, hapticsOn: true, rangeMin: 1, rangeMax: 10);
  bool _loading = true;
  Object? _error;
  Future<void> _writeQueue = Future.value();

  SettingsProvider({required this.storage});

  Settings get settings => _settings;
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> load() async {
    try {
      _settings = await storage.loadSettings();
      _error = null;
    } catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Settings next) async {
    _settings = next;
    notifyListeners();
    final write = _writeQueue.then<void>((_) => storage.saveSettings(next));
    // Keep later user changes writable even when an earlier disk write fails.
    _writeQueue = write.catchError((_) {});
    try {
      await write;
      if (identical(_settings, next)) _error = null;
    } catch (error) {
      if (identical(_settings, next)) {
        _error = error;
        notifyListeners();
      }
    }
  }
}
