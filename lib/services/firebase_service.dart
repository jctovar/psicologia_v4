import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:suayed/firebase_options.dart';
import 'package:suayed/models/notification_model.dart';
import 'package:suayed/services/logger_service.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:localstore/localstore.dart';

// Esta debe ser una función de nivel superior
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.d("📱 Background message: ${message.messageId}");
  AppLogger.d("📱 Title: ${message.notification?.title}");
  AppLogger.d("📱 Body: ${message.notification?.body}");
  AppLogger.d("📱 Data: ${message.data}");

  // Guardar notificación en almacenamiento local
  await _saveNotificationToStorage(message);
}

// Función auxiliar para guardar notificación (debe ser de nivel superior)
Future<void> _saveNotificationToStorage(RemoteMessage message) async {
  try {
    if (message.messageId == null) {
      AppLogger.w('⚠️ Message has no ID, skipping save');
      return;
    }

    final notification = NotificationModel.fromRemoteMessage(
      message.messageId!,
      message.notification?.title,
      message.notification?.body,
      message.data,
    );

    final db = Localstore.instance;
    await db
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());

    AppLogger.i('✅ Notification saved to storage (ID: ${notification.id})');
  } catch (e) {
    AppLogger.e('❌ Error saving notification to storage', e);
  }
}

class FirebaseService {
  static Future<void> initialize() async {
    AppLogger.d('🔥 Initializing Firebase services');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('✅ Firebase Core initialized');

    // Configurar manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    AppLogger.d('📨 Background message handler configured');

    // Solicitar permisos primero
    await _requestPermissions();

    // Suscribirse a tópicos
    await _subscribeToTopics();

    // Configurar listeners
    _setupForegroundListener();
    _setupOnMessageOpenedAppListener();
    _checkInitialMessage();

    // Obtener y registrar token FCM (útil para debugging)
    _logFCMToken();

    AppLogger.i('✅ Firebase Messaging configured');
  }

  static Future<void> _subscribeToTopics() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('posts');
      await FirebaseMessaging.instance.subscribeToTopic('alerts');
      AppLogger.i('✅ Subscribed to topics: posts, alerts');
    } catch (e) {
      AppLogger.e('❌ Error subscribing to topics: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
        criticalAlert: false,
        announcement: false,
      );

      AppLogger.d('🔔 Notification permission status: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.i('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.w('⚠️ User granted provisional notification permission');
      } else {
        AppLogger.e('❌ User declined notification permission');
      }
    } catch (e) {
      AppLogger.e('❌ Error requesting permissions: $e');
    }
  }

  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.d("📬 Foreground message received: ${message.messageId}");
      AppLogger.d("📬 Title: ${message.notification?.title}");
      AppLogger.d("📬 Body: ${message.notification?.body}");
      AppLogger.d("📬 Data: ${message.data}");

      // Guardar notificación en almacenamiento local
      await _saveNotificationToStorage(message);

      // Mostrar snackbar para notificaciones en primer plano
      if (message.notification != null) {
        final notification = message.notification!;
        final title = notification.title ?? '';
        final body = notification.body ?? '';

        final snackBar = SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (body.isNotEmpty) Text(body),
            ],
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {
              _handleMessageTap(message);
            },
          ),
        );
        Constants.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      }
    });
  }

  static void _setupOnMessageOpenedAppListener() {
    // Manejar cuando la app está en segundo plano y el usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d('🔔 Notification tapped (app in background)');
      AppLogger.d('🔔 Message ID: ${message.messageId}');
      AppLogger.d('🔔 Data: ${message.data}');
      _handleMessageTap(message);
    });
  }

  static Future<void> _checkInitialMessage() async {
    // Manejar cuando la app se abre desde estado terminado mediante notificación
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      AppLogger.d('🚀 App opened from terminated state via notification');
      AppLogger.d('🚀 Message ID: ${initialMessage.messageId}');
      AppLogger.d('🚀 Data: ${initialMessage.data}');
      _handleMessageTap(initialMessage);
    }
  }

  static void _handleMessageTap(RemoteMessage message) {
    // Manejar navegación basada en datos de notificación
    AppLogger.d('👆 Handling notification tap');
    AppLogger.d('👆 Data: ${message.data}');

    // Navegar a la pantalla de notificaciones
    final context = Constants.scaffoldMessengerKey.currentContext;
    if (context != null) {
      Navigator.pushNamed(context, 'notifications');
    } else {
      AppLogger.w('⚠️ Cannot navigate: context is null');
    }
  }

  static Future<void> _logFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        AppLogger.d('🔑 FCM Token: $token');
        AppLogger.i('💡 Use this token for testing push notifications');
      }

      // Escuchar actualizaciones de token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        AppLogger.d('🔄 FCM Token refreshed: $newToken');
        // TODO: Enviar nuevo token a tu servidor si es necesario
      });
    } catch (e) {
      AppLogger.e('❌ Error getting FCM token: $e');
    }
  }
}
