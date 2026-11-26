import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──
  static const Color black = Color(0xFF0A0A0A);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color mediumGrey = Color(0xFF6B6B6B);
  static const Color lightGrey = Color(0xFFB0B0B0);
  static const Color borderGrey = Color(0xFFE8E8E8);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2D2D2D);

  // ── Spacing ──
  static const double sp4 = 4;
  static const double sp8 = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp48 = 48;

  // ── Radius ──
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ── Durations ──
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 800);

  // ── Curves ──
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.easeOutBack;

  // ── TextStyles ──
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: -1,
  );

  static TextStyle displayMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
  );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    letterSpacing: 1.5,
  );

  static TextStyle mono(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.surface,
  );

  // ── ThemeData ──
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: black,
        onPrimary: white,
        surface: white,
        onSurface: black,
        outline: borderGrey,
        surfaceContainerHighest: surfaceGrey,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: black,
          letterSpacing: 2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: black,
        unselectedItemColor: lightGrey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      colorScheme: const ColorScheme.dark(
        primary: white,
        onPrimary: black,
        surface: darkGrey,
        onSurface: white,
        outline: accent,
        surfaceContainerHighest: black,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: lightGrey,
        displayColor: white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: white,
          letterSpacing: 2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: black,
        selectedItemColor: white,
        unselectedItemColor: mediumGrey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: accent,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
