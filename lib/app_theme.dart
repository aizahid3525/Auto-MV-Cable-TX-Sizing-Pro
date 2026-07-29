import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color fuchsia = Color(0xFFC2185B);
  static const Color fuchsiaBright = Color(0xFFE91E63);
  static const Color fuchsiaDark = Color(0xFF880E4F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: fuchsia,
      brightness: Brightness.light,
      surface: const Color(0xFFFFF8FB),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFFF8FB),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: fuchsia, width: 2),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        indicatorColor: Color(0xFFF8DCE8),
        selectedIconTheme: IconThemeData(color: fuchsiaDark),
        selectedLabelTextStyle: TextStyle(
          color: fuchsiaDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: fuchsiaBright,
      brightness: Brightness.dark,
      surface: const Color(0xFF211820),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF151014),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF211820),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: fuchsiaBright, width: 2),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        indicatorColor: Color(0xFF4A1830),
        selectedIconTheme: IconThemeData(color: Color(0xFFFF78AA)),
        selectedLabelTextStyle: TextStyle(
          color: Color(0xFFFF9DBF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
