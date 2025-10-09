import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF2D7FF9),
      secondary: const Color(0xFFF7D154),
      error: const Color(0xFFE34D4D),
      tertiary: const Color(0xFF28C76F),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    textTheme: base.textTheme.copyWith(
      displayMedium: base.textTheme.displayMedium?.copyWith(fontSize: 30),
    ),
  );
}

