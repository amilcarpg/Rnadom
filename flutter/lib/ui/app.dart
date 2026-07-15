import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';
import '../services/rng_service.dart';
import '../services/storage_service.dart';
import '../state/play_provider.dart';
import '../state/settings_provider.dart';
import '../state/history_provider.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

class DecisorApp extends StatelessWidget {
  const DecisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => RngService()),
        Provider(create: (_) => AdsService()),
        Provider(create: (_) => AnalyticsService()),
        Provider(create: (_) => FeedbackService()),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => PlayProvider()),
        ChangeNotifierProvider(
          create: (ctx) =>
              HistoryProvider(storage: ctx.read<StorageService>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              SettingsProvider(storage: ctx.read<StorageService>())..load(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: buildTheme(),
          locale: settings.settings.localeCode == null
              ? null
              : Locale(settings.settings.localeCode!),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
