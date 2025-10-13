import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../services/rng_service.dart';
import '../../services/analytics_service.dart';
import '../../state/play_provider.dart';

class Wheel4Screen extends StatefulWidget {
  const Wheel4Screen({super.key});

  @override
  State<Wheel4Screen> createState() => _Wheel4ScreenState();
}

class _Wheel4ScreenState extends State<Wheel4Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _selected; // 0..3
  int _seenToken = 0;

  static const labels = ['Amarillo', 'Azul', 'Rojo', 'Verde'];
  static const colors = [AppColors.yellow, AppColors.blue, AppColors.red, AppColors.green];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final play = context.read<PlayProvider>();
    final rng = context.read<RngService>();
    final analytics = context.read<AnalyticsService>();
    unawaited(analytics.logEvent('play_start', {'mode': 'wheel4'}));
    await play.runLocked(() async {
      setState(() => _selected = null);
      await _controller.forward(from: 0);
      final idx = rng.nextIntInRange(0, 4);
      setState(() => _selected = idx);
      unawaited(analytics.logEvent('play_result', {'mode': 'wheel4', 'value': labels[idx]}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<PlayProvider>().token;
    if (token != _seenToken) {
      _seenToken = token;
      unawaited(_play());
    }
    final bgColor = _selected == null ? Colors.transparent : colors[_selected!];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: bgColor,
      child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: Tween<double>(begin: 0, end: 2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
            child: SizedBox(
              width: 220,
              height: 220,
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(4, (i) {
                  final selected = _selected == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: colors[i],
                      border: Border.all(color: selected ? Colors.black : Colors.white, width: selected ? 4 : 2),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'resultado',
            value: _selected == null ? '' : labels[_selected!],
            liveRegion: true,
            child: Text(
              _selected == null ? '—' : labels[_selected!],
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    ));
  }
}
