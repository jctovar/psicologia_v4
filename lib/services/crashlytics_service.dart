import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:suayed/services/logger_service.dart';

/// Servicio de Crashlytics para reportar errores y crashes
class CrashlyticsService {
  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Inicializa Crashlytics y configura el manejo de errores
  static Future<void> initialize() async {
    try {
      // Habilita la recolección de crashes solo en modo release
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Configura Flutter para enviar errores a Crashlytics
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        // Reportar a Crashlytics
        _crashlytics.recordFlutterFatalError(errorDetails);

        // También log local
        AppLogger.f(
          'Flutter Fatal Error: ${errorDetails.exception}',
          errorDetails.exception,
          errorDetails.stack,
        );
      };

      // Captura errores que ocurren fuera del framework de Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        AppLogger.f('Platform Error: $error', error, stack);
        return true;
      };

      AppLogger.i('✅ Crashlytics initialized (enabled: ${!kDebugMode})');
    } catch (e) {
      AppLogger.e('❌ Error initializing Crashlytics', e);
    }
  }

  /// Reporta un error no fatal a Crashlytics
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
      AppLogger.d('📊 Error recorded to Crashlytics: $exception');
    } catch (e) {
      AppLogger.e('❌ Failed to record error to Crashlytics', e);
    }
  }

  /// Registra un mensaje personalizado en Crashlytics
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      AppLogger.e('❌ Failed to log to Crashlytics', e);
    }
  }

  /// Establece un ID de usuario para rastrear errores por usuario
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      AppLogger.d('👤 Crashlytics user ID set: $userId');
    } catch (e) {
      AppLogger.e('❌ Failed to set user ID in Crashlytics', e);
    }
  }

  /// Establece una clave-valor personalizada para contexto adicional
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      AppLogger.d('🔑 Crashlytics custom key set: $key = $value');
    } catch (e) {
      AppLogger.e('❌ Failed to set custom key in Crashlytics', e);
    }
  }

  /// Fuerza un crash (solo para testing)
  static void forceCrash() {
    if (kDebugMode) {
      AppLogger.w('⚠️ Force crash called in debug mode - ignoring');
      return;
    }
    _crashlytics.crash();
  }
}
