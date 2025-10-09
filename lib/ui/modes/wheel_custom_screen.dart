import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/option_item.dart';
import '../../services/rng_service.dart';
import '../../services/analytics_service.dart';
import '../../services/storage_service.dart';
import '../../state/play_provider.dart';

class WheelCustomScreen extends StatefulWidget {
  const WheelCustomScreen({super.key});

  @override
  State<WheelCustomScreen> createState() => _WheelCustomScreenState();
}

class _WheelCustomScreenState extends State<WheelCustomScreen> {
  List<OptionItem> _items = const [];
  OptionItem? _selected;
  int _seenToken = 0;

  static const palette = <Color>[
    Color(0xFFF7D154),
    Color(0xFF2D7FF9),
    Color(0xFFE34D4D),
    Color(0xFF28C76F),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    final items = await storage.loadCustomWheel();
    setState(() => _items = items);
  }

  Future<void> _save() async {
    final storage = context.read<StorageService>();
    await storage.saveCustomWheel(_items);
  }

  Future<void> _play() async {
    if (_items.isEmpty) return;
    final play = context.read<PlayProvider>();
    final rng = context.read<RngService>();
    final analytics = context.read<AnalyticsService>();
    unawaited(analytics.logEvent('play_start', {'mode': 'wheel_custom'}));
    await play.runLocked(() async {
      setState(() => _selected = null);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final pick = rng.pickUniform(_items);
      setState(() => _selected = pick);
      unawaited(analytics.logEvent('play_result', {'mode': 'wheel_custom', 'value': pick.label}));
    });
  }

  Future<void> _addOrEdit([OptionItem? item]) async {
    final controller = TextEditingController(text: item?.label ?? '');
    Color color = item?.color ?? palette.first;
    final res = await showDialog<OptionItem>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateDialog) {
          return AlertDialog(
            title: Text(item == null ? 'Agregar opción' : 'Editar opción'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: controller, decoration: const InputDecoration(labelText: 'Texto')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in palette)
                      GestureDetector(
                        onTap: () => setStateDialog(() => color = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: c == color ? Colors.black : Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final next = OptionItem(id: item?.id ?? UniqueKey().toString(), label: text, color: color);
                  Navigator.pop(ctx2, next);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
    if (res != null) {
      setState(() {
        final idx = _items.indexWhere((e) => e.id == res.id);
        if (idx >= 0) {
          _items = [..._items]..[idx] = res;
        } else if (_items.length < 12) {
          _items = [..._items, res];
        }
      });
      await _save();
    }
  }

  void _remove(OptionItem item) async {
    setState(() => _items = _items.where((e) => e.id != item.id).toList(growable: false));
    await _save();
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
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _items.length >= 12 ? null : () => _addOrEdit(),
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
              const SizedBox(width: 8),
              Text('${_items.length}/12'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final it = _items[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: it.color),
                    title: Text(it.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEdit(it)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _remove(it)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'resultado',
            value: _selected?.label ?? '',
            liveRegion: true,
            child: Text(
              _selected?.label ?? '—',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }
}
