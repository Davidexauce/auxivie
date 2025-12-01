import 'package:flutter/material.dart';

/// Configuration du thème de l'application Auxivie - Palette CareLink
class AppTheme {
  // Couleurs principales CareLink
  static const Color primary = Color(0xFF16a34a); // green-600
  static const Color primaryDark = Color(0xFF15803d); // green-700
  static const Color primaryLight = Color(0xFF22c55e); // green-500
  static const Color accent = Color(0xFF86efac); // green-300
  static const Color emerald = Color(0xFF10b981); // emerald-500
  static const Color emeraldDark = Color(0xFF059669); // emerald-600
  
  // Arrière-plans
  static const Color background = Color(0xFFf6fbf8); // muted
  static const Color cardBackground = Color(0xFFFFFFFF); // white
  static const Color green50 = Color(0xFFf0fdf4);
  static const Color green100 = Color(0xFFdcfce7);
  static const Color green200 = Color(0xFFbbf7d0);
  
  // Texte
  static const Color textPrimary = Color(0xFF0b1220); // foreground
  static const Color textSecondary = Color(0xFF334155); // slate-700
  static const Color textTertiary = Color(0xFF475569); // slate-600
  static const Color textDark = Color(0xFF1e293b); // slate-800
  static const Color textGreen = Color(0xFF166534); // green-800/900
  
  // Bordures
  static const Color borderLight = Color(0xFFdcfce7); // green-100
  static const Color borderSlate = Color(0xFFe2e8f0); // slate-200
  
  // États
  static const Color success = Color(0xFFf0fdf4); // green-50
  static const Color successBorder = Color(0xFFbbf7d0); // green-200
  static const Color successText = Color(0xFF166534); // green-800
  static const Color error = Color(0xFFdc2626); // red-600
  static const Color errorDark = Color(0xFF991b1b); // red-800
  static const Color errorLight = Color(0xFFfecaca); // red-200
  static const Color errorBackground = Color(0xFFfef2f2); // red-50
  static const Color focus = Color(0xFF2563eb); // blue-600
  static const Color focusGreen = Color(0xFF86efac); // emerald-300
  
  // Autres
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x0F000000); // rgba(0,0,0,0.06)

  /// Thème clair CareLink
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: emerald,
      surface: cardBackground,
      background: background,
      error: error,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: cardBackground,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      surfaceTintColor: Colors.transparent,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Poppins',
        color: textSecondary,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 11,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderSlate, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderSlate, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 14,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: shadow,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textGreen,
        backgroundColor: cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: accent, width: 2),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      color: cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),

    primaryIconTheme: const IconThemeData(
      color: primary,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: borderSlate,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: green50,
      selectedColor: primary.withOpacity(0.1),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textGreen,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: green100, width: 1),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// Thème sombre CareLink
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF0b1220),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: emerald,
      surface: const Color(0xFF1e293b),
      background: const Color(0xFF0b1220),
      error: error,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1e293b),
      foregroundColor: white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: white,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: white,
        size: 24,
      ),
      surfaceTintColor: Colors.transparent,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF94a3b8),
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        color: white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF94a3b8),
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 11,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1e293b),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: textTertiary,
        fontSize: 14,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: accent, width: 2),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      color: const Color(0xFF1e293b),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: white,
      size: 24,
    ),

    primaryIconTheme: const IconThemeData(
      color: primary,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1e293b),
      selectedColor: primary.withOpacity(0.2),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// Dégradé Hero CareLink - Identique au Dashboard (135deg, #ecfdf5 0%, #d1fae5 40%, #ffffff 100%)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.4, 1.0],
    colors: [
      Color(0xFFecfdf5), // green-50
      Color(0xFFd1fae5), // green-100
      Color(0xFFFFFFFF), // white
    ],
  );

  /// Dégradé bouton solide CareLink
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primary,      // #16a34a
      emerald,      // #10b981
      primary,      // #16a34a
    ],
  );

  /// Dégradé texte CareLink
  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primary,      // #16a34a
      primaryLight, // #22c55e
      accent,       // #86efac
    ],
  );
}
