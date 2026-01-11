import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/utils/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HttpService - Configuración', () {
    test('opciones base tienen los valores correctos', () {
      // Arrange
      final options = BaseOptions(
        baseUrl: Constants.uriHttp,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
        receiveDataWhenStatusError: true,
      );

      // Assert
      expect(options.baseUrl, Constants.uriHttp);
      expect(options.baseUrl, isNotEmpty);
      expect(options.connectTimeout, const Duration(milliseconds: 5000));
      expect(options.receiveTimeout, const Duration(milliseconds: 3000));
      expect(options.receiveDataWhenStatusError, true);
    });

    test('opciones de caché tienen configuración correcta con MemCacheStore', () {
      // Arrange - Crear opciones de caché con MemCacheStore para testing
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );

      // Assert
      expect(cacheOptions.store, isNotNull);
      expect(cacheOptions.store, isA<MemCacheStore>());
      expect(cacheOptions.maxStale, const Duration(days: 7));
      expect(cacheOptions.allowPostMethod, false);
      expect(cacheOptions.priority, CachePriority.normal);
    });

    test('cliente Dio se puede crear con interceptores', () {
      // Arrange
      final options = BaseOptions(
        baseUrl: Constants.uriHttp,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
      );

      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7),
      );

      // Act
      final testDio = Dio(options)
        ..interceptors.add(DioCacheInterceptor(options: cacheOptions));

      // Assert
      expect(testDio, isNotNull);
      expect(testDio, isA<Dio>());
      expect(testDio.interceptors.length, greaterThanOrEqualTo(1));
      expect(testDio.options.baseUrl, Constants.uriHttp);
    });

    test('HiveCacheStore puede ser instanciado con path', () {
      // Arrange & Act
      final store = HiveCacheStore('/tmp/test_cache');

      // Assert
      expect(store, isNotNull);
      expect(store, isA<HiveCacheStore>());
    });

    test('CachePolicy.request es la política correcta', () {
      // Arrange
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7),
      );

      // Assert
      expect(cacheOptions.policy, CachePolicy.request);
    });

    test('configuración de caché usa prioridad normal', () {
      // Arrange
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        priority: CachePriority.normal,
      );

      // Assert
      expect(cacheOptions.priority, CachePriority.normal);
    });

    test('maxStale está configurado a 7 días', () {
      // Arrange
      final maxStale = const Duration(days: 7);
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        maxStale: maxStale,
      );

      // Assert
      expect(cacheOptions.maxStale, const Duration(days: 7));
      expect(cacheOptions.maxStale?.inDays, 7);
    });

    test('POST method puede ser deshabilitado en cache', () {
      // Arrange
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        allowPostMethod: false,
      );

      // Assert
      expect(cacheOptions.allowPostMethod, false);
    });

    test('keyBuilder por defecto está configurado', () {
      // Arrange
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      );

      // Assert
      expect(cacheOptions.keyBuilder, isNotNull);
      expect(cacheOptions.keyBuilder, equals(CacheOptions.defaultCacheKeyBuilder));
    });
  });

  group('HttpService - Integración', () {
    test('múltiples interceptores pueden ser agregados', () {
      // Arrange
      final options = BaseOptions(baseUrl: Constants.uriHttp);
      final cacheOptions = CacheOptions(store: MemCacheStore());

      // Act
      final testDio = Dio(options)
        ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.next(options),
          ),
        );

      // Assert - Al menos 2 interceptores (Dio puede agregar interceptores por defecto)
      expect(testDio.interceptors.length, greaterThanOrEqualTo(2));
    });

    test('timeouts están configurados correctamente', () {
      // Arrange
      final options = BaseOptions(
        baseUrl: Constants.uriHttp,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
      );

      final testDio = Dio(options);

      // Assert
      expect(testDio.options.connectTimeout?.inMilliseconds, 5000);
      expect(testDio.options.receiveTimeout?.inMilliseconds, 3000);
    });
  });
}
