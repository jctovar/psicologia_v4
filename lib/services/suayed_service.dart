import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:suayed/models/post_model.dart';
import 'http_service.dart';

class SuayedServices {

  static Future<List<PostModel>> getPosts(bool refreshCache) async {
    DioCacheManager dioCacheManager = DioCacheManager(CacheConfig());

    Options cacheOptions = buildCacheOptions(const Duration(days: 3), forceRefresh: refreshCache);

    dio.interceptors.add(dioCacheManager.interceptor);

    try {
      Response response = await dio.request('wp-json/wp/v2/posts?per_page=15',
          options: cacheOptions);

      return (response.data as List).map((x) => PostModel.fromJson(x)).toList();
    } on DioError catch (e) {
      if(e.type == DioErrorType.receiveTimeout){
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }

  // Old function, only for documentation for jsonDecode
  /*
  static Future<List> getWP() async {
    // response['title']['rendered']
    final requestUri = Uri.https(
        'suayed.iztacala.unam.mx', '/wp-json/wp/v2/posts', { '_embed' : '' }
    );
    try {
      final response = await http.get(requestUri, headers: {'Accept': 'application/json'});
      var convert = jsonDecode(response.body);
      return convert;
    } on DioError catch (e) {
      if(e.type == DioErrorType.receiveTimeout){
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }*/
}
