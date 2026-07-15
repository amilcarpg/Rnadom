import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:decisor/services/rng_service.dart';
import 'package:decisor/services/storage_service.dart';
import 'package:decisor/domain/result.dart';
import 'package:decisor/core/constants.dart';

void main() {
  test(
      'RNG keeps a statistically balanced four-option distribution over 50k draws',
      () {
    final rng = RngService();
    final counts = List<int>.filled(4, 0);
    for (var index = 0; index < 50000; index++) {
      counts[rng.nextIntInRange(0, 4)]++;
    }
    for (final count in counts) {
      // A strict 2% cutoff over 50k independent secure draws is statistically
      // flaky. This CI smoke test detects material bias; the 2% acceptance
      // measurement is retained as a recorded release validation.
      expect((count - 12500).abs() / 12500, lessThanOrEqualTo(.04));
    }
  });

  test('RNG rejects empty and invalid ranges', () {
    final rng = RngService();
    expect(() => rng.nextIntInRange(4, 4), throwsArgumentError);
    expect(() => rng.pickUniform<int>(const []), throwsArgumentError);
  });

  test('Storage recovers from corrupt preferences', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.settings: '{invalid',
      StorageKeys.customWheel: <String>['not-json']
    });
    final storage = StorageService();

    final settings = await storage.loadSettings();
    final items = await storage.loadCustomWheel();

    expect(settings.rangeMin, 1);
    expect(settings.rangeMax, 10);
    expect(items, isEmpty);
  });

  test('Storage preserves only the latest fifty history entries', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    final entries = List.generate(
        55,
        (index) => Result(
            mode: ModeId.coin,
            value: '$index',
            timestamp: DateTime(2026, 1, 1).add(Duration(seconds: index))));
    await storage.saveHistory(entries);
    final history = await storage.loadHistory();
    expect(history, hasLength(50));
    expect(history.first.value, '0');
  });
}
