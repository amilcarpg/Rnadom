import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/accessibility.dart';
import '../widgets/game_viewport.dart';
import '../../domain/option_item.dart';
import '../../domain/result.dart';
import '../../services/analytics_service.dart';
import '../../services/feedback_service.dart';
import '../../services/rng_service.dart';
import '../../state/play_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/history_provider.dart';
import '../widgets/circular_wheel.dart';
import '../widgets/result_card.dart';
import '../../l10n/app_localizations.dart';

class Wheel4Screen extends StatefulWidget {
  const Wheel4Screen({super.key});

  @override
  State<Wheel4Screen> createState() => _Wheel4ScreenState();
}

class _Wheel4ScreenState extends State<Wheel4Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final PlayProvider _playProvider;
  int? _selected;
  double _turns = 0;
  double _beginTurns = 0;

  List<OptionItem> _items(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OptionItem(id: 'yellow', label: l10n.yellow, color: AppColors.yellow),
      OptionItem(id: 'blue', label: l10n.blue, color: AppColors.blue),
      OptionItem(id: 'red', label: l10n.red, color: AppColors.red),
      OptionItem(id: 'green', label: l10n.green, color: AppColors.green),
    ];
  }

  @override
  void initState() {
    super.initState();
    _playProvider = context.read<PlayProvider>();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playProvider.register(ModeId.wheel4, _play);
    });
  }

  @override
  void dispose() {
    _playProvider.unregister(ModeId.wheel4);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final items = _items(context);
    final index = context.read<RngService>().nextIntInRange(0, items.length);
    final analytics = context.read<AnalyticsService>();
    setState(() {
      _selected = null;
      _beginTurns = _turns;
      _turns = _turns.ceilToDouble() + 3 - index / items.length;
      _controller.value = 0;
    });
    unawaited(analytics.logEvent('play_start', {'mode': 'wheel4'}));
    if (!await finishPlayAnimation(_controller, context)) return;
    if (!mounted) return;
    final item = items[index];
    setState(() => _selected = index);
    unawaited(context.read<HistoryProvider>().add(Result(
        mode: ModeId.wheel4, value: item.label, timestamp: DateTime.now())));
    unawaited(analytics
        .logEvent('play_result', {'mode': 'wheel4', 'value': item.label}));
    unawaited(context
        .read<FeedbackService>()
        .playResult(context.read<SettingsProvider>().settings));
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return GameViewport(
      builder: (context, constraints) {
        final wheelSize = math.min(
          constraints.maxWidth * .8,
          constraints.maxHeight * .55,
        );
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularWheel(
                items: items,
                size: wheelSize,
                turns: Tween<double>(begin: _beginTurns, end: _turns).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeOutCubic)),
                selectedIndex: _selected,
              ),
              const SizedBox(height: Spacing.m),
              Text(AppLocalizations.of(context)!.equalChance,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: Spacing.m),
              FractionallySizedBox(
                widthFactor: .9,
                child: ResultCard(
                    value: _selected == null ? null : items[_selected!].label,
                    color: _selected == null ? null : items[_selected!].color),
              ),
            ],
          ),
        );
      },
    );
  }
}
