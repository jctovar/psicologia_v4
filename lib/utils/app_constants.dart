import 'dart:ui';
import 'package:flutter/material.dart';

class Constants {
  //App related strings
  static String appName = 'Psicología SUAyED';
  static String uriHttp="https://suayed.iztacala.unam.mx/";

  static Color mainColor = const Color.fromARGB(0xff, 0xe1, 0x0c, 0x35);

  static TextStyle mainStyleTitle = const TextStyle(
    fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: -.3,
  );

  static TextStyle mainStyleSubtitle = const TextStyle(
    fontSize: 14.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, letterSpacing: -.1,
  );
}
