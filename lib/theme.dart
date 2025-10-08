import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Centralized color definition, moved from app_constants.dart
const Color _seedColor = Color(0xffe10c35);

ThemeData suayedTheme = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: const Color(
    0xFFFDF8F8,
  ), // A slightly off-white for a softer look
  // Generate a cohesive ColorScheme from a single seed color
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
    primary: _seedColor,
    onPrimary: Colors.white,
    secondary: const Color(0xFF5C5C5C), // A complementary grey
    onSecondary: Colors.white,
    error: const Color(0xFFB00020),
    onError: Colors.white,
    surface: const Color(0xFFFDF8F8),
    onSurface: const Color(0xFF1C1B1F),
  ),

  // Define a unified TextTheme
  textTheme: TextTheme(
    // Title style from app_constants.dart, now part of the theme
    titleLarge: GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Colors.blue, // Use the primary color for titles
      letterSpacing: -.3,
    ),
    // Subtitle style from app_constants.dart
    titleMedium: GoogleFonts.montserrat(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: -.1,
    ),
    // Subtitle style from app_constants.dart
    titleSmall: GoogleFonts.montserrat(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -.1,
    ),
    bodyLarge: GoogleFonts.montserrat(
      textStyle: const TextStyle(color: Color(0xFF333333), letterSpacing: .5),
    ),
    bodyMedium: GoogleFonts.montserrat(
      textStyle: const TextStyle(color: Color(0xFF5C5C5C), letterSpacing: .5),
    ),
    labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
  ),

  // Define modern component themes
  appBarTheme: AppBarTheme(
    backgroundColor: _seedColor,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: _seedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: _seedColor,
  ),

  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
  ),
);
