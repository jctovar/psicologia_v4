import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suayed/theme.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/screens/about_screen.dart';
import 'package:suayed/screens/areas_screen.dart';
import 'package:suayed/screens/bookmarks_screen.dart';
import 'package:suayed/screens/home_screen.dart';
import 'package:suayed/screens/teachers_screen.dart';
import 'package:suayed/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.subscribeToTopic('posts');
  await FirebaseMessaging.instance.subscribeToTopic('alerts');

  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print('User granted permission');
    }
  } else {
    if (kDebugMode) {
      print('User declined or has not accepted permission');
    }
  }

  runApp(const MyApp());
}

////////////////////////////////////////////////////////////////////////////////
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

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
      if (kDebugMode) {
        print("message recieved");
      }
      if (kDebugMode) {
        print(event.notification!.body);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print('Message clicked!');
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: suayedTheme,
      home: HomeScreen(title: Constants.appName),
      routes: {
        Routes.home: (context) => HomeScreen(title: Constants.appName),
        Routes.teachers: (context) => const TeachersPage(title: 'Profesores'),
        Routes.areas: (context) =>
            const AreasPage(title: 'Coordinación SUAyED'),
        Routes.bookmarks: (context) => const BookmarksPage(title: 'Marcadores'),
        Routes.about: (context) => const AboutPage(),
      },
      navigatorObservers: [_MyAppState.observer],
    );
  }
}
