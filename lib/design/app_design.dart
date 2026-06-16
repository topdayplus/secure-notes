import 'package:flutter/material.dart';

class AppDesign {
  const AppDesign._();

  static const Color background = Color(0xFFF7F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color softSurface = Color(0xFFF1F4FB);
  static const Color ink = Color(0xFF111529);
  static const Color muted = Color(0xFF7D8496);
  static const Color primary = Color(0xFF4F63FF);
  static const Color primaryDark = Color(0xFF303FD8);
  static const Color amber = Color(0xFFB9C0D3);
  static const Color blueGrey = Color(0xFF697187);
  static const Color border = Color(0xFFE4E8F1);

  static const BorderRadius radius = BorderRadius.all(Radius.circular(18));
  static const BorderRadius softRadius = BorderRadius.all(Radius.circular(24));

  static ThemeData theme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: amber,
          tertiary: blueGrey,
          surface: surface,
          onSurface: ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softSurface,
        border: OutlineInputBorder(
          borderRadius: softRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: softRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: softRadius,
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: CircleBorder(),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          shape: const CircleBorder(),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: ink,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(color: muted),
      ),
    );
  }
}
