import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
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

  static const palette = <Color>[
    AppColors.yellow,
    AppColors.blue,
    AppColors.red,
    AppColors.green,
    AppColors.purple,
    AppColors.cyan,
    AppColors.orange,
    AppColors.pink,
    AppColors.indigo,
    AppColors.lime,
  ];

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
    _replaceItems(items);
  }

  void _replaceItems(List<OptionItem> items) {
    setState(() => _items = List.unmodifiable(items));
    _playProvider.setAvailable(ModeId.wheelCustom, items.isNotEmpty);
  }

  Future<void> _save() =>
      context.read<StorageService>().saveCustomWheel(_items);

  Future<void> _play() async {
    if (_items.isEmpty) return;
    final index = context.read<RngService>().nextIntInRange(0, _items.length);
    final analytics = context.read<AnalyticsService>();
    setState(() {
      _selected = null;
      _turns = 4 - index / _items.length;
    });
    unawaited(analytics.logEvent('play_start', {'mode': 'wheel_custom'}));
    await _controller.forward(from: 0);
    if (!mounted) return;
    final item = _items[index];
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

  Future<void> _addOrEdit([OptionItem? item]) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item?.label ?? '');
    Color color = item?.color ?? palette[_items.length % palette.length];
    final result = await showDialog<OptionItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(item == null ? l10n.addOption : l10n.editOption),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.optionText)),
              const SizedBox(height: Spacing.l),
              Wrap(
                spacing: Spacing.s,
                runSpacing: Spacing.s,
                children: [
                  for (final candidate in palette)
                    Semantics(
                      label: l10n.color(_colorName(candidate, l10n)),
                      selected: candidate == color,
                      button: true,
                      child: IconButton(
                        tooltip: l10n.color(_colorName(candidate, l10n)),
                        onPressed: () =>
                            setDialogState(() => color = candidate),
                        icon: Icon(Icons.circle,
                            color: candidate, size: AppSizes.minTouchTarget),
                        style: IconButton.styleFrom(
                            side: BorderSide(
                                color: candidate == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final label = controller.text.trim();
                if (label.isEmpty) return;
                Navigator.pop(
                    dialogContext,
                    OptionItem(
                        id: item?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        label: label,
                        color: color));
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || result == null) return;
    final next = [..._items];
    final index = next.indexWhere((candidate) => candidate.id == result.id);
    if (index >= 0) {
      next[index] = result;
    } else if (next.length < 12) {
      next.add(result);
    }
    _replaceItems(next);
    await _save();
  }

  Future<void> _remove(OptionItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteOption),
        content: Text(l10n.deleteOptionConfirmation(item.label)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    _replaceItems(_items
        .where((candidate) => candidate.id != item.id)
        .toList(growable: false));
    await _save();
  }

  Future<void> _openOptionsEditor() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (_, setSheetState) => SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * .72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.l, Spacing.s, Spacing.l, Spacing.l),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Editar opciones',
                              style:
                                  Theme.of(sheetContext).textTheme.titleLarge),
                        ),
                        Text('${_items.length}/12',
                            style: TextStyle(
                                color:
                                    Theme.of(sheetContext).colorScheme.primary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: Spacing.m),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.minTouchTarget,
                      child: FilledButton.icon(
                        onPressed: _items.length >= 12
                            ? null
                            : () async {
                                await _addOrEdit();
                                if (mounted) setSheetState(() {});
                              },
                        icon: const Icon(Icons.add),
                        label:
                            Text(AppLocalizations.of(sheetContext)!.addOption),
                      ),
                    ),
                    const SizedBox(height: Spacing.m),
                    Expanded(
                      child: _items.isEmpty
                          ? const _EmptyWheel()
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: Spacing.s),
                              itemBuilder: (_, index) => _OptionTile(
                                item: _items[index],
                                onEdit: () async {
                                  await _addOrEdit(_items[index]);
                                  if (mounted) setSheetState(() {});
                                },
                                onRemove: () async {
                                  await _remove(_items[index]);
                                  if (mounted) setSheetState(() {});
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  String _colorName(Color color, AppLocalizations l10n) {
    if (color == AppColors.yellow) return l10n.yellow;
    if (color == AppColors.blue) return l10n.blue;
    if (color == AppColors.red) return l10n.red;
    if (color == AppColors.green) return l10n.green;
    return l10n.customColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.wheelCustom,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.m, vertical: Spacing.s),
                  child: Text(l10n.optionsCount(_items.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),
          if (_items.isEmpty)
            const Expanded(child: _EmptyWheel())
          else ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => CircularWheel(
                      items: _items,
                      size: math.min(constraints.maxWidth * .72,
                          constraints.maxHeight * .68),
                      turns: Tween<double>(begin: 0, end: _turns).animate(
                          CurvedAnimation(
                              parent: _controller, curve: Curves.easeOutCubic)),
                      selectedIndex: _selected == null
                          ? null
                          : _items
                              .indexWhere((item) => item.id == _selected!.id),
                    ),
                  ),
                  const SizedBox(height: Spacing.m),
                  FractionallySizedBox(
                    widthFactor: .9,
                    child: ResultCard(
                        value: _selected?.label, color: _selected?.color),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Spacing.s),
          SizedBox(
            width: double.infinity,
            height: AppSizes.minTouchTarget,
            child: FilledButton.icon(
              onPressed: _openOptionsEditor,
              icon: const Icon(Icons.tune),
              label: const Text('Editar opciones'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile(
      {required this.item, required this.onEdit, required this.onRemove});

  final OptionItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: ListTile(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: scheme.primary.withValues(alpha: .3)),
            borderRadius: BorderRadius.circular(AppRadii.small)),
        leading: Semantics(
          label: l10n.colorOf(item.label),
          child: CircleAvatar(backgroundColor: item.color),
        ),
        title: Text(item.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                tooltip: l10n.edit(item.label),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined)),
            IconButton(
                tooltip: l10n.remove(item.label),
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}

class _EmptyWheel extends StatelessWidget {
  const _EmptyWheel();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: Spacing.m),
            Text(AppLocalizations.of(context)!.addOneOption,
                textAlign: TextAlign.center),
          ],
        ),
      );
}
