import 'package:flutter/material.dart';

class AppColors {
  static const yellow = Color(0xFFF7D154);
  static const blue = Color(0xFF2D7FF9);
  static const red = Color(0xFFE34D4D);
  static const green = Color(0xFF28C76F);
}

/// Paleta base de UI (lib/ui/AGENTS.md)
class AppPalette {
  static const background = Color(0xFF2C3E50); // ó 0xFF2D3250
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFBDC3C7); // ó 0xFFA9A9A9
  static const accent = Color(0xFF1ABC9C); // ó 0xFF4ECDC4
  static const accentDark = Color(0xFF16A085); // ó 0xFF3BA082
  static const separator = Color(0xFF4A6572); // ó 0xFF3B3B3B
}

/// Espaciado basado en grid de 8pt
class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
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
