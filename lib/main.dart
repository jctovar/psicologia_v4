import 'dart:io';
import 'package:flutter/material.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/pages/about_page.dart';
import 'package:suayed/pages/areas_page.dart';
import 'package:suayed/pages/bookmarks_page.dart';
import 'package:suayed/pages/home_page.dart';
import 'package:suayed/pages/teachers_page.dart';
import 'package:suayed/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.subscribeToTopic('posts');

  runApp(const MyApp());
}

////////////////////////////////////////////////////////////////////////////////
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();

    /*messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      print('valor:');
      print(value);
    });*/

    if (Platform.isIOS) {
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
            .copyWith(secondary: Colors.pinkAccent),
        fontFamily: 'Roboto',
      ),
      home: HomePage(title: Constants.appName),
      routes: {
        Routes.home: (context) => HomePage(title: Constants.appName),
        Routes.teachers: (context) => const TeachersPage(title: 'Profesores'),
        Routes.areas: (context) => const AreasPage(title: 'Coordinación SUAyED'),
        Routes.bookmarks: (context) => const BookmarksPage(title: 'Marcadores'),
        Routes.about: (context) => const AboutPage(),
      },
    );
  }
}
