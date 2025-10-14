import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.dark(
    background: AppPalette.background,
    surface: AppPalette.background,
    primary: AppPalette.accent,
    secondary: AppPalette.accentDark,
    error: AppColors.red,
    onBackground: AppPalette.textPrimary,
    onSurface: AppPalette.textPrimary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );
  final textTheme = base.textTheme.apply(
    bodyColor: AppPalette.textPrimary,
    displayColor: AppPalette.textPrimary,
  ).copyWith(
    // Resultado grande 28–32sp
    displayMedium: base.textTheme.displayMedium?.copyWith(fontSize: 30),
    titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 15),
    bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 13, color: AppPalette.textSecondary),
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.background,
    appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
    textTheme: textTheme,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0x33222A33),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
      labelStyle: TextStyle(color: AppPalette.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48), shape: const StadiumBorder()),
    ),
    tabBarTheme: const TabBarTheme(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xB3FFFFFF),
    ),
    dividerColor: AppPalette.separator,
  );
}
