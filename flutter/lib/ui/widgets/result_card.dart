import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../l10n/app_localizations.dart';

class ResultCard extends StatelessWidget {
  const ResultCard(
      {super.key, required this.value, this.color, this.placeholder = '—'});

  final String? value;
  final Color? color;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final isResult = value != null;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context)!.result,
      value: value ?? '',
      liveRegion: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: const BoxConstraints(minWidth: 220, minHeight: 80),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl, vertical: Spacing.l),
        decoration: BoxDecoration(
          color: isResult
              ? (color ?? scheme.surface)
              : scheme.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            value ?? placeholder,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: isResult && color != null
                      ? _foregroundFor(color!)
                      : scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }

  Color _foregroundFor(Color background) =>
      background.computeLuminance() > 0.45 ? Colors.black : Colors.white;
}
