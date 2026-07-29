import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color navy = Color(0xFF173278);
  static const Color blue = Color(0xFF2457E6);
  static const Color cyan = Color(0xFF11C5D9);
  static const Color cyanDark = Color(0xFF087F99);
  static const Color teal = Color(0xFF0F766E);

  // Backward-compatible aliases retained for existing engineering widgets.
  static const Color fuchsia = blue;
  static const Color fuchsiaBright = cyan;
  static const Color fuchsiaDark = navy;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.light,
      surface: Colors.white,
    ).copyWith(
      primary: blue,
      secondary: cyanDark,
      tertiary: teal,
      surface: Colors.white,
      surfaceContainerLowest: const Color(0xFFF8FAFD),
      surfaceContainerLow: const Color(0xFFF1F5F9),
      outlineVariant: const Color(0xFFDDE5EF),
    );
    return _theme(scheme, const Color(0xFFF4F7FB));
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F172A),
    ).copyWith(
      primary: const Color(0xFF60A5FA),
      secondary: const Color(0xFF22D3EE),
      tertiary: const Color(0xFF5EEAD4),
      surface: const Color(0xFF0F172A),
      surfaceContainerLowest: const Color(0xFF111B2E),
      surfaceContainerLow: const Color(0xFF172033),
      outlineVariant: const Color(0xFF334155),
    );
    return _theme(scheme, const Color(0xFF07111F));
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
            color: isDark ? const Color(0xFF22D3EE) : cyanDark,
            width: 1.8,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF164E63) : const Color(0xFFDBEAFE),
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
        indicatorColor: isDark ? const Color(0xFF164E63) : const Color(0xFFDBEAFE),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
