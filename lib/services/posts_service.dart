import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/logger_service.dart';
import 'http_service.dart';

class PostsResponse {
  final List<PostModel> posts;
  final int totalPages;
  final int totalPosts;

  PostsResponse({
    required this.posts,
    required this.totalPages,
    required this.totalPosts,
  });
}

class HttpProvider {
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
