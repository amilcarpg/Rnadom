import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../domain/mode.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../state/play_provider.dart';
import '../state/settings_provider.dart';
import '../state/history_provider.dart';
import 'modes/coin_screen.dart';
import 'modes/number_screen.dart';
import 'modes/wheel4_screen.dart';
import 'modes/wheel_custom_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  BannerAd? _banner;
  late final TabController _tabs;
  ModeId _activeMode = modes.first.id;
  bool _loadingBanner = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: modes.length, vsync: this)
      ..addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner == null && !_loadingBanner) unawaited(_loadBanner());
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging || _activeMode == modes[_tabs.index].id) return;
    setState(() => _activeMode = modes[_tabs.index].id);
  }

  Future<void> _loadBanner() async {
    _loadingBanner = true;
    final ads = context.read<AdsService>();
    final analytics = context.read<AnalyticsService>();
    try {
      await ads.init();
      if (!mounted || ads.bannerAdUnitId.isEmpty) return;
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              MediaQuery.sizeOf(context).width.truncate());
      if (!mounted || size == null) return;
      final ad = BannerAd(
        size: size,
        adUnitId: ads.bannerAdUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted) {
              loadedAd.dispose();
              return;
            }
            setState(() => _banner = loadedAd as BannerAd);
            unawaited(analytics.logEvent('ad_impression_banner', const {}));
          },
          onAdFailedToLoad: (failedAd, error) {
            failedAd.dispose();
            unawaited(analytics.logEvent(
                'ad_error', {'code': error.code, 'domain': error.domain}));
          },
        ),
      );
      await ad.load();
    } catch (_) {
      // Ads are optional; the game remains fully usable offline.
    } finally {
      _loadingBanner = false;
    }
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled =
        context.select<PlayProvider, bool>((play) => play.canPlay(_activeMode));
    final playing = context.select<PlayProvider, bool>((play) => play.playing);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.15),
            radius: 1.35,
            colors: [Color(0xFF123656), AppPalette.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.contentWidth),
              child: Column(
                children: [
                  const SizedBox(height: Spacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: AppPalette.textPrimary,
                                      fontFamily: 'serif',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800)),
                        ),
                        IconButton(
                            tooltip: l10n.history,
                            onPressed: _openHistory,
                            icon: const Icon(Icons.history)),
                        IconButton(
                            tooltip: l10n.settings,
                            onPressed: _openSettings,
                            icon: const Icon(Icons.settings)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                    child: _ModeSelector(
                      label: modes
                          .firstWhere((mode) => mode.id == _activeMode)
                          .localizedName(context),
                      icon: _modeIcon(_activeMode),
                      semanticLabel: l10n.selectMode,
                      onPressed: _openModeSelector,
                    ),
                  ),
                  const SizedBox(height: Spacing.m),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: const [
                        CoinScreen(),
                        NumberScreen(),
                        Wheel4Screen(),
                        WheelCustomScreen()
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xl, vertical: Spacing.s),
                          child: _GradientCTA(
                            enabled: enabled,
                            onPressed: enabled
                                ? () => context
                                    .read<PlayProvider>()
                                    .requestPlay(_activeMode)
                                : null,
                            text: playing ? l10n.playing : l10n.play,
                          ),
                        ),
                        if (_banner != null)
                          SizedBox(
                              height: _banner!.size.height.toDouble(),
                              child: AdWidget(ad: _banner!)),
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
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer<SettingsProvider>(
        builder: (context, settings, _) => Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                title: Text(AppLocalizations.of(context)!.sound),
                value: settings.settings.soundOn,
                onChanged: settings.loading
                    ? null
                    : (value) => settings
                        .update(settings.settings.copyWith(soundOn: value)),
              ),
              SwitchListTile.adaptive(
                title: Text(AppLocalizations.of(context)!.haptics),
                value: settings.settings.hapticsOn,
                onChanged: settings.loading
                    ? null
                    : (value) => settings
                        .update(settings.settings.copyWith(hapticsOn: value)),
              ),
              DropdownButtonFormField<String?>(
                initialValue: settings.settings.localeCode,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.language),
                items: [
                  DropdownMenuItem(
                      value: null,
                      child:
                          Text(AppLocalizations.of(context)!.systemLanguage)),
                  DropdownMenuItem(
                      value: 'es',
                      child: Text(AppLocalizations.of(context)!.spanish)),
                  DropdownMenuItem(
                      value: 'en',
                      child: Text(AppLocalizations.of(context)!.english)),
                ],
                onChanged: settings.loading
                    ? null
                    : (value) => settings.update(settings.settings.copyWith(
                        localeCode: value, clearLocale: value == null)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openModeSelector() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.l, Spacing.s, Spacing.l, Spacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectMode,
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: Spacing.s),
                for (final mode in modes)
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: Spacing.s),
                    minVerticalPadding: Spacing.s,
                    leading: Icon(_modeIcon(mode.id)),
                    title: Text(mode.localizedName(sheetContext)),
                    subtitle: Text(_modeDescription(l10n, mode.id)),
                    trailing: mode.id == _activeMode
                        ? Icon(Icons.check_circle,
                            color: Theme.of(sheetContext).colorScheme.primary)
                        : null,
                    selected: mode.id == _activeMode,
                    onTap: () => _selectMode(sheetContext, mode.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectMode(BuildContext sheetContext, ModeId mode) {
    Navigator.pop(sheetContext);
    if (mode == _activeMode) return;
    setState(() => _activeMode = mode);
    _tabs.animateTo(modes.indexWhere((item) => item.id == mode));
  }

  IconData _modeIcon(ModeId mode) {
    switch (mode) {
      case ModeId.coin:
        return Icons.sentiment_very_satisfied_rounded;
      case ModeId.number:
        return Icons.numbers;
      case ModeId.wheel4:
        return Icons.donut_large_outlined;
      case ModeId.wheelCustom:
        return Icons.tune;
    }
  }

  String _modeDescription(AppLocalizations l10n, ModeId mode) {
    switch (mode) {
      case ModeId.coin:
        return l10n.coinDescription;
      case ModeId.number:
        return l10n.numberDescription;
      case ModeId.wheel4:
        return l10n.wheel4Description;
      case ModeId.wheelCustom:
        return l10n.wheelCustomDescription;
    }
  }

  void _openHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer<HistoryProvider>(
        builder: (context, history, _) => Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: SizedBox(
            height: 360,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(AppLocalizations.of(context)!.history,
                            style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(
                        onPressed: history.items.isEmpty ? null : history.clear,
                        child: Text(AppLocalizations.of(context)!.clear)),
                  ],
                ),
                Expanded(
                  child: history.loading
                      ? const Center(child: CircularProgressIndicator())
                      : history.items.isEmpty
                          ? Center(
                              child:
                                  Text(AppLocalizations.of(context)!.noPlays))
                          : ListView.separated(
                              itemCount: history.items.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (_, index) {
                                final item = history.items[index];
                                return ListTile(
                                  title: Text(item.value),
                                  subtitle: Text(
                                      '${modes.firstWhere((mode) => mode.id == item.mode).localizedName(context)} · ${item.timestamp.toLocal()}'),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientCTA extends StatelessWidget {
  const _GradientCTA(
      {required this.text, required this.enabled, this.onPressed});

  final String text;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.primary, scheme.secondary];
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: enabled
                    ? colors
                    : colors
                        .map((color) => color.withValues(alpha: .5))
                        .toList()),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, letterSpacing: .6))),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.label,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel,
      value: label,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: AppPalette.surfaceStrong,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: scheme.primary.withValues(alpha: .8)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
              child: Row(
                children: [
                  Icon(icon, color: scheme.primary),
                  const SizedBox(width: Spacing.m),
                  Expanded(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: scheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
