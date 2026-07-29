import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // Controlled professional fuchsia palette. Existing aliases are retained so
  // legacy widgets inherit the new identity without duplicating colour logic.
  static const Color navy = Color(0xFF581C87);
  static const Color blue = Color(0xFFC026D3);
  static const Color cyan = Color(0xFFF0ABFC);
  static const Color cyanDark = Color(0xFFA21CAF);
  static const Color teal = Color(0xFF86198F);

  static const Color fuchsia = blue;
  static const Color fuchsiaBright = cyan;
  static const Color fuchsiaDark = navy;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: fuchsia,
      brightness: Brightness.light,
      surface: Colors.white,
    ).copyWith(
      primary: fuchsia,
      secondary: cyanDark,
      tertiary: const Color(0xFFE879F9),
      surface: Colors.white,
      surfaceContainerLowest: const Color(0xFFFFFBFF),
      surfaceContainerLow: const Color(0xFFFDF4FF),
      outlineVariant: const Color(0xFFEAD7EF),
    );
    return _theme(scheme, const Color(0xFFFBF7FC));
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: fuchsiaBright,
      brightness: Brightness.dark,
      surface: const Color(0xFF1B1020),
    ).copyWith(
      primary: const Color(0xFFF0ABFC),
      secondary: const Color(0xFFE879F9),
      tertiary: const Color(0xFFF5D0FE),
      surface: const Color(0xFF1B1020),
      surfaceContainerLowest: const Color(0xFF211226),
      surfaceContainerLow: const Color(0xFF2B1732),
      outlineVariant: const Color(0xFF5A3564),
    );
    return _theme(scheme, const Color(0xFF120A16));
  }

  static ThemeData _theme(ColorScheme scheme, Color scaffold) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        suffixStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFF0ABFC) : cyanDark,
            width: 1.8,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF701A75) : const Color(0xFFFAE8FF),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
            color: scheme.onSurface,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF701A75) : const Color(0xFFFAE8FF),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
