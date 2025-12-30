// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Industrial Scandinavian Dashboard Theme
/// High contrast minimalist design optimized for driving safety
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================
  // COLOR PALETTE
  // ============================================================

  /// Accent color - Safety Orange
  static const Color accentPrimary = Color(0xFFFF6B35);
  static const Color accentDark = Color(0xFFE85A2A);
  static const Color accentLight = Color(0xFFFF8859);

  /// Status Colors
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusPurple = Color(0xFF8B5CF6);

  /// Light Mode Status Backgrounds
  static const Color statusSuccessLightBg = Color(0xFFD1FAE5);
  static const Color statusWarningLightBg = Color(0xFFFEF3C7);
  static const Color statusErrorLightBg = Color(0xFFFEE2E2);
  static const Color statusInfoLightBg = Color(0xFFDBEAFE);
  static const Color statusPurpleLightBg = Color(0xFFEDE9FE);

  /// Dark Mode Status Backgrounds
  static const Color statusSuccessDarkBg = Color(0xFF064E3B);
  static const Color statusWarningDarkBg = Color(0xFF78350F);
  static const Color statusErrorDarkBg = Color(0xFF7F1D1D);
  static const Color statusInfoDarkBg = Color(0xFF1E3A8A);
  static const Color statusPurpleDarkBg = Color(0xFF4C1D95);

  // ============================================================
  // SPACING SCALE
  // ============================================================

  static const double space1 = 8.0;
  static const double space2 = 16.0;
  static const double space3 = 24.0;
  static const double space4 = 32.0;
  static const double space5 = 48.0;
  static const double space6 = 64.0;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // ============================================================
  // TOUCH TARGET (Minimum for driving safety)
  // ============================================================

  static const double touchTarget = 60.0;
  static const double touchTargetMedium = 56.0;

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        onPrimary: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Colors.black,
        error: statusError,
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFFF8F9FA),
      ),

      // Scaffold
      scaffoldBackgroundColor: Colors.white,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(
            color: Colors.black,
            width: 3,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(
              color: accentPrimary,
              width: 2,
            ),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          side: const BorderSide(
            color: Colors.black,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          minimumSize: const Size(0, touchTargetMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: statusError,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4A5568),
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          color: const Color(0xFFA0AEC0),
        ),
      ),

      // Typography
      textTheme: TextTheme(
        // Headings
        displayLarge: GoogleFonts.rajdhani(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.rajdhani(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          height: 1.3,
        ),
        displaySmall: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          height: 1.3,
        ),

        // Body
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF4A5568),
          height: 1.5,
        ),

        // Labels
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        labelMedium: GoogleFonts.ibmPlexMono(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A5568),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Colors.black,
        thickness: 2,
        space: 32,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentPrimary,
        unselectedItemColor: Color(0xFF4A5568),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        surface: Color(0xFF000000),
        onSurface: Colors.white,
        error: statusError,
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFF1A1A1A),
      ),

      // Scaffold
      scaffoldBackgroundColor: Colors.black,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF262626),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(
              color: accentPrimary,
              width: 2,
            ),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          side: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          minimumSize: const Size(0, touchTargetMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFF333333),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFF333333),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: statusError,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFFA0AEC0),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          color: Color(0xFF4A5568),
        ),
      ),

      // Typography
      textTheme: const TextTheme(
        // Headings
        displayLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.3,
        ),

        // Body
        bodyLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA0AEC0),
          height: 1.5,
        ),

        // Labels
        labelLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFA0AEC0),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Colors.white,
        thickness: 2,
        space: 32,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: accentPrimary,
        unselectedItemColor: Color(0xFFA0AEC0),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
