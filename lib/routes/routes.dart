import 'package:flutter/material.dart';
import 'package:suayed/screens/about_screen.dart';
import 'package:suayed/screens/areas_screen.dart';
import 'package:suayed/screens/bookmarks_screen.dart';
import 'package:suayed/screens/calendario_screen.dart';
import 'package:suayed/screens/home_screen.dart';
import 'package:suayed/screens/privacy_notice.dart';
import 'package:suayed/screens/notifications_screen.dart';
import 'package:suayed/screens/teachers_screen.dart';
import 'package:suayed/utils/app_constants.dart';

class Routes {
  static const String home = HomeScreen.routeName;
  static const String teachers = TeachersPage.routeName;
  static const String areas = AreasPage.routeName;
  static const String calendario = CalendarioScreen.routeName;
  static const String bookmarks = BookmarksScreen.routeName;
  static const String notifications = NotificationsScreen.routeName;
  static const String privacy = PrivacyNotice.routeName;
  static const String about = AboutScreen.routeName;

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      Routes.home: (context) => HomeScreen(title: Constants.appName),
      Routes.teachers: (context) => const TeachersPage(title: 'Profesores'),
      Routes.areas: (context) => const AreasPage(title: 'Coordinación SUAyED'),
      Routes.calendario: (context) => const CalendarioScreen(title: 'Calendario Escolar'),
      Routes.bookmarks: (context) => const BookmarksScreen(title: 'Marcadores'),
      Routes.notifications: (context) => const NotificationsScreen(title: 'Notificaciones'),
      Routes.privacy: (context) => const PrivacyNotice(),
      Routes.about: (context) => const AboutScreen(title: 'Acerca de la aplicación'),
    };
  }
}
