import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:suayed/utils/app_constants.dart';

var options = BaseOptions(
  baseUrl: Constants.uriHttp,
  connectTimeout: const Duration(milliseconds: 5000),
  receiveTimeout: const Duration(milliseconds: 3000),
  receiveDataWhenStatusError: true,
);

// Cache options
final cacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  maxStale: const Duration(days: 7),
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);

Dio dio = Dio(options)
  ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
