import 'package:flutter/material.dart';

class AppTheme {
  // -- Colors --
  static const Color bgDark = Color(0xFF0A0A12);
  static const Color bgCard = Color(0x14FFFFFF);
  static const Color borderLight = Color(0x2DFFFFFF);
  static const Color accentPrimary = Color(0xFF7C3AED);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF);
  static const Color textPlaceholder = Color(0x59FFFFFF);

  // Priority colors
  static const Color priorityLow = Color(0xFF6B7280);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityCritical = Color(0xFFEF4444);

  static Color priorityColor(int level) {
    return switch (level) {
      1 => priorityLow,
      2 => priorityMedium,
      3 => priorityHigh,
      4 => priorityCritical,
      _ => textSecondary,
    };
  }

  static String priorityLabel(int level) {
    return switch (level) {
      1 => 'Low',
      2 => 'Medium',
      3 => 'High',
      4 => 'Critical',
      _ => 'None',
    };
  }

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF7C3AED),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
    Color(0xFF64748B),
  ];

  static const List<String> categoryNames = [
    'Work',
    'Personal',
    'Health',
    'Finance',
    'Urgent',
    'Shopping',
    'Travel',
    'Learning',
    'Home',
    'Social',
    'Ideas',
    'Other',
  ];

  // -- Glassmorphism BoxDecoration --
  static BoxDecoration glassDecoration({
    double blur = 24,
    double radius = 20,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // -- Theme Data --
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentAmber,
        surface: bgDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedItemColor: accentPrimary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: textPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: textPlaceholder),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textPlaceholder),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
      ),
    );
  }
}
