import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/result.dart';
import '../../services/analytics_service.dart';
import '../../services/feedback_service.dart';
import '../../services/rng_service.dart';
import '../../state/play_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/history_provider.dart';
import '../../l10n/app_localizations.dart';

class NumberScreen extends StatefulWidget {
  const NumberScreen({super.key});

  @override
  State<NumberScreen> createState() => _NumberScreenState();
}

class _NumberScreenState extends State<NumberScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late final AnimationController _controller;
  late final PlayProvider _playProvider;
  String? _result;
  String? _error;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _playProvider = context.read<PlayProvider>();
    final settings = context.read<SettingsProvider>().settings;
    _minCtrl = TextEditingController(text: settings.rangeMin.toString());
    _maxCtrl = TextEditingController(text: settings.rangeMax.toString());
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playProvider.register(ModeId.number, _play);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (!_hydrated && !settings.loading) {
      _hydrated = true;
      _minCtrl.text = settings.settings.rangeMin.toString();
      _maxCtrl.text = settings.settings.rangeMax.toString();
    }
  }

  @override
  void dispose() {
    _playProvider.unregister(ModeId.number);
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  MapEntry<int, int>? _parseAndValidate() {
    final l10n = AppLocalizations.of(context)!;
    final min = int.tryParse(_minCtrl.text.trim());
    final max = int.tryParse(_maxCtrl.text.trim());
    String? error;
    if (min == null || max == null) {
      error = l10n.invalidIntegers;
    } else if (min >= max) {
      error = l10n.minimumLessThanMaximum;
    } else if (min < AppLimits.minSuggested || max > AppLimits.maxSuggested) {
      error = l10n.rangeLimit;
    }
    setState(() => _error = error);
    return error == null ? MapEntry(min!, max!) : null;
  }

  Future<void> _play() async {
    final range = _parseAndValidate();
    if (range == null) return;
    final analytics = context.read<AnalyticsService>();
    final rng = context.read<RngService>();
    unawaited(analytics.logEvent('play_start', {'mode': 'number'}));
    setState(() => _result = null);
    await _controller.forward(from: 0);
    if (!mounted) return;
    final value = rng.nextIntInRange(range.key, range.value + 1);
    final result = '$value';
    setState(() => _result = result);
    unawaited(context.read<HistoryProvider>().add(
        Result(mode: ModeId.number, value: result, timestamp: DateTime.now())));
    unawaited(
        analytics.logEvent('play_result', {'mode': 'number', 'value': result}));
    final settings = context.read<SettingsProvider>();
    unawaited(settings.update(settings.settings
        .copyWith(rangeMin: range.key, rangeMax: range.value)));
    unawaited(context.read<FeedbackService>().playResult(settings.settings));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loading =
        context.select<SettingsProvider, bool>((state) => state.loading);
    if (loading) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: constraints.maxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.numberRange,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: Spacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _numberField(_minCtrl, l10n.minimum)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Spacing.s),
                      child: Icon(Icons.arrow_forward),
                    ),
                    Expanded(child: _numberField(_maxCtrl, l10n.maximum)),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.s),
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: Spacing.xl),
                ScaleTransition(
                  scale: Tween<double>(begin: .85, end: 1).animate(
                      CurvedAnimation(
                          parent: _controller, curve: Curves.easeOutBack)),
                  child: FractionallySizedBox(
                    widthFactor: .9,
                    child: _FlipNumberCard(value: _result),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Spacing.s),
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: Spacing.xs),
          SizedBox(
            height: AppSizes.numberInputHeight,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s, vertical: Spacing.m),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  borderSide: BorderSide(color: scheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  borderSide:
                      BorderSide(color: scheme.primary.withValues(alpha: .5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipNumberCard extends StatelessWidget {
  const _FlipNumberCard({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayedValue = value ?? '—';
    return Semantics(
      label: AppLocalizations.of(context)!.result,
      value: value ?? '',
      liveRegion: true,
      child: Container(
        constraints:
            const BoxConstraints(minHeight: AppSizes.numberResultHeight),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: scheme.primary.withValues(alpha: .7)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Divider(height: Spacing.xs, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: Tween<double>(begin: .5, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: FittedBox(
                  key: ValueKey(displayedValue),
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayedValue,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
