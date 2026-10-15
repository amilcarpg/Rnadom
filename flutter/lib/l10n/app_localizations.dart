import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Tira Suerte'**
  String get appTitle;

  /// No description provided for @selectMode.
  ///
  /// In es, this message translates to:
  /// **'Elige un modo'**
  String get selectMode;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @sound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get sound;

  /// No description provided for @haptics.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get haptics;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma del dispositivo'**
  String get systemLanguage;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @play.
  ///
  /// In es, this message translates to:
  /// **'JUGAR'**
  String get play;

  /// No description provided for @playing.
  ///
  /// In es, this message translates to:
  /// **'JUGANDO…'**
  String get playing;

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @noPlays.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay jugadas.'**
  String get noPlays;

  /// No description provided for @coin.
  ///
  /// In es, this message translates to:
  /// **'Cara o Sello'**
  String get coin;

  /// No description provided for @coinDescription.
  ///
  /// In es, this message translates to:
  /// **'Lanza una moneda al azar.'**
  String get coinDescription;

  /// No description provided for @number.
  ///
  /// In es, this message translates to:
  /// **'Número aleatorio'**
  String get number;

  /// No description provided for @numberRange.
  ///
  /// In es, this message translates to:
  /// **'RANGO DEL SORTEO'**
  String get numberRange;

  /// No description provided for @numberDescription.
  ///
  /// In es, this message translates to:
  /// **'Sortea un número dentro de un rango.'**
  String get numberDescription;

  /// No description provided for @wheel4.
  ///
  /// In es, this message translates to:
  /// **'Ruleta 4 colores'**
  String get wheel4;

  /// No description provided for @wheel4Description.
  ///
  /// In es, this message translates to:
  /// **'Gira una ruleta de cuatro colores.'**
  String get wheel4Description;

  /// No description provided for @wheelCustom.
  ///
  /// In es, this message translates to:
  /// **'Ruleta personalizada'**
  String get wheelCustom;

  /// No description provided for @wheelCustomDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea y gira tu propia ruleta.'**
  String get wheelCustomDescription;

  /// No description provided for @heads.
  ///
  /// In es, this message translates to:
  /// **'Cara'**
  String get heads;

  /// No description provided for @tails.
  ///
  /// In es, this message translates to:
  /// **'Sello'**
  String get tails;

  /// No description provided for @minimum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get maximum;

  /// No description provided for @invalidIntegers.
  ///
  /// In es, this message translates to:
  /// **'Ingresa dos números enteros.'**
  String get invalidIntegers;

  /// No description provided for @minimumLessThanMaximum.
  ///
  /// In es, this message translates to:
  /// **'El mínimo debe ser menor que el máximo.'**
  String get minimumLessThanMaximum;

  /// No description provided for @rangeLimit.
  ///
  /// In es, this message translates to:
  /// **'Usa valores entre -1e9 y 1e9.'**
  String get rangeLimit;

  /// No description provided for @yellow.
  ///
  /// In es, this message translates to:
  /// **'Amarillo'**
  String get yellow;

  /// No description provided for @blue.
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get blue;

  /// No description provided for @red.
  ///
  /// In es, this message translates to:
  /// **'Rojo'**
  String get red;

  /// No description provided for @green.
  ///
  /// In es, this message translates to:
  /// **'Verde'**
  String get green;

  /// No description provided for @result.
  ///
  /// In es, this message translates to:
  /// **'resultado'**
  String get result;

  /// No description provided for @coinSemantic.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get coinSemantic;

  /// No description provided for @addOption.
  ///
  /// In es, this message translates to:
  /// **'Agregar opción'**
  String get addOption;

  /// No description provided for @editOption.
  ///
  /// In es, this message translates to:
  /// **'Editar opción'**
  String get editOption;

  /// No description provided for @optionText.
  ///
  /// In es, this message translates to:
  /// **'Texto de la opción'**
  String get optionText;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @deleteOption.
  ///
  /// In es, this message translates to:
  /// **'Eliminar opción'**
  String get deleteOption;

  /// No description provided for @deleteOptionConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{label}\" de la ruleta?'**
  String deleteOptionConfirmation(Object label);

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @optionsCount.
  ///
  /// In es, this message translates to:
  /// **'{count}/12 opciones'**
  String optionsCount(int count);

  /// No description provided for @addOneOption.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos una opción para jugar.'**
  String get addOneOption;

  /// No description provided for @color.
  ///
  /// In es, this message translates to:
  /// **'Color {name}'**
  String color(Object name);

  /// No description provided for @colorOf.
  ///
  /// In es, this message translates to:
  /// **'Color de {label}'**
  String colorOf(Object label);

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar {label}'**
  String edit(Object label);

  /// No description provided for @remove.
  ///
  /// In es, this message translates to:
  /// **'Eliminar {label}'**
  String remove(Object label);

  /// No description provided for @customColor.
  ///
  /// In es, this message translates to:
  /// **'personalizado'**
  String get customColor;

  /// No description provided for @editOptions.
  ///
  /// In es, this message translates to:
  /// **'Editar opciones'**
  String get editOptions;

  /// No description provided for @equalChance.
  ///
  /// In es, this message translates to:
  /// **'Todas las opciones tienen la misma probabilidad.'**
  String get equalChance;

  /// No description provided for @bulkOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones, una por línea'**
  String get bulkOptions;

  /// No description provided for @optionsHelp.
  ///
  /// In es, this message translates to:
  /// **'Una opción por línea · Hasta 60 caracteres por opción · Máximo 12.'**
  String get optionsHelp;

  /// No description provided for @foodPreset.
  ///
  /// In es, this message translates to:
  /// **'Qué comemos'**
  String get foodPreset;

  /// No description provided for @yesNoPreset.
  ///
  /// In es, this message translates to:
  /// **'Sí / No'**
  String get yesNoPreset;

  /// No description provided for @addExamples.
  ///
  /// In es, this message translates to:
  /// **'Agregar ejemplo'**
  String get addExamples;

  /// No description provided for @foodOptions.
  ///
  /// In es, this message translates to:
  /// **'Pizza\nPollo\nEnsalada'**
  String get foodOptions;

  /// No description provided for @yesNoOptions.
  ///
  /// In es, this message translates to:
  /// **'Sí\nNo'**
  String get yesNoOptions;

  /// No description provided for @optionLimit.
  ///
  /// In es, this message translates to:
  /// **'La ruleta admite un máximo de 12 opciones.'**
  String get optionLimit;

  /// No description provided for @optionLengthLimit.
  ///
  /// In es, this message translates to:
  /// **'Cada opción admite hasta 60 caracteres.'**
  String get optionLengthLimit;

  /// No description provided for @optionDeleted.
  ///
  /// In es, this message translates to:
  /// **'Opción eliminada.'**
  String get optionDeleted;

  /// No description provided for @undo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// No description provided for @historyDeleted.
  ///
  /// In es, this message translates to:
  /// **'Historial eliminado.'**
  String get historyDeleted;

  /// No description provided for @sorting.
  ///
  /// In es, this message translates to:
  /// **'Sorteando…'**
  String get sorting;

  /// No description provided for @playError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la jugada. Inténtalo de nuevo.'**
  String get playError;

  /// No description provided for @saveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios en este dispositivo.'**
  String get saveError;

  /// No description provided for @clearHistoryQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el historial de jugadas?'**
  String get clearHistoryQuestion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
