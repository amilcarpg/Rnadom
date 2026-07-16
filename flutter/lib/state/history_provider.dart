import 'package:flutter/foundation.dart';

import '../domain/result.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({required this.storage});

  final StorageService storage;
  List<Result> _items = const [];
  bool _loading = true;
  Future<void> _writeQueue = Future.value();

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
    final snapshot = _items;
    await _enqueueSave(snapshot);
  }

  Future<void> clear() async {
    _items = const [];
    notifyListeners();
    await _enqueueSave(_items);
  }

  Future<void> _enqueueSave(List<Result> snapshot) {
    final write = _writeQueue.then<void>((_) => storage.saveHistory(snapshot));
    // A failed save is isolated so the next add/clear can still persist.
    _writeQueue = write.catchError((_) {});
    return write;
  }
}
