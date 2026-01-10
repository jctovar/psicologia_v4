import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/logger_service.dart';
import 'http_service.dart';

/// Respuesta paginada de la API de posts.
///
/// Contiene la lista de posts junto con metadatos de paginacion
/// obtenidos de los headers HTTP de WordPress.
class PostsResponse {
  /// Lista de posts obtenidos en esta pagina.
  final List<PostModel> posts;

  /// Numero total de paginas disponibles en la API.
  /// Obtenido del header `X-WP-TotalPages`.
  final int totalPages;

  /// Numero total de posts disponibles en la API.
  /// Obtenido del header `X-WP-Total`.
  final int totalPosts;

  /// Crea una respuesta de posts con metadatos de paginacion.
  PostsResponse({
    required this.posts,
    required this.totalPages,
    required this.totalPosts,
  });
}

/// Proveedor HTTP para operaciones con posts de WordPress.
///
/// Proporciona metodos estaticos para obtener posts de la API REST
/// de WordPress con soporte para paginacion y cache.
class HttpProvider {
  /// Obtiene una lista paginada de posts desde la API de WordPress.
  ///
  /// Parametros:
  /// - [page]: Numero de pagina a obtener (por defecto 1).
  /// - [perPage]: Cantidad de posts por pagina (por defecto 15).
  /// - [refreshCache]: Si es `true`, ignora el cache y obtiene datos frescos.
  ///
  /// Retorna un [PostsResponse] que contiene:
  /// - La lista de posts para la pagina solicitada
  /// - El numero total de paginas disponibles
  /// - El numero total de posts disponibles
  ///
  /// Lanza [Exception] con mensaje en espanol si ocurre un error:
  /// - Timeout de conexion/recepcion
  /// - Respuesta invalida del servidor
  /// - Solicitud cancelada
  /// - Error inesperado
  ///
  /// Ejemplo:
  /// ```dart
  /// // Obtener primera pagina
  /// final response = await HttpProvider.getPosts();
  ///
  /// // Obtener segunda pagina con cache fresco
  /// final page2 = await HttpProvider.getPosts(page: 2, refreshCache: true);
  ///
  /// // Verificar si hay mas paginas
  /// if (page2.totalPages > 2) {
  ///   // Cargar mas...
  /// }
  /// ```
  static Future<PostsResponse> getPosts({
    int page = 1,
    int perPage = 15,
    bool refreshCache = false,
  }) async {
    Options? requestOptions;
    if (refreshCache) {
      AppLogger.d('🔄 Refresh cache requested');
      requestOptions = CacheOptions(
        policy: CachePolicy.refresh,
        store: null,
      ).toOptions();
    }

    try {
      AppLogger.d('🌐 Requesting posts from API (page: $page)');
      Response response = await dio.request(
        '?rest_route=/wp/v2/posts&per_page=$perPage&page=$page',
        options: requestOptions,
      );

      final posts = (response.data as List).map((x) => PostModel.fromJson(x)).toList();
      final totalPages = int.tryParse(response.headers.value('X-WP-TotalPages') ?? '1') ?? 1;
      final totalPosts = int.tryParse(response.headers.value('X-WP-Total') ?? '0') ?? 0;

      AppLogger.i('✅ API request successful: page $page/$totalPages, ${posts.length} posts');
      return PostsResponse(
        posts: posts,
        totalPages: totalPages,
        totalPosts: totalPosts,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('⏱️ Timeout error', e);
        throw Exception(
          "No se pudo conectar al servidor. Revisa tu conexión a internet.",
        );
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('❌ Bad response from server', e);
        throw Exception(
          "Ocurrió un error al procesar la respuesta del servidor.",
        );
      } else if (e.type == DioExceptionType.cancel) {
        AppLogger.w('🚫 Request cancelled', e);
        throw Exception("La solicitud fue cancelada.");
      } else {
        AppLogger.e('❌ Unexpected error fetching posts', e);
        throw Exception("Ocurrió un error inesperado.");
      }
    }
  }
}

// Response response = await dio.request('?rest_route=/wp/v2/posts&per_page=15',
