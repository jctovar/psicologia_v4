import 'dart:io';
import 'package:flutter/material.dart';
import 'package:suayed/utils/constants.dart';
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
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

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
  bool userIsLoggedIn = false;
  final appTitle = Constants.appName;
  //late FirebaseMessaging messaging;

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
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
            .copyWith(secondary: Colors.pinkAccent),
        fontFamily: 'Roboto',
      ),
      home: HomePage(title: appTitle),
      routes: {
        Routes.home: (context) => const HomePage(title: 'SUAyED'),
        Routes.teachers: (context) => const TeachersPage(title: 'Profesores'),
        Routes.areas: (context) => const AreasPage(title: 'Coordinación SUAyED'),
        Routes.bookmarks: (context) => const BookmarksPage(title: 'Marcadores'),
        Routes.about: (context) => const AboutPage(),
      },
    );
  }
}
