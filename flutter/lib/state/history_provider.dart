import 'package:flutter/foundation.dart';

import '../domain/result.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({required this.storage});

  final StorageService storage;
  List<Result> _items = const [];
  bool _loading = true;

  List<Result> get items => _items;
  bool get loading => _loading;

  Future<void> load() async {
    _items = await storage.loadHistory();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Result result) async {
    _items = [result, ..._items].take(50).toList(growable: false);
    notifyListeners();
    await storage.saveHistory(_items);
  }

  Future<void> clear() async {
    _items = const [];
    notifyListeners();
    await storage.saveHistory(_items);
  }
}
