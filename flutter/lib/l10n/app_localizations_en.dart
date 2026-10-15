// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tira Suerte';

  @override
  String get selectMode => 'Choose a mode';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get sound => 'Sound';

  @override
  String get haptics => 'Vibration';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get play => 'PLAY';

  @override
  String get playing => 'PLAYING…';

  @override
  String get clear => 'Clear';

  @override
  String get noPlays => 'No plays yet.';

  @override
  String get coin => 'Heads or Tails';

  @override
  String get coinDescription => 'Flip a coin at random.';

  @override
  String get number => 'Random number';

  @override
  String get numberRange => 'DRAW RANGE';

  @override
  String get numberDescription => 'Draw a number from a range.';

  @override
  String get wheel4 => '4-color wheel';

  @override
  String get wheel4Description => 'Spin a wheel with four colors.';

  @override
  String get wheelCustom => 'Custom wheel';

  @override
  String get wheelCustomDescription => 'Create and spin your own wheel.';

  @override
  String get heads => 'Heads';

  @override
  String get tails => 'Tails';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get invalidIntegers => 'Enter two whole numbers.';

  @override
  String get minimumLessThanMaximum =>
      'The minimum must be less than the maximum.';

  @override
  String get rangeLimit => 'Use values between -1e9 and 1e9.';

  @override
  String get yellow => 'Yellow';

  @override
  String get blue => 'Blue';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get result => 'result';

  @override
  String get coinSemantic => 'Coin';

  @override
  String get addOption => 'Add option';

  @override
  String get editOption => 'Edit option';

  @override
  String get optionText => 'Option text';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteOption => 'Delete option';

  @override
  String deleteOptionConfirmation(Object label) {
    return 'Delete \"$label\" from the wheel?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String optionsCount(int count) {
    return '$count/12 options';
  }

  @override
  String get addOneOption => 'Add at least one option to play.';

  @override
  String color(Object name) {
    return 'Color $name';
  }

  @override
  String colorOf(Object label) {
    return 'Color of $label';
  }

  @override
  String edit(Object label) {
    return 'Edit $label';
  }

  @override
  String remove(Object label) {
    return 'Delete $label';
  }

  @override
  String get customColor => 'custom';

  @override
  String get editOptions => 'Edit options';

  @override
  String get equalChance => 'Every option has the same probability.';

  @override
  String get bulkOptions => 'Options, one per line';

  @override
  String get optionsHelp =>
      'One option per line · Up to 60 characters each · Maximum 12.';

  @override
  String get foodPreset => 'What to eat';

  @override
  String get yesNoPreset => 'Yes / No';

  @override
  String get addExamples => 'Add example';

  @override
  String get foodOptions => 'Pizza\nChicken\nSalad';

  @override
  String get yesNoOptions => 'Yes\nNo';

  @override
  String get optionLimit => 'The wheel supports up to 12 options.';

  @override
  String get optionLengthLimit => 'Each option supports up to 60 characters.';

  @override
  String get optionDeleted => 'Option deleted.';

  @override
  String get undo => 'Undo';

  @override
  String get historyDeleted => 'History deleted.';

  @override
  String get sorting => 'Drawing…';

  @override
  String get playError => 'Unable to complete the play. Please try again.';

  @override
  String get saveError => 'Changes could not be saved on this device.';

  @override
  String get clearHistoryQuestion => 'Delete the play history?';
}
