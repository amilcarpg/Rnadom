import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decisor/core/accessibility.dart';
import 'package:decisor/core/constants.dart';
import 'package:decisor/services/rng_service.dart';
import 'package:decisor/services/analytics_service.dart';
import 'package:decisor/state/play_provider.dart';
import 'package:decisor/ui/app.dart';
import 'package:decisor/ui/modes/coin_screen.dart';
import 'package:decisor/ui/widgets/options_editor.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('RNG falls back when secure construction fails', () {
    final expected = Random(42);
    final rng = RngService(
        secureFactory: () => throw UnsupportedError('test'),
        fallback: Random(42));
    for (var index = 0; index < 100; index++) {
      expect(rng.nextIntInRange(-10, 11), -10 + expected.nextInt(21));
    }
  });

  test('all wheel palette text pairs meet normal-text contrast', () {
    for (final color in [
      ...AppColors.wheelPalette,
      AppPalette.accent,
      AppPalette.accentDark
    ]) {
      final background = color.computeLuminance();
      final foreground = readableForeground(color).computeLuminance();
      expect(
          (max(background, foreground) + .05) /
              (min(background, foreground) + .05),
          greaterThanOrEqualTo(4.5));
    }
  });

  test('analytics normalizes SDK parameters and isolates SDK errors', () async {
    Map<String, Object>? recorded;
    final analytics = AnalyticsService(writer: (name, values) async {
      recorded = values;
    });
    await analytics.logEvent(
        'settings_changed', {'sound': false, 'haptics': true, 'ignored': null});
    expect(recorded, {'sound': 0, 'haptics': 1});
    await AnalyticsService(writer: (_, __) async {
      throw StateError('offline');
    }).logEvent('play_start', {'mode': 'coin'});
  });

  testWidgets('disposing a spinning screen releases the play lock',
      (tester) async {
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    final provider =
        tester.element(find.byType(CoinScreen)).read<PlayProvider>();
    final play = provider.requestPlay(ModeId.coin);
    await tester.pump(const Duration(milliseconds: 100));
    expect(provider.playing, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await play;
    expect(provider.playing, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mode navigation is blocked until the current result is shown',
      (tester) async {
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAY'));
    await tester.pump(const Duration(milliseconds: 100));
    final provider =
        tester.element(find.byType(CoinScreen)).read<PlayProvider>();
    expect(provider.playing, isTrue);
    await tester.tap(find.text('Heads or Tails'));
    await tester.pump();
    expect(find.text('Choose a mode'), findsNothing);
    await tester.pumpAndSettle();
    expect(provider.playing, isFalse);
  });
  testWidgets(
      'bulk editor saves options, supports undo, and survives a restart',
      (tester) async {
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heads or Tails'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Custom wheel'), 100,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom wheel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit options'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alpha\nBeta\nGamma');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final listScroller1 = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(OptionsEditor), matching: find.byType(Scrollable))
        .first);
    listScroller1.position.jumpTo(listScroller1.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('3/12 options'), findsWidgets);
    expect(
        tester
            .element(find.byType(OptionsEditor))
            .read<PlayProvider>()
            .canPlay(ModeId.wheelCustom),
        isFalse);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    await tester.ensureVisible(find.byTooltip('Delete Beta'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Beta'));
    await tester.pumpAndSettle();
    expect(find.text('2/12 options'), findsWidgets);
    await tester.ensureVisible(find.text('Undo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('3/12 options'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heads or Tails'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Custom wheel'), 100,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom wheel'));
    await tester.pumpAndSettle();
    expect(find.text('3/12 options'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('number game scrolls with a keyboard on a small screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heads or Tails'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Random number'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Random number'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).first);
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('PLAY'), findsOneWidget);
  });
  testWidgets(
      'custom editor handles large text and enforces the 12 option limit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 1.7;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const DecisorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heads or Tails'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Custom wheel'), 100,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom wheel'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit options'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField),
        List.generate(13, (i) => 'Option $i').join('\n'));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final listScroller2 = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(OptionsEditor), matching: find.byType(Scrollable))
        .first);
    listScroller2.position.jumpTo(listScroller2.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('The wheel supports up to 12 options.'), findsOneWidget);
    listScroller2.position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alpha\nBeta');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final listScroller3 = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(OptionsEditor), matching: find.byType(Scrollable))
        .first);
    listScroller3.position.jumpTo(listScroller3.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('Edit Alpha'), 100,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit Alpha'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextField)),
        'Updated');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsWidgets);
    Navigator.of(tester.element(find.byType(OptionsEditor))).pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
