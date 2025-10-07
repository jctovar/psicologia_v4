import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
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

      return (response.data as List).map((x) => PostModel.fromJson(x)).toList();
    } on DioError catch (e) {
      if (e.type == DioErrorType.receiveTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }
}
