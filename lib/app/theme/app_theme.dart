import 'package:flutter/material.dart';

const brandColor = Color(0xFF315CE8);
const inkColor = Color(0xFF17243B);
const mutedColor = Color(0xFF718096);
const canvasColor = Color(0xFFF5F7FB);
const lineColor = Color(0xFFE5EAF2);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandColor,
    brightness: Brightness.light,
    surface: Colors.white,
  );

  OutlineInputBorder inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvasColor,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: canvasColor,
      foregroundColor: inkColor,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: inkColor,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -.35,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: inkColor,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -.8,
      ),
      headlineSmall: TextStyle(
        color: inkColor,
        fontSize: 23,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
      ),
      titleLarge: TextStyle(
        color: inkColor,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -.25,
      ),
      titleMedium: TextStyle(
        color: inkColor,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: inkColor, fontSize: 14, height: 1.45),
      bodyMedium: TextStyle(color: mutedColor, fontSize: 13, height: 1.45),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: lineColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9AA5B5), fontSize: 13),
      labelStyle: const TextStyle(color: mutedColor, fontSize: 13),
      border: inputBorder(lineColor),
      enabledBorder: inputBorder(lineColor),
      focusedBorder: inputBorder(brandColor, width: 1.5),
      errorBorder: inputBorder(const Color(0xFFD64545)),
      focusedErrorBorder: inputBorder(const Color(0xFFD64545), width: 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: inkColor,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: lineColor),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFEAF0FF),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
        ),
      ),
    ),
    dividerColor: lineColor,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
