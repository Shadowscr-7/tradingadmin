import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF18122B),
    primaryColor: const Color(0xFF7F27FF),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF7F27FF),
      secondary: const Color(0xFF9F70FD),
      background: const Color(0xFF18122B),
      surface: const Color(0xFF393053),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF393053),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Color(0xFF7F27FF)),
      ),
    ),
    cardColor: const Color(0xFF393053),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF18122B)),
    iconTheme: const IconThemeData(color: Color(0xFF7F27FF)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF7F27FF),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF393053),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Color(0xFF7F27FF)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF7F27FF),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF7F27FF),
    ),
  );
}
