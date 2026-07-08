import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_tokens.dart';

class AppTheme {
  // Cores principais (derivadas de AppTokens — Fase 0)
  static const Color primaryColor = AppTokens.primary; // verde da marca
  static const Color secondaryColor = AppTokens.green900;
  static const Color tertiaryColor = AppTokens.accentPurpleMedium;
  static const Color errorColor = AppTokens.error;
  static const Color successColor = AppTokens.success;
  static const Color warningColor = AppTokens.warning;

  // Cores do Canfy
  static const Color canfyGreen = AppTokens.green800; // #00994B
  static const Color canfyPurple = AppTokens.accentPurple;

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: AppTokens.neutral000,
      ),
      scaffoldBackgroundColor: AppTokens.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: GoogleFonts.truculenta(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.truculenta(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        displayMedium: GoogleFonts.truculenta(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        displaySmall: GoogleFonts.truculenta(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineLarge: GoogleFonts.truculenta(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineMedium: GoogleFonts.truculenta(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineSmall: GoogleFonts.truculenta(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleLarge: GoogleFonts.truculenta(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleMedium: GoogleFonts.truculenta(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleSmall: GoogleFonts.truculenta(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        bodyLarge: GoogleFonts.arimo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF14181B),
        ),
        bodyMedium: GoogleFonts.arimo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF14181B),
        ),
        bodySmall: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelLarge: GoogleFonts.arimo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelMedium: GoogleFonts.arimo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelSmall: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
      ),
    );
  }

  // Tema escuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: Color(0xFF14181B),
      ),
      scaffoldBackgroundColor: const Color(0xFF1D2428),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: GoogleFonts.truculenta(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.truculenta(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.truculenta(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.truculenta(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.truculenta(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.truculenta(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.truculenta(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.truculenta(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.truculenta(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.truculenta(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.arimo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.arimo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelLarge: GoogleFonts.arimo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelMedium: GoogleFonts.arimo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelSmall: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = '__theme_mode__';
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs ??= await SharedPreferences.getInstance();
    final darkMode = _prefs?.getBool(_themeKey);
    if (darkMode != null) {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _prefs ??= await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await _prefs?.remove(_themeKey);
    } else {
      await _prefs?.setBool(_themeKey, mode == ThemeMode.dark);
    }
    notifyListeners();
  }
}

