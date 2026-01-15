import 'package:dio/dio.dart';
import 'package:suayed/models/calendario_model.dart';
import 'package:suayed/services/logger_service.dart';
import 'http_service.dart';

/// Servicio para obtener el calendario escolar desde una fuente externa.
///
/// Usa Dio con cache persistente (HiveCacheStore, 7 días max-stale)
/// para minimizar llamadas a la red y mejorar rendimiento offline.
///
/// Ejemplo de uso:
/// ```dart
/// // Obtener calendario (usa cache si está disponible)
/// final calendario = await CalendarioService.getCalendario();
///
/// // Forzar actualización (ignora cache)
/// final calendarioFresco = await CalendarioService.getCalendario(
///   forceRefresh: true,
/// );
/// ```
class CalendarioService {
  /// URL externa del calendario en formato JSON.
  static const String calendarioUrl =
      'https://jctovar.github.io/calendario.json';

  /// Obtiene el calendario escolar completo.
  ///
  /// Parámetros:
  /// - [forceRefresh]: Si es `true`, ignora el cache y obtiene datos frescos
  ///   desde la red. Útil para pull-to-refresh.
  ///
  /// Retorna un [CalendarioModel] con toda la información del calendario,
  /// incluyendo periodos, eventos, y días inhábiles.
  ///
  /// Lanza [Exception] con mensaje en español si ocurre un error:
  /// - Timeout de conexión/recepción: "No se pudo conectar al servidor..."
  /// - Respuesta inválida del servidor: "Ocurrió un error al obtener..."
  /// - Solicitud cancelada: "La solicitud fue cancelada."
  /// - Error de parsing JSON: "Ocurrió un error al procesar los datos..."
  /// - Error inesperado: "Ocurrió un error inesperado..."
  ///
  /// El calendario se guarda en cache automáticamente por 7 días (configuración
  /// global de Dio). Funciona offline mientras el cache sea válido.
  static Future<CalendarioModel> getCalendario({
    bool forceRefresh = false,
  }) async {
    try {
      AppLogger.d('📅 Requesting calendario from external URL');

      // Configurar opciones de cache si se requiere refresh
      Options? requestOptions;
      if (forceRefresh) {
        AppLogger.d('🔄 Refresh cache requested for calendario');
        // Usar header Cache-Control para forzar actualización
        requestOptions = Options(
          headers: {'Cache-Control': 'no-cache'},
        );
      }

      // Realizar petición HTTP
      Response response = await dio.get(
        calendarioUrl,
        options: requestOptions,
      );

      AppLogger.i('✅ Calendario fetched successfully');

      // Log para debugging
      AppLogger.d('Calendario JSON keys: ${response.data.keys}');

      // Parsear y retornar modelo
      return CalendarioModel.fromJson(response.data);
    } on DioException catch (e) {
      // Manejar diferentes tipos de errores de Dio
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('⏱️ Timeout error fetching calendario', e);
        throw Exception(
          "No se pudo conectar al servidor. Revisa tu conexión a internet.",
        );
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('❌ Bad response from servidor', e);
        throw Exception(
          "Ocurrió un error al obtener el calendario. Código de estado: ${e.response?.statusCode}",
        );
      } else if (e.type == DioExceptionType.cancel) {
        AppLogger.w('🚫 Request cancelled', e);
        throw Exception("La solicitud fue cancelada.");
      } else {
        AppLogger.e('❌ Unexpected DioException fetching calendario', e);
        throw Exception(
          "Ocurrió un error inesperado al cargar el calendario.",
        );
      }
    } catch (e) {
      // Capturar errores de parsing JSON u otros errores no relacionados con Dio
      AppLogger.e('❌ Error parsing calendario JSON', e);
      throw Exception(
        "Ocurrió un error al procesar los datos del calendario.",
      );
    }
  }
}
