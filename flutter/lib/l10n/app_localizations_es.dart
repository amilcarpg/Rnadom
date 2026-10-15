// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tira Suerte';

  @override
  String get selectMode => 'Elige un modo';

  @override
  String get history => 'Historial';

  @override
  String get settings => 'Ajustes';

  @override
  String get sound => 'Sonido';

  @override
  String get haptics => 'Vibración';

  @override
  String get language => 'Idioma';

  @override
  String get systemLanguage => 'Idioma del dispositivo';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get play => 'JUGAR';

  @override
  String get playing => 'JUGANDO…';

  @override
  String get clear => 'Limpiar';

  @override
  String get noPlays => 'Aún no hay jugadas.';

  @override
  String get coin => 'Cara o Sello';

  @override
  String get coinDescription => 'Lanza una moneda al azar.';

  @override
  String get number => 'Número aleatorio';

  @override
  String get numberRange => 'RANGO DEL SORTEO';

  @override
  String get numberDescription => 'Sortea un número dentro de un rango.';

  @override
  String get wheel4 => 'Ruleta 4 colores';

  @override
  String get wheel4Description => 'Gira una ruleta de cuatro colores.';

  @override
  String get wheelCustom => 'Ruleta personalizada';

  @override
  String get wheelCustomDescription => 'Crea y gira tu propia ruleta.';

  @override
  String get heads => 'Cara';

  @override
  String get tails => 'Sello';

  @override
  String get minimum => 'Mínimo';

  @override
  String get maximum => 'Máximo';

  @override
  String get invalidIntegers => 'Ingresa dos números enteros.';

  @override
  String get minimumLessThanMaximum =>
      'El mínimo debe ser menor que el máximo.';

  @override
  String get rangeLimit => 'Usa valores entre -1e9 y 1e9.';

  @override
  String get yellow => 'Amarillo';

  @override
  String get blue => 'Azul';

  @override
  String get red => 'Rojo';

  @override
  String get green => 'Verde';

  @override
  String get result => 'resultado';

  @override
  String get coinSemantic => 'Moneda';

  @override
  String get addOption => 'Agregar opción';

  @override
  String get editOption => 'Editar opción';

  @override
  String get optionText => 'Texto de la opción';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteOption => 'Eliminar opción';

  @override
  String deleteOptionConfirmation(Object label) {
    return '¿Eliminar \"$label\" de la ruleta?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String optionsCount(int count) {
    return '$count/12 opciones';
  }

  @override
  String get addOneOption => 'Agrega al menos una opción para jugar.';

  @override
  String color(Object name) {
    return 'Color $name';
  }

  @override
  String colorOf(Object label) {
    return 'Color de $label';
  }

  @override
  String edit(Object label) {
    return 'Editar $label';
  }

  @override
  String remove(Object label) {
    return 'Eliminar $label';
  }

  @override
  String get customColor => 'personalizado';

  @override
  String get editOptions => 'Editar opciones';

  @override
  String get equalChance => 'Todas las opciones tienen la misma probabilidad.';

  @override
  String get bulkOptions => 'Opciones, una por línea';

  @override
  String get optionsHelp =>
      'Una opción por línea · Hasta 60 caracteres por opción · Máximo 12.';

  @override
  String get foodPreset => 'Qué comemos';

  @override
  String get yesNoPreset => 'Sí / No';

  @override
  String get addExamples => 'Agregar ejemplo';

  @override
  String get foodOptions => 'Pizza\nPollo\nEnsalada';

  @override
  String get yesNoOptions => 'Sí\nNo';

  @override
  String get optionLimit => 'La ruleta admite un máximo de 12 opciones.';

  @override
  String get optionLengthLimit => 'Cada opción admite hasta 60 caracteres.';

  @override
  String get optionDeleted => 'Opción eliminada.';

  @override
  String get undo => 'Deshacer';

  @override
  String get historyDeleted => 'Historial eliminado.';

  @override
  String get sorting => 'Sorteando…';

  @override
  String get playError => 'No se pudo completar la jugada. Inténtalo de nuevo.';

  @override
  String get saveError =>
      'No se pudieron guardar los cambios en este dispositivo.';

  @override
  String get clearHistoryQuestion => '¿Eliminar el historial de jugadas?';
}
