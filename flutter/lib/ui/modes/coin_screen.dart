import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
import '../widgets/result_card.dart';
import '../../l10n/app_localizations.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final PlayProvider _playProvider;
  String? _result;
  bool? _isHeads;

  @override
  void initState() {
    super.initState();
    _playProvider = context.read<PlayProvider>();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playProvider.register(ModeId.coin, _play);
    });
  }

  @override
  void dispose() {
    _playProvider.unregister(ModeId.coin);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final rng = context.read<RngService>();
    final analytics = context.read<AnalyticsService>();
    setState(() {
      _result = null;
      _isHeads = null;
    });
    unawaited(analytics.logEvent('play_start', {'mode': 'coin'}));
    await _controller.forward(from: 0);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final isHeads = rng.nextBool();
    final result = isHeads ? l10n.heads : l10n.tails;
    setState(() {
      _result = result;
      _isHeads = isHeads;
    });
    unawaited(context.read<HistoryProvider>().add(
        Result(mode: ModeId.coin, value: result, timestamp: DateTime.now())));
    unawaited(
        analytics.logEvent('play_result', {'mode': 'coin', 'value': result}));
    unawaited(context
        .read<FeedbackService>()
        .playResult(context.read<SettingsProvider>().settings));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final coinSize =
              math.min(constraints.maxWidth * .62, constraints.maxHeight * .48);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 3).animate(
                      CurvedAnimation(
                          parent: _controller, curve: Curves.easeOut)),
                  child: RepaintBoundary(
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                          sigmaX: _controller.isAnimating ? 4 : 0,
                          sigmaY: _controller.isAnimating ? 4 : 0),
                      child:
                          _CoinFace(isHeads: _isHeads ?? true, size: coinSize),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                FractionallySizedBox(
                  widthFactor: .9,
                  child: ResultCard(value: _result),
                ),
              ],
            ),
          );
        },
      );
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.isHeads, required this.size});

  final bool isHeads;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      image: true,
      label: isHeads ? l10n.heads : l10n.tails,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-.35, -.42),
            colors: [Color(0xFFFFE49A), Color(0xFFD99427), Color(0xFF7A4111)],
            stops: [.04, .62, 1],
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))
          ],
          border: Border.all(color: const Color(0xFFFFE4A0), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8D5517), width: 5),
            ),
            child: Center(
              child: Icon(
                isHeads
                    ? Icons.sentiment_very_satisfied_rounded
                    : Icons.workspace_premium_rounded,
                color: const Color(0xFF714310),
                size: size * .46,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
