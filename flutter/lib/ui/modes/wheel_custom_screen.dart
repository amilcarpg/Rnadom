import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/accessibility.dart';
import '../../domain/option_item.dart';
import '../../domain/result.dart';
import '../../services/analytics_service.dart';
import '../../services/feedback_service.dart';
import '../../services/rng_service.dart';
import '../../services/storage_service.dart';
import '../../state/play_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/history_provider.dart';
import '../widgets/circular_wheel.dart';
import '../widgets/result_card.dart';
import '../widgets/game_viewport.dart';
import '../widgets/options_editor.dart';
import '../../l10n/app_localizations.dart';

class WheelCustomScreen extends StatefulWidget {
  const WheelCustomScreen({super.key});

  @override
  State<WheelCustomScreen> createState() => _WheelCustomScreenState();
}

class _WheelCustomScreenState extends State<WheelCustomScreen>
    with SingleTickerProviderStateMixin {
  List<OptionItem> _items = const [];
  OptionItem? _selected;
  late final AnimationController _controller;
  late final PlayProvider _playProvider;
  double _turns = 0;
  double _beginTurns = 0;
  bool _loading = true;
  bool _editing = false;
  Future<void> _writeQueue = Future.value();

  @override
  void initState() {
    super.initState();
    _playProvider = context.read<PlayProvider>();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _playProvider.register(ModeId.wheelCustom, _play, available: false);
      unawaited(_load());
    });
  }

  @override
  void dispose() {
    _playProvider.unregister(ModeId.wheelCustom);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await context.read<StorageService>().loadCustomWheel();
    if (!mounted) return;
    setState(() {
      _items = List.unmodifiable(items);
      _loading = false;
    });
    _playProvider.setAvailable(
        ModeId.wheelCustom, !_editing && items.isNotEmpty);
  }

  Future<void> _replaceItems(List<OptionItem> items) async {
    if (!mounted || _playProvider.playing) return;
    final snapshot = List<OptionItem>.unmodifiable(items);
    final storage = context.read<StorageService>();
    setState(() {
      _items = snapshot;
      _selected = null;
      _turns = 0;
      _beginTurns = 0;
      _controller.value = 0;
    });
    _playProvider.setAvailable(
        ModeId.wheelCustom, !_editing && items.isNotEmpty);
    final write = _writeQueue.then((_) => storage.saveCustomWheel(snapshot));
    _writeQueue = write.catchError((_) {});
    await write;
  }

  Future<void> _play() async {
    if (_editing || _items.isEmpty) return;
    final snapshot = List<OptionItem>.of(_items);
    final index = context.read<RngService>().nextIntInRange(0, snapshot.length);
    final analytics = context.read<AnalyticsService>();
    setState(() {
      _selected = null;
      _beginTurns = _turns;
      _turns = _turns.ceilToDouble() + 3 - index / snapshot.length;
      _controller.value = 0;
    });
    unawaited(analytics.logEvent('play_start', {'mode': 'wheel_custom'}));
    if (!await finishPlayAnimation(_controller, context)) return;
    if (!mounted) return;
    final item = snapshot[index];
    setState(() => _selected = item);
    unawaited(context.read<HistoryProvider>().add(Result(
        mode: ModeId.wheelCustom,
        value: item.label,
        timestamp: DateTime.now())));
    unawaited(analytics.logEvent(
        'play_result', {'mode': 'wheel_custom', 'value': item.label}));
    unawaited(context
        .read<FeedbackService>()
        .playResult(context.read<SettingsProvider>().settings));
  }

  Future<void> _openOptionsEditor() async {
    if (_loading || _playProvider.playing) return;
    _editing = true;
    // Opening the editor makes the mode unavailable, including keyboard triggers.
    _playProvider.setAvailable(ModeId.wheelCustom, false);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => OptionsEditor(items: _items, onChanged: _replaceItems),
      );
    } finally {
      _editing = false;
      if (mounted) {
        _playProvider.setAvailable(ModeId.wheelCustom, _items.isNotEmpty);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playing = context.select<PlayProvider, bool>((play) => play.playing);
    if (_loading) return const Center(child: CircularProgressIndicator());
    return GameViewport(builder: (context, constraints) {
      final wheelSize = math.min(constraints.maxWidth * .72,
          math.max(AppSizes.coinSize, constraints.maxHeight * .42));
      return Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.optionsCount(_items.length),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Spacing.m),
            if (_items.isEmpty) ...[
              Icon(Icons.add_circle_outline,
                  size: AppSizes.emptyIcon,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: Spacing.m),
              Text(l10n.addOneOption, textAlign: TextAlign.center),
            ] else ...[
              CircularWheel(
                items: _items,
                size: wheelSize,
                turns: Tween<double>(begin: _beginTurns, end: _turns).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeOutCubic)),
                selectedIndex: _selected == null
                    ? null
                    : _items.indexWhere((item) => item.id == _selected!.id),
              ),
              const SizedBox(height: Spacing.m),
              ResultCard(value: _selected?.label, color: _selected?.color),
            ],
            const SizedBox(height: Spacing.m),
            Text(l10n.equalChance,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Spacing.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: playing ? null : _openOptionsEditor,
                icon: const Icon(Icons.tune),
                label: Text(l10n.editOptions),
              ),
            ),
          ],
        ),
      );
    });
  }
}
