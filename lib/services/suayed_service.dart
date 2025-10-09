import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:suayed/models/post_model.dart';
import 'http_service.dart';

class SuayedServices {
  static Future<List<PostModel>> getPosts(bool refreshCache) async {
    Options? requestOptions;
    if (refreshCache) {
      // Override the global cache policy just for this request
      requestOptions = CacheOptions(
        policy: CachePolicy.refresh,
        store: null,
      ).toOptions();
    }

    try {
      Response response = await dio.request(
        'wp-json/wp/v2/posts?per_page=15',
        options: requestOptions,
      );

      debugPrint('Response data: ${response.data}');

      return (response.data as List).map((x) => PostModel.fromJson(x)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          "No se pudo conectar al servidor. Revisa tu conexión a internet.",
        );
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          "Ocurrió un error al procesar la respuesta del servidor.",
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception("La solicitud fue cancelada.");
      } else {
        debugPrint('Response data: ${e.error}');
        throw Exception("Ocurrió un error inesperado.");
      }
    }
  }
}
