import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../services/rng_service.dart';
import '../../services/analytics_service.dart';
import '../../state/play_provider.dart';
import '../../state/settings_provider.dart';

class NumberScreen extends StatefulWidget {
  const NumberScreen({super.key});

  @override
  State<NumberScreen> createState() => _NumberScreenState();
}

class _NumberScreenState extends State<NumberScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late final AnimationController _controller;
  String? _result;
  String? _error;
  int _seenToken = 0;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _minCtrl = TextEditingController(text: s.rangeMin.toString());
    _maxCtrl = TextEditingController(text: s.rangeMax.toString());
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  MapEntry<int, int>? _parseAndValidate() {
    final min = int.tryParse(_minCtrl.text.trim());
    final max = int.tryParse(_maxCtrl.text.trim());
    if (min == null || max == null) {
      setState(() => _error = 'Ingrese valores enteros');
      return null;
    }
    if (min >= max) {
      setState(() => _error = 'Validación: min < max');
      return null;
    }
    if (min < AppLimits.minSuggested || max > AppLimits.maxSuggested) {
      setState(() => _error = 'Sugerido: límites entre -1e9 y 1e9');
      return null;
    }
    setState(() => _error = null);
    return MapEntry(min, max);
  }

  Future<void> _play() async {
    final play = context.read<PlayProvider>();
    final rng = context.read<RngService>();
    final settings = context.read<SettingsProvider>();
    final analytics = context.read<AnalyticsService>();
    unawaited(analytics.logEvent('play_start', {'mode': 'number'}));
    final range = _parseAndValidate();
    if (range == null) return;
    final min = range.key;
    final max = range.value;
    await play.runLocked(() async {
      setState(() => _result = null);
      await _controller.forward(from: 0);
      final value = rng.nextIntInRange(min, max + 1); // inclusivo
      setState(() => _result = '$value');
      unawaited(analytics.logEvent('play_result', {'mode': 'number', 'value': _result}));
      await settings.update(settings.settings.copyWith(rangeMin: min, rangeMax: max));
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<PlayProvider>().token;
    if (token != _seenToken) {
      _seenToken = token;
      unawaited(_play());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min'),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max'),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Semantics(
              label: 'resultado',
              value: _result ?? '',
              liveRegion: true,
              child: Text(
                _result ?? '—',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
