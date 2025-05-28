import 'package:flutter/material.dart';
import 'package:house_cleaning/constants/app_theme.dart';

/// Bu helper sınıfı, karanlık tema uyarlamaları için kullanılabilir
class DarkThemeHelper {
  /// Özel container için arka plan rengini döndürür
  static Color getContainerBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
  }
  
  /// Özel container için border rengini döndürür
  static Color getContainerBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? Colors.white.withOpacity(0.1) 
        : Colors.white.withOpacity(0.2);
  }
  
  /// Özel container için gölge rengini döndürür
  static Color getShadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? Colors.black.withOpacity(0.3) 
        : Colors.black.withOpacity(0.1);
  }
  
  /// Özel container için glassmorphism dekorasyonunu döndürür
  static BoxDecoration getGlassDecoration(BuildContext context, {
    Color? color, 
    double borderRadius = 20,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: color ?? (isDark 
          ? Colors.grey[900]!.withOpacity(0.5)  
          : Colors.white.withOpacity(0.7)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark 
              ? Colors.black.withOpacity(0.3) 
              : Colors.black.withOpacity(0.1),
          blurRadius: isDark ? 10 : 20,
          offset: const Offset(0, 5),
          spreadRadius: isDark ? -2 : -4,
        ),
      ],
    );
  }
  
  /// Özel container için gradient'i döndürür
  static LinearGradient getContainerGradient(BuildContext context, ThemeOption themeOption) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              themeOption.primary.withOpacity(0.4),
              themeOption.accent.withOpacity(0.3),
            ]
          : [
              themeOption.primary,
              themeOption.accent,
            ],
    );
  }
  
  /// Özel icon için rengi döndürür
  static Color getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[300]! : Colors.grey[600]!;
  }
  
  /// Özel text için rengi döndürür
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isSecondary) {
      return isDark ? Colors.grey[400]! : Colors.grey[700]!;
    }
    
    return isDark ? Colors.white : const Color(0xFF1E293B);
  }
  
  /// Özel neumorphism için dekorasyonu döndürür
  static BoxDecoration getNeumorphismDecoration(BuildContext context, {
    Color? backgroundColor,
    double borderRadius = 20,
    bool isPressed = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: backgroundColor ?? (isDark 
          ? const Color(0xFF2D3748) 
          : const Color(0xFFE2E8F0)),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isDark 
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: Offset(isPressed ? 2 : -3, isPressed ? 2 : -3),
                blurRadius: isPressed ? 3 : 6,
                spreadRadius: isPressed ? -1 : -1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                offset: Offset(isPressed ? -2 : 3, isPressed ? -2 : 3),
                blurRadius: isPressed ? 3 : 6,
                spreadRadius: isPressed ? -1 : -2,
              ),
            ]
          : [
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
}
