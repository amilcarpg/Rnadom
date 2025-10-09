import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../services/rng_service.dart';
import '../services/storage_service.dart';
import '../state/play_provider.dart';
import '../state/settings_provider.dart';
import 'home_screen.dart';

class DecisorApp extends StatelessWidget {
  const DecisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => RngService()),
        Provider(create: (_) => AdsService()),
        Provider(create: (_) => AnalyticsService()),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => PlayProvider()),
        ChangeNotifierProvider(
          create: (ctx) => SettingsProvider(storage: ctx.read<StorageService>())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Decisor',
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

