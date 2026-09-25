import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // Las fuentes van incluidas en assets/google_fonts/: no descargarlas
    GoogleFonts.config.allowRuntimeFetching = false;
    _registerFontLicenses();

    // Tareas independientes entre sí: se ejecutan en paralelo
    await Future.wait([
      // Inicializar servicio HTTP con cache persistente
      initHttpService(),
      // Precargar fuentes desde assets
      _preloadFonts(),
      // Inicializar Firebase Core y Crashlytics lo antes posible para
      // reportar errores del resto del arranque
      FirebaseService.initialize().then((_) => CrashlyticsService.initialize()),
    ]);

    AppLogger.i('✅ App initialization complete');
    runApp(const AppState());

    // Permisos, tópicos y mensaje inicial no deben bloquear el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.setupMessaging();
    });
  }, (error, stack) {
    // Captura errores asíncronos no manejados
    AppLogger.f('Unhandled async error: $error', error, stack);
  });
}

Future<void> _preloadFonts() async {
  try {
    await AppFonts.preloadFonts();
    AppLogger.i('✅ Fonts preloaded successfully');
  } catch (e) {
    AppLogger.w('⚠️ Font preloading failed: $e');
  }
}

/// Registra las licencias OFL de las fuentes incluidas en assets.
void _registerFontLicenses() {
  const families = ['Poppins', 'Montserrat', 'Lora'];
  LicenseRegistry.addLicense(() async* {
    for (final family in families) {
      final license =
          await rootBundle.loadString('assets/google_fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], license);
    }
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
