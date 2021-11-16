import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  //App related strings
  static String appName = 'Psicología SUAyED';
  static String uriSUAyED="https://suayed.iztacala.unam.mx/feed/json";

  static Color mainColor = const Color.fromARGB(0xff, 0xe1, 0x0c, 0x35);

  static TextStyle mainStyleTitle = const TextStyle(
    fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: -.3,
  );

  static TextStyle mainStyleSubtitle = const TextStyle(
    fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, letterSpacing: -.1,
  );
}
