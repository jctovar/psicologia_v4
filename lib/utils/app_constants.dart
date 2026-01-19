import 'package:flutter/material.dart';

class Constants {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  //App related strings
  static String appName = 'Psicología SUAyED';
  static String uriHttp = 'https://suayed.iztacala.unam.mx/';
  static const String placeholderImg = 'assets/images/no_image.jpg';
}
