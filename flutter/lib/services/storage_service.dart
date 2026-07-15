import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/option_item.dart';
import '../domain/settings.dart';
import '../domain/result.dart';

class StorageKeys {
  static const settings = 'settings';
  static const customWheel = 'custom_wheel';
  static const history = 'history';
}

class StorageService {
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<Settings> loadSettings() async {
    try {
      final raw = (await _prefs).getString(StorageKeys.settings);
      if (raw == null) return _defaultSettings;
      final settings =
          Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _isValidRange(settings.rangeMin, settings.rangeMax)
          ? settings
          : _defaultSettings;
    } catch (_) {
      return _defaultSettings;
    }
  }

  Future<void> saveSettings(Settings settings) async {
    await (await _prefs)
        .setString(StorageKeys.settings, jsonEncode(settings.toJson()));
  }

  Future<List<OptionItem>> loadCustomWheel() async {
    try {
      final raw =
          (await _prefs).getStringList(StorageKeys.customWheel) ?? const [];
      return raw
          .map((entry) =>
              OptionItem.fromJson(jsonDecode(entry) as Map<String, dynamic>))
          .where((item) => item.id.isNotEmpty && item.label.trim().isNotEmpty)
          .take(12)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCustomWheel(List<OptionItem> items) async {
    final prefs = await _prefs;
    final list =
        items.map((e) => jsonEncode(e.toJson())).toList(growable: false);
    await prefs.setStringList(StorageKeys.customWheel, list);
  }

  Future<List<Result>> loadHistory() async {
    try {
      final raw = (await _prefs).getStringList(StorageKeys.history) ?? const [];
      return raw
          .map((entry) =>
              Result.fromJson(jsonDecode(entry) as Map<String, dynamic>))
          .take(50)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveHistory(List<Result> items) async {
    final list = items
        .take(50)
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);
    await (await _prefs).setStringList(StorageKeys.history, list);
  }

  static const _defaultSettings =
      Settings(soundOn: true, hapticsOn: true, rangeMin: 1, rangeMax: 10);
  static bool _isValidRange(int min, int max) =>
      min < max && min >= -1000000000 && max <= 1000000000;
}
