import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suayed/screens/home_screen.dart';
import 'package:suayed/services/http_service.dart';
import 'package:provider/provider.dart';
import 'package:suayed/providers/bookmark_provider.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/providers/notification_provider.dart';
import 'package:suayed/providers/theme_provider.dart';
import 'package:suayed/routes/routes.dart';
import 'package:suayed/services/crashlytics_service.dart';
import 'package:suayed/services/firebase_service.dart';
import 'package:suayed/services/logger_service.dart';
import 'package:suayed/theme.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/utils/analytics.dart';

Future<void> main() async {
  // Captura errores asíncronos que ocurren fuera del runApp
  await runZonedGuarded(() async {
    AppLogger.i('🚀 Starting SUAyED App');

    // Inicializar Hive para cache persistente
    await Hive.initFlutter();
    AppLogger.i('✅ Hive initialized');

    // Inicializar servicio HTTP con cache persistente
    await initHttpService();

    // Precargar fuentes de la aplicación para mejor rendimiento
    try {
      await AppFonts.preloadFonts();
      AppLogger.i('✅ Fonts preloaded successfully');
    } catch (e) {
      AppLogger.w('⚠️ Font preloading failed, will load on demand: $e');
    }

    // Asegurar que los widgets están inicializados e inicializar servicios de Firebase
    await FirebaseService.initialize();

    // Inicializar Crashlytics
    await CrashlyticsService.initialize();

    AppLogger.i('✅ App initialization complete');
    runApp(const AppState());
  }, (error, stack) {
    // Captura errores asíncronos no manejados
    AppLogger.f('Unhandled async error: $error', error, stack);
  });
}

////////////////////////////////////////////////////////////////////////////////
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()..fetchPosts()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de tu aplicación.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: Constants.navigatorKey,
          scaffoldMessengerKey: Constants.scaffoldMessengerKey,
          theme: iztacalaTheme,
          darkTheme: iztacalaDarkTheme,
          themeMode: themeProvider.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          initialRoute: Routes.home,
          home: const HomeScreen(title: 'Iztacala'),
          routes: Routes.getRoutes(context),
          navigatorObservers: [
            Analytics.observer,
          ],
        );
      },
    );
  }
}
