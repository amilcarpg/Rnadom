import 'package:flutter/material.dart';

class AppColors {
  static const yellow = Color(0xFFF7D154);
  static const blue = Color(0xFF2D7FF9);
  static const red = Color(0xFFE34D4D);
  static const green = Color(0xFF28C76F);
  static const purple = Color(0xFF9C27B0);
  static const cyan = Color(0xFF00BCD4);
  static const orange = Color(0xFFFF8A1F);
  static const pink = Color(0xFFEC4899);
  static const indigo = Color(0xFF6366F1);
  static const lime = Color(0xFF84CC16);
}

/// Paleta base de UI (lib/ui/AGENTS.md)
class AppPalette {
  static const background = Color(0xFF020D1B);
  static const surface = Color(0xFF091A2B);
  static const surfaceStrong = Color(0xFF061524);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAEB8C7);
  static const accent = Color(0xFF12D6C1);
  static const accentDark = Color(0xFF079D98);
  static const separator = Color(0xFF294057);
}

/// Espaciado basado en grid de 8pt
class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

class AppRadii {
  static const double small = 12;
  static const double medium = 20;
  static const double pill = 24;
}

class AppSizes {
  static const double minTouchTarget = 48;
  static const double contentWidth = 520;
  static const double wheelSize = 240;
  static const double coinSize = 140;
  static const double coinSymbolSize = 64;
  static const double numberInputHeight = 104;
  static const double numberResultHeight = 128;
}

class AppLimits {
  static const int minSuggested = -1000000000; // -1e9
  static const int maxSuggested = 1000000000; // 1e9
}

enum ModeId {
  coin,
  number,
  wheel4,
  wheelCustom,
}
