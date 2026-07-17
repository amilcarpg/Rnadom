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
              ? (color ?? AppPalette.surface)
              : AppPalette.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: scheme.primary.withValues(alpha: .65), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))
          ],
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
