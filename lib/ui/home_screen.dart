import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

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
    final playing = context.watch<PlayProvider>().playing;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: modes.length,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Title + settings icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'DEcisor',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF2D7FF9),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ajustes',
                          onPressed: _openSettings,
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Segmented tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TabBar(
                        isScrollable: true,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black54,
                        tabs: [for (final m in modes) Tab(text: m.name)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Main content area
                  const Expanded(
                    child: TabBarView(
                      children: [
                        CoinScreen(),
                        NumberScreen(),
                        Wheel4Screen(),
                        WheelCustomScreen(),
                      ],
                    ),
                  ),
                  // CTA button and banner at the bottom
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: _GradientCTA(
                            text: 'JUGAR',
                            enabled: !playing,
                            onPressed: playing ? null : () => context.read<PlayProvider>().triggerPlay(),
                          ),
                        ),
                        if (_banner != null)
                          SizedBox(
                            height: _banner!.size.height.toDouble(),
                            child: AdWidget(ad: _banner!),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    final settings = context.read<SettingsProvider>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Switch.adaptive(
                    value: settings.settings.soundOn,
                    onChanged: settings.loading
                        ? null
                        : (v) => settings.update(settings.settings.copyWith(soundOn: v)),
                  ),
                  const Text('Sonido'),
                  const SizedBox(width: 24),
                  Switch.adaptive(
                    value: settings.settings.hapticsOn,
                    onChanged: settings.loading
                        ? null
                        : (v) => settings.update(settings.settings.copyWith(hapticsOn: v)),
                  ),
                  const Text('Haptics'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// El PlayProvider expone un token que cambia en cada "Jugar".

class _GradientCTA extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  const _GradientCTA({required this.text, this.onPressed, required this.enabled});

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF2D7FF9), Color(0xFF49A6FF)];
    return SizedBox(
      width: 240,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          elevation: WidgetStateProperty.all<double>(6),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shadowColor: WidgetStateProperty.all<Color>(Colors.black26),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: enabled ? colors : colors.map((c) => c.withValues(alpha: 0.5)).toList()),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
