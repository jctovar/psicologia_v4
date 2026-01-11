import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:suayed/services/logger_service.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:path_provider/path_provider.dart';

var options = BaseOptions(
  baseUrl: Constants.uriHttp,
  connectTimeout: const Duration(milliseconds: 5000),
  receiveTimeout: const Duration(milliseconds: 3000),
  receiveDataWhenStatusError: true,
);

// Inicializar el cache store de Hive
Future<HiveCacheStore> _initHiveCacheStore() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return HiveCacheStore(appDocDir.path);
}

// Opciones de caché (será inicializado de manera asíncrona)
late CacheOptions cacheOptions;

// Variable para rastrear si el servicio ya fue inicializado
bool _isInitialized = false;

// Interceptor de logging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('🔵 HTTP Request: ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d(
      '🟢 HTTP Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '🔴 HTTP Error: ${err.type} ${err.requestOptions.uri}',
      err.error,
    );
    super.onError(err, handler);
  }
}

// Cliente Dio (será inicializado con cache persistente)
late final Dio dio;

// Inicializar el servicio HTTP con cache persistente
Future<void> initHttpService({
  bool useMemoryCache = false,
  bool forceReinit = false,
}) async {
  // Si ya está inicializado y no se fuerza reinicialización, retornar
  if (_isInitialized && !forceReinit) {
    return;
  }

  // Crear el store de caché (Hive para producción, Memory para testing)
  final CacheStore cacheStore;
  if (useMemoryCache) {
    cacheStore = MemCacheStore();
    AppLogger.i('✅ HTTP service initialized with memory cache (testing mode)');
  } else {
    cacheStore = await _initHiveCacheStore();
    AppLogger.i('✅ HTTP service initialized with persistent cache');
  }

  // Configurar las opciones de caché
  cacheOptions = CacheOptions(
    store: cacheStore,
    policy: CachePolicy.request,
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  // Crear el cliente Dio con los interceptores
  dio = Dio(options)
    ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
    ..interceptors.add(LoggingInterceptor());

  _isInitialized = true;
}
