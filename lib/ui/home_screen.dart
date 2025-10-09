import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../domain/mode.dart';
import '../services/ads_service.dart';
import '../state/play_provider.dart';
import '../state/settings_provider.dart';
import 'modes/coin_screen.dart';
import 'modes/number_screen.dart';
import 'modes/wheel4_screen.dart';
import 'modes/wheel_custom_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    final ads = context.read<AdsService>();
    ads.init().then((_) {
      final unit = ads.bannerAdUnitId;
      if (unit.isEmpty) return; // no ads en esta plataforma
      final ad = BannerAd(
        size: AdSize.banner,
        adUnitId: unit,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      ad.load();
      setState(() => _banner = ad);
    });
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final playing = context.watch<PlayProvider>().playing;
    return DefaultTabController(
      length: modes.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Decisor'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final m in modes) Tab(text: m.name)],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: const [
                  CoinScreen(),
                  NumberScreen(),
                  Wheel4Screen(),
                  WheelCustomScreen(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch.adaptive(
                  value: settings.settings.soundOn,
                  onChanged: settings.loading
                      ? null
                      : (v) => settings.update(settings.settings.copyWith(soundOn: v)),
                ),
                const Text('Sonido'),
                const SizedBox(width: 16),
                Switch.adaptive(
                  value: settings.settings.hapticsOn,
                  onChanged: settings.loading
                      ? null
                      : (v) => settings.update(settings.settings.copyWith(hapticsOn: v)),
                ),
                const Text('Haptics'),
              ],
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: playing ? null : () => context.read<PlayProvider>().triggerPlay(),
                      child: const Text('Jugar'),
                    ),
                  ),
                  if (_banner != null)
                    SizedBox(height: _banner!.size.height.toDouble(), child: AdWidget(ad: _banner!)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// El PlayProvider expone un token que cambia en cada "Jugar".
