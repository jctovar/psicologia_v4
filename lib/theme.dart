import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData suayedTheme = ThemeData(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.pinkAccent,

    brightness: Brightness.light,
  ).copyWith(primary: Colors.blue.shade400, secondary: Colors.pink.shade400),
  useMaterial3: true,
  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  scaffoldBackgroundColor: const Color.fromARGB(255, 245, 237, 222),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.pinkAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.pinkAccent,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.volkhov(fontSize: 24, fontStyle: FontStyle.normal),
    labelSmall: GoogleFonts.montserrat(),
    bodyMedium: GoogleFonts.montserrat(
      textStyle: const TextStyle(color: Colors.black87, letterSpacing: .5),
    ),
    displaySmall: GoogleFonts.pacifico(),
  ),
);
