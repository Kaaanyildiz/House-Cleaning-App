import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF303030);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFD54F);
  static const Color textColor = Color(0xFF212121);
  static const Color textColorLight = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x29000000);

  // Tema varyasyonları
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColorLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textColor),
        displayMedium: TextStyle(color: textColor),
        displaySmall: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: textColorLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF424242),
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF424242),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF616161)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textColorLight),
        displayMedium: TextStyle(color: textColorLight),
        displaySmall: TextStyle(color: textColorLight),
        headlineMedium: TextStyle(color: textColorLight),
        headlineSmall: TextStyle(color: textColorLight),
        titleLarge: TextStyle(color: textColorLight, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textColorLight),
        bodyMedium: TextStyle(color: textColorLight),
      ),
    );
  }
}
