import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF4B39EF);
  static const Color secondaryColor = Color(0xFF39D2C0);
  static const Color tertiaryColor = Color(0xFFEE8B60);
  static const Color errorColor = Color(0xFFFF5963);
  static const Color successColor = Color(0xFF249689);
  static const Color warningColor = Color(0xFFF9CF58);
  
  // Cores do Canfy
  static const Color canfyGreen = Color(0xFF00994B); // green-800 do Figma
  static const Color canfyPurple = Color(0xFF9C27B0); // Roxo para gradiente

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
        surface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F4F8),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: GoogleFonts.interTight(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.interTight(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        displayMedium: GoogleFonts.interTight(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        displaySmall: GoogleFonts.interTight(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineLarge: GoogleFonts.interTight(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineMedium: GoogleFonts.interTight(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        headlineSmall: GoogleFonts.interTight(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleLarge: GoogleFonts.interTight(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleMedium: GoogleFonts.interTight(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        titleSmall: GoogleFonts.interTight(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF14181B),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF14181B),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF14181B),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF57636C),
        ),
        labelSmall: GoogleFonts.inter(
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
        titleTextStyle: GoogleFonts.interTight(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.interTight(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.interTight(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.interTight(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.interTight(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.interTight(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.interTight(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.interTight(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.interTight(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.interTight(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF95A1AC),
        ),
        labelSmall: GoogleFonts.inter(
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

