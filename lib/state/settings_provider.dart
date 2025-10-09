import 'package:flutter/foundation.dart';

import '../domain/settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService storage;
  Settings _settings = const Settings(soundOn: true, hapticsOn: true, rangeMin: 1, rangeMax: 10);
  bool _loading = true;

  SettingsProvider({required this.storage});

  Settings get settings => _settings;
  bool get loading => _loading;

  Future<void> load() async {
    _settings = await storage.loadSettings();
    _loading = false;
    notifyListeners();
  }

  Future<void> update(Settings next) async {
    _settings = next;
    notifyListeners();
    await storage.saveSettings(_settings);
  }
}

