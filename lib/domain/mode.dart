import '../core/constants.dart';

class Mode {
  final ModeId id;
  final String name;
  const Mode({required this.id, required this.name});
}

const modes = <Mode>[
  Mode(id: ModeId.coin, name: 'Cara o Sello'),
  Mode(id: ModeId.number, name: 'Número aleatorio'),
  Mode(id: ModeId.wheel4, name: 'Ruleta 4 colores'),
  Mode(id: ModeId.wheelCustom, name: 'Ruleta personalizada'),
];

