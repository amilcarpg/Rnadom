import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/option_item.dart';
import '../domain/settings.dart';

class StorageKeys {
  static const settings = 'settings';
  static const customWheel = 'custom_wheel';
}

class StorageService {
  Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.settings);
    if (raw == null) {
      return const Settings(soundOn: true, hapticsOn: true, rangeMin: 1, rangeMax: 10);
    }
    return Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.settings, jsonEncode(settings.toJson()));
  }

  Future<List<OptionItem>> loadCustomWheel() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StorageKeys.customWheel) ?? [];
    return raw
        .map((e) => OptionItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> saveCustomWheel(List<OptionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => jsonEncode(e.toJson())).toList(growable: false);
    await prefs.setStringList(StorageKeys.customWheel, list);
  }
}

