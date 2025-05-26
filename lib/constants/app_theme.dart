import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThemeOption {
  final String name;
  final Color primary;
  final Color accent;
  final Color surface;
  final Color secondary;
  late final LinearGradient gradient;
  late final LinearGradient cardGradient;
  late final LinearGradient shimmerGradient;

  ThemeOption({
    required this.name,
    required this.primary,
    required this.accent,
    Color? surface,
    Color? secondary,
    LinearGradient? gradient,
  }) : 
    surface = surface ?? primary.withOpacity(0.05),
    secondary = secondary ?? accent.withOpacity(0.8) {
    this.gradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary,
        primary.withOpacity(0.9),
        accent.withOpacity(0.8),
        accent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    this.cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.9),
        Colors.white.withOpacity(0.7),
        Colors.white.withOpacity(0.5),
      ],
    );
    
    this.shimmerGradient = LinearGradient(
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.0),
      ],
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
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Gradient getGradientBackground() => gradient;
  
  BoxShadow getPrimaryShadow({double opacity = 0.3}) => BoxShadow(
    color: primary.withOpacity(opacity),
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );
  
  BoxShadow getGlassShadow() => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );
  
  List<BoxShadow> getNeumorphismShadow({bool isPressed = false}) {
    return [
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: Offset(isPressed ? 2 : -6, isPressed ? 2 : -6),
        blurRadius: isPressed ? 4 : 12,
        spreadRadius: isPressed ? -2 : 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        offset: Offset(isPressed ? -2 : 6, isPressed ? -2 : 6),
        blurRadius: isPressed ? 4 : 12,
        spreadRadius: isPressed ? -2 : 0,
      ),
    ];
  }
}

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  static AppTheme get instance => _instance;
  
  AppTheme._internal();

  ThemeOption _currentThemeOption = themeOptions[0];
  bool _isDark = false;

  // Premium color palette
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFF1E293B);
  static const Color textColorLight = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);
  static const Color glassBg = Color(0x80FFFFFF);
  static const Color glassBlur = Color(0x40FFFFFF);
  
  // Premium tema paletleri
  static final List<ThemeOption> themeOptions = [
    ThemeOption(
      name: 'Emerald Dreams',
      primary: const Color(0xFF059669),
      accent: const Color(0xFF34D399),
      surface: const Color(0xFFF0FDF4),
      secondary: const Color(0xFF6EE7B7),
    ),
    ThemeOption(
      name: 'Ocean Breeze',
      primary: const Color(0xFF0EA5E9),
      accent: const Color(0xFF38BDF8),
      surface: const Color(0xFFF0F9FF),
      secondary: const Color(0xFF7DD3FC),
    ),
    ThemeOption(
      name: 'Purple Magic',
      primary: const Color(0xFF7C3AED),
      accent: const Color(0xFF8B5CF6),
      surface: const Color(0xFFF5F3FF),
      secondary: const Color(0xFFA78BFA),
    ),
    ThemeOption(
      name: 'Sunset Glow',
      primary: const Color(0xFFEA580C),
      accent: const Color(0xFFFB923C),
      surface: const Color(0xFFFFF7ED),
      secondary: const Color(0xFFFDBA74),
    ),
    ThemeOption(
      name: 'Rose Gold',
      primary: const Color(0xFFE11D48),
      accent: const Color(0xFFF43F5E),
      surface: const Color(0xFFFFF1F2),
      secondary: const Color(0xFFFB7185),
    ),
    ThemeOption(
      name: 'Midnight Blue',
      primary: const Color(0xFF1E40AF),
      accent: const Color(0xFF3B82F6),
      surface: const Color(0xFFEFF6FF),
      secondary: const Color(0xFF60A5FA),
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
  
  // Premium visual effects
  static BoxDecoration getGlassmorphismDecoration({
    Color? color,
    double borderRadius = 20,
    double blur = 15,
  }) {
    return BoxDecoration(
      color: color ?? glassBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }
  
  static BoxDecoration getNeumorphismDecoration({
    Color? backgroundColor,
    double borderRadius = 20,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.white,
          offset: Offset(isPressed ? 2 : -6, isPressed ? 2 : -6),
          blurRadius: isPressed ? 4 : 12,
          spreadRadius: isPressed ? -2 : 0,
        ),
        BoxShadow(
          color: const Color(0xFFBECBE8).withOpacity(0.4),
          offset: Offset(isPressed ? -2 : 6, isPressed ? -2 : 6),
          blurRadius: isPressed ? 4 : 12,
          spreadRadius: isPressed ? -2 : 0,
        ),
      ],
    );
  }
  
  static Gradient getShimmerGradient() {
    return const LinearGradient(
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
      colors: [
        Color(0x00FFFFFF),
        Color(0x4DFFFFFF),
        Color(0x00FFFFFF),
      ],
    );
  }
}
