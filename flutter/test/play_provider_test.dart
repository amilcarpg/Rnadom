import 'package:flutter_test/flutter_test.dart';

import 'package:decisor/core/constants.dart';
import 'package:decisor/state/play_provider.dart';

void main() {
  test(
      'PlayProvider dispatches only the requested mode and locks concurrent requests',
      () async {
    final provider = PlayProvider();
    var coinPlays = 0;
    var numberPlays = 0;
    provider.register(ModeId.coin, () async => coinPlays++);
    provider.register(ModeId.number, () async => numberPlays++);

    await provider.requestPlay(ModeId.coin);

    expect(coinPlays, 1);
    expect(numberPlays, 0);
  });
}
