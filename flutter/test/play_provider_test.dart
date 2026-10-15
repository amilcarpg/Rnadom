import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:decisor/core/constants.dart';
import 'package:decisor/state/play_provider.dart';

void main() {
  test('rejects concurrent requests across modes and unlocks after completion',
      () async {
    final provider = PlayProvider();
    final completion = Completer<void>();
    var coinPlays = 0;
    var numberPlays = 0;
    provider.register(ModeId.coin, () {
      coinPlays++;
      return completion.future;
    });
    provider.register(ModeId.number, () async {
      numberPlays++;
    });
    final first = provider.requestPlay(ModeId.coin);
    await provider.requestPlay(ModeId.coin);
    await provider.requestPlay(ModeId.number);
    expect(provider.playing, isTrue);
    expect(coinPlays, 1);
    expect(numberPlays, 0);
    completion.complete();
    await first;
    expect(provider.playing, isFalse);
    await provider.requestPlay(ModeId.number);
    expect(numberPlays, 1);
    provider.dispose();
  });

  test('unlocks after a failed action', () async {
    final provider = PlayProvider();
    provider.register(ModeId.coin, () async {
      throw StateError('test');
    });
    await expectLater(provider.requestPlay(ModeId.coin), throwsStateError);
    expect(provider.canPlay(ModeId.coin), isTrue);
    provider.dispose();
  });

  test('settles an in-flight request after provider disposal', () async {
    final provider = PlayProvider();
    final completion = Completer<void>();
    provider.register(ModeId.coin, () => completion.future);
    final play = provider.requestPlay(ModeId.coin);
    provider.dispose();
    completion.complete();
    await play;
    expect(provider.playing, isFalse);
    expect(provider.canPlay(ModeId.coin), isFalse);
  });
}
