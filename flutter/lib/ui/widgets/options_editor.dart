import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../domain/option_item.dart';
import '../../l10n/app_localizations.dart';

class OptionsEditor extends StatefulWidget {
  const OptionsEditor(
      {super.key, required this.items, required this.onChanged});
  final List<OptionItem> items;
  final Future<void> Function(List<OptionItem>) onChanged;

  @override
  State<OptionsEditor> createState() => _OptionsEditorState();
}

class _OptionsEditorState extends State<OptionsEditor> {
  late List<OptionItem> _items;
  final _input = TextEditingController();
  final _focus = FocusNode();
  Color _color = AppColors.yellow;
  String? _error;
  OptionItem? _removed;
  int _removedIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _apply(List<OptionItem> next) async {
    setState(() {
      _items = next;
      _error = null;
    });
    try {
      await widget.onChanged(List.unmodifiable(next));
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.saveError);
      }
    }
  }

  Future<void> _add([String? preset]) async {
    final l10n = AppLocalizations.of(context)!;
    final labels = (preset ?? _input.text)
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();
    if (labels.isEmpty) {
      setState(() => _error = l10n.addOneOption);
      return;
    }
    if (labels.any((label) => label.length > AppLimits.maxLabelLength)) {
      setState(() => _error = l10n.optionLengthLimit);
      return;
    }
    if (_items.length + labels.length > AppLimits.maxOptions) {
      setState(() => _error = l10n.optionLimit);
      return;
    }
    final next = [..._items];
    final batch = DateTime.now().microsecondsSinceEpoch;
    for (var index = 0; index < labels.length; index++) {
      next.add(OptionItem(
          id: '$batch-$index',
          label: labels[index],
          color: index == 0
              ? _color
              : AppColors
                  .wheelPalette[next.length % AppColors.wheelPalette.length]));
    }
    _input.clear();
    await _apply(next);
    if (mounted && preset == null) _focus.requestFocus();
  }

  Future<void> _edit(OptionItem item) async {
    final updated = await showDialog<OptionItem>(
      context: context,
      builder: (_) => _OptionDialog(item: item),
    );
    if (!mounted || updated == null) return;
    await _apply(
        _items.map((value) => value.id == item.id ? updated : value).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final full = _items.length >= AppLimits.maxOptions;
    return SafeArea(
        top: false,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child:
                ListView(padding: const EdgeInsets.all(Spacing.l), children: [
              Text(l10n.editOptions,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(l10n.optionsCount(_items.length),
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: Spacing.m),
              TextField(
                  controller: _input,
                  focusNode: _focus,
                  minLines: 2,
                  maxLines: 4,
                  maxLength:
                      (AppLimits.maxLabelLength + 1) * AppLimits.maxOptions,
                  enabled: !full,
                  decoration: InputDecoration(labelText: l10n.bulkOptions)),
              Text(l10n.optionsHelp,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: Spacing.s),
              _colorPicker(
                  context, _color, (color) => setState(() => _color = color)),
              FilledButton.icon(
                  onPressed: full ? null : () => _add(),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.add)),
              const SizedBox(height: Spacing.s),
              Text(l10n.addExamples,
                  style: Theme.of(context).textTheme.bodySmall),
              Wrap(spacing: Spacing.s, children: [
                TextButton(
                    onPressed: full ? null : () => _add(l10n.foodOptions),
                    child: Text(l10n.foodPreset)),
                TextButton(
                    onPressed: full ? null : () => _add(l10n.yesNoOptions),
                    child: Text(l10n.yesNoPreset)),
              ]),
              if (_error != null)
                Semantics(
                    liveRegion: true,
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              if (_removed != null)
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(l10n.optionDeleted),
                  TextButton(
                      onPressed: full
                          ? null
                          : () {
                              final next = [..._items];
                              next.insert(_removedIndex.clamp(0, next.length),
                                  _removed!);
                              setState(() => _removed = null);
                              _apply(next);
                            },
                      child: Text(l10n.undo)),
                ]),
              for (final item in _items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ExcludeSemantics(
                      child: CircleAvatar(backgroundColor: item.color)),
                  title: Text(item.label),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        tooltip: l10n.edit(item.label),
                        onPressed: () => _edit(item),
                        icon: const Icon(Icons.edit_outlined)),
                    IconButton(
                        tooltip: l10n.remove(item.label),
                        onPressed: () {
                          _removedIndex = _items.indexOf(item);
                          _removed = item;
                          _apply(_items
                              .where((value) => value.id != item.id)
                              .toList());
                        },
                        icon: const Icon(Icons.delete_outline)),
                  ]),
                ),
            ]),
          ),
        ));
  }
}

class _OptionDialog extends StatefulWidget {
  const _OptionDialog({required this.item});
  final OptionItem item;
  @override
  State<_OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<_OptionDialog> {
  late final TextEditingController _controller;
  late Color _color;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.label);
    _color = widget.item.color;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.editOption),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: _controller,
            autofocus: true,
            maxLength: AppLimits.maxLabelLength,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.optionText)),
        const SizedBox(height: Spacing.m),
        _colorPicker(
            context, _color, (value) => setState(() => _color = value)),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => Navigator.pop(
                    context,
                    widget.item.copyWith(
                        label: _controller.text.trim(), color: _color)),
            child: Text(l10n.save)),
      ],
    );
  }
}

Widget _colorPicker(
    BuildContext context, Color selected, ValueChanged<Color> onChanged) {
  final l10n = AppLocalizations.of(context)!;
  return Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: [
    for (var index = 0; index < AppColors.wheelPalette.length; index++)
      Semantics(
          selected: selected == AppColors.wheelPalette[index],
          child: IconButton(
            tooltip: l10n.color(index + 1),
            onPressed: () => onChanged(AppColors.wheelPalette[index]),
            icon: Icon(
                selected == AppColors.wheelPalette[index]
                    ? Icons.check_circle
                    : Icons.circle,
                color: AppColors.wheelPalette[index]),
          )),
  ]);
}
