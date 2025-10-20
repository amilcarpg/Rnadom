import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (Platform.isAndroid || Platform.isIOS) {
      await MobileAds.instance.initialize();
      _initialized = true;
    }
  }

  String get bannerAdUnitId {
    if (!(Platform.isAndroid || Platform.isIOS)) return '';

    if (kDebugMode) {
      // ID de prueba de Google (para desarrollo)
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }

    // IDs de producción
    if (Platform.isAndroid) {
      return 'ca-app-pub-2193465688766661/9067826528';
    } else {
      return 'ca-app-pub-2193465688766661/9067826528';
    }
  }
}
