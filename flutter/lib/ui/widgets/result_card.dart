import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/accessibility.dart';
import '../../state/play_provider.dart';
import '../../l10n/app_localizations.dart';

class ResultCard extends StatelessWidget {
  const ResultCard(
      {super.key, required this.value, this.color, this.placeholder = '—'});

  final String? value;
  final Color? color;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final playing = context.select<PlayProvider, bool>((play) => play.playing);
    final displayedValue = value ??
        (playing ? AppLocalizations.of(context)!.sorting : placeholder);
    final isResult = value != null;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context)!.result,
      value: displayedValue,
      excludeSemantics: true,
      liveRegion: true,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        constraints: const BoxConstraints(
            minWidth: AppSizes.resultMinWidth,
            minHeight: AppSizes.resultMinHeight),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl, vertical: Spacing.l),
        decoration: BoxDecoration(
          color: isResult
              ? (color ?? AppPalette.surface)
              : AppPalette.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(
              color: scheme.primary.withValues(alpha: .65), width: 2),
          boxShadow: const [
            BoxShadow(
                color: AppPalette.shadow, blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        child: Center(
          child: Text(
            displayedValue,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: isResult && color != null
                      ? readableForeground(color!)
                      : scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
