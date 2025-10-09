import 'package:flutter/material.dart';

class AppColors {
  static const yellow = Color(0xFFF7D154);
  static const blue = Color(0xFF2D7FF9);
  static const red = Color(0xFFE34D4D);
  static const green = Color(0xFF28C76F);
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

