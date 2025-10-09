import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      // Solo inicializar en plataformas soportadas
      if (Platform.isAndroid || Platform.isIOS) {
        await MobileAds.instance.initialize();
      }
      _initialized = true;
    } catch (_) {
      // Falla en silencio (offline o sin SDK)
    }
  }

  String get bannerAdUnitId {
    // En Windows/u otras plataformas, retornar vacío para omitir banner
    if (!(Platform.isAndroid || Platform.isIOS)) return '';

    if (kDebugMode) {
      // Test IDs oficiales
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }
    // TODO: reemplazar por Ad Unit IDs de producción
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
    } else {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
    }
  }
}
