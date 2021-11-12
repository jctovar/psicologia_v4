import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:suayed/pages/about_page.dart';
import 'package:suayed/pages/areas_page.dart';
import 'package:suayed/pages/bookmarks_page.dart';
import 'package:suayed/pages/home_page.dart';
import 'package:suayed/pages/teachers_page.dart';
import 'package:suayed/routes/routes.dart';
import 'package:json_store/json_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Tratando de inicializar FirebaseMessaging");
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;
  final appTitle = 'Psicología SUAyED';
  final _jsonStore = JsonStore(dbName: 'suayed');

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);


  late FirebaseMessaging messaging;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        print('inicializada...');
        _pushMessaging();
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        print('error grave...');
        _error = true;
      });
    }
  }

  _pushMessaging() {
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      print('token: $value');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
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

