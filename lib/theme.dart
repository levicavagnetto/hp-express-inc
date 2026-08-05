import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primary = Color(0xFFD71921);      // Brand Crimson Red
  static const Color primaryDark = Color(0xFFA21318);  // Crimson Dark
  static const Color accent = Color(0xFF0E4B8F);       // Brand Royal Blue
  static const Color navyDark = Color(0xFF0D1D39);     // Steel Navy (Dark Theme Background)
  static const Color navyMedium = Color(0xFF153160);   // Dark Steel Medium
  static const Color navyLight = Color(0xFF1B4778);    // Dark Steel Light
  static const Color bgLight = Color(0xFFF4F6FA);      // Light Surface Background
  static const Color cardBg = Color(0xFFFFFFFF);       // White Card Background
  static const Color textDark = Color(0xFF152239);     // Dark Text
  static const Color textMuted = Color(0xFF5B6C86);    // Muted/Secondary Text

  // Layout Constraints
  static const double maxContentWidth = 1180.0;

  // ThemeData configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bgLight,
      cardColor: cardBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: cardBg,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textDark,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMuted,
          height: 1.6,
        ),
      ),
    );
  }
}
