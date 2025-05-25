import 'package:flutter/material.dart';

class ThemeOption {
  final String name;
  final Color primary;
  final Color accent;
  late final LinearGradient gradient;

  ThemeOption({
    required this.name,
    required this.primary,
    required this.accent,
    LinearGradient? gradient,
  }) {
    this.gradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, accent],
    );
  }

  ThemeData toThemeData({bool isDark = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      secondary: accent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Gradient getGradientBackground() => gradient;
}

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  static AppTheme get instance => _instance;
  
  AppTheme._internal();

  ThemeOption _currentThemeOption = themeOptions[0];
  bool _isDark = false;

  // Ana renkler
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
  // Tema paletleri
  static final List<ThemeOption> themeOptions = [
    ThemeOption(
      name: 'Doğal',
      primary: Color(0xFF4CAF50),
      accent: Color(0xFF8BC34A),
    ),
    ThemeOption(
      name: 'Okyanus',
      primary: Color(0xFF0288D1),
      accent: Color(0xFF03A9F4),
    ),
    ThemeOption(
      name: 'Lavanta',
      primary: Color(0xFF7E57C2),
      accent: Color(0xFF9575CD),
    ),
    ThemeOption(
      name: 'Gün Batımı',
      primary: Color(0xFFFF7043),
      accent: Color(0xFFFFB74D),
    ),
  ];

  // Getters
  ThemeOption get currentThemeOption => _currentThemeOption;
  bool get isDark => _isDark;
  ThemeData get currentTheme => _currentThemeOption.toThemeData(isDark: _isDark);

  // Tema değiştirme metodları
  void setThemeOption(ThemeOption option) {
    _currentThemeOption = option;
  }

  void toggleDarkMode() {
    _isDark = !_isDark;
  }

  void setDarkMode(bool isDark) {
    _isDark = isDark;
  }
}
