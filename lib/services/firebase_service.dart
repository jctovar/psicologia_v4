import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// This must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class FirebaseService {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _subscribeToTopics();
    await _requestPermissions();
    _setupForegroundListener();
    _setupOnMessageOpenedAppListener();
  }

  static Future<void> _subscribeToTopics() async {
    await FirebaseMessaging.instance.subscribeToTopic('posts');
    await FirebaseMessaging.instance.subscribeToTopic('alerts');
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          provisional: false,
          sound: true,
        );

    if (kDebugMode) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else {
        print('User declined or has not accepted permission');
      }
    }
  }

  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (kDebugMode) {
        print("Foreground message received: ${event.notification?.body}");
      }
    });
  }

  static void _setupOnMessageOpenedAppListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print('Message clicked!');
      }
    });
  }
}
