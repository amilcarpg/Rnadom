import 'dart:math';

class RngService {
  final Random _secure;
  final Random _fallback = Random();
  RngService() : _secure = Random.secure();

  bool nextBool() {
    try {
      return _secure.nextBool();
    } catch (_) {
      return _fallback.nextBool();
    }
  }

  int nextIntInRange(int min, int maxExclusive) {
    final range = maxExclusive - min;
    if (range <= 0) throw ArgumentError('Invalid range: $min..$maxExclusive');
    try {
      return min + _secure.nextInt(range);
    } catch (_) {
      return min + _fallback.nextInt(range);
    }
  }

  T pickUniform<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('Empty list');
    final idx = nextIntInRange(0, items.length);
    return items[idx];
  }
}
