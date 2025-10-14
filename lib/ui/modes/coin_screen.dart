import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

import '../../services/rng_service.dart';
import '../../services/analytics_service.dart';
import '../../state/play_provider.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinFace extends StatelessWidget {
  final String? face; // 'Cara' | 'Sello' | null
  const _CoinFace({required this.face});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))],
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Center(
        child: Text(
          face == null ? '' : (face == 'Cara' ? 'CARA' : 'SELLO'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class _CoinScreenState extends State<CoinScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String? _result;
  int _seenToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
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
    unawaited(analytics.logEvent('play_start', {'mode': 'coin'}));
    await play.runLocked(() async {
      setState(() => _result = null);
      await _controller.forward(from: 0);
      final isHeads = rng.nextBool();
      setState(() => _result = isHeads ? 'Cara' : 'Sello');
      unawaited(analytics.logEvent('play_result', {'mode': 'coin', 'value': _result}));
      // pequeña pausa visual
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<PlayProvider>().token;
    if (token != _seenToken) {
      _seenToken = token;
      // desencadenar juego asincrónico sin bloquear build
      unawaited(_play());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: Tween<double>(begin: 0, end: 3).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: _controller.isAnimating ? 5 : 0,
                sigmaY: _controller.isAnimating ? 5 : 0,
              ),
              child: _CoinFace(face: _result),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'resultado',
            value: _result ?? '',
            liveRegion: true,
            child: Text(
              _result ?? '—',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }
}
