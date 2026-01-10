import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

/// Servicio de logging centralizado para toda la aplicación
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static FirebaseCrashlytics? get _crashlytics {
    try {
      return FirebaseCrashlytics.instance;
    } catch (e) {
      // Firebase no está inicializado (probablemente en tests)
      return null;
    }
  }

  /// Log de debug - para información detallada de debugging
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _crashlytics?.log('[DEBUG] $message');
  }

  /// Log de información - para mensajes informativos generales
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _crashlytics?.log('[INFO] $message');
  }

  /// Log de warning - para situaciones potencialmente problemáticas
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _crashlytics?.log('[WARNING] $message');

    // Reportar warnings a Crashlytics como errores no fatales
    if (error != null) {
      _crashlytics?.recordError(
        error,
        stackTrace,
        reason: message.toString(),
        fatal: false,
      );
    }
  }

  /// Log de error - para errores que requieren atención
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _crashlytics?.log('[ERROR] $message');

    // Reportar errores a Crashlytics como errores no fatales
    if (error != null) {
      _crashlytics?.recordError(
        error,
        stackTrace,
        reason: message.toString(),
        fatal: false,
      );
    } else {
      // Si no hay un error específico, crear uno con el mensaje
      _crashlytics?.recordError(
        Exception(message),
        stackTrace ?? StackTrace.current,
        reason: message.toString(),
        fatal: false,
      );
    }
  }

  /// Log fatal - para errores críticos
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _crashlytics?.log('[FATAL] $message');

    // Reportar errores fatales a Crashlytics
    if (error != null) {
      _crashlytics?.recordError(
        error,
        stackTrace,
        reason: message.toString(),
        fatal: true,
      );
    } else {
      _crashlytics?.recordError(
        Exception(message),
        stackTrace ?? StackTrace.current,
        reason: message.toString(),
        fatal: true,
      );
    }
  }
}
