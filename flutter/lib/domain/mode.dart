import 'package:flutter/widgets.dart';

import '../core/constants.dart';
import '../l10n/app_localizations.dart';

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

extension ModeLocalization on Mode {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case ModeId.coin:
        return l10n.coin;
      case ModeId.number:
        return l10n.number;
      case ModeId.wheel4:
        return l10n.wheel4;
      case ModeId.wheelCustom:
        return l10n.wheelCustom;
    }
  }
}
