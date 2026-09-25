import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/providers/home_provider.dart';
import 'package:suayed/services/http_service.dart';

/// Post mínimo con la estructura de la API de WordPress.
Map<String, dynamic> _post(int id) => {
  'id': id,
  'date': '2026-01-01T00:00:00',
  'title': {'rendered': 'Post $id'},
  'link': 'https://example.com/$id',
  'jetpack_featured_media_url': '',
  'content': {'rendered': '<p>$id</p>'},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Respuestas simuladas por número de página. `null` simula un error.
  late Map<int, List<int>?> pages;

  setUpAll(() async {
    await initHttpService(useMemoryCache: true);
    // Interceptor que responde sin red según `pages`
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final page = int.parse(
            RegExp(r'[&?]page=(\d+)').firstMatch(options.path)!.group(1)!,
          );
          final ids = pages[page];
          if (ids == null) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
            return;
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: ids.map(_post).toList(),
              headers: Headers.fromMap({
                'X-WP-TotalPages': ['3'],
              }),
            ),
          );
        },
      ),
    );
  });

  test('loadMore descarta posts repetidos al desplazarse la paginación',
      () async {
    // Se publicó un post nuevo: la página 2 repite el último de la página 1
    pages = {
      1: [10, 9, 8],
      2: [8, 7, 6],
    };
    final provider = HomeProvider();

    await provider.fetchPosts();
    await provider.loadMore();

    expect(provider.posts.map((p) => p.id), [10, 9, 8, 7, 6]);
    expect(provider.loadMoreError, isNull);
  });

  test('loadMore guarda el error y permite reintentar', () async {
    pages = {
      1: [10, 9, 8],
      2: null,
    };
    final provider = HomeProvider();

    await provider.fetchPosts();
    await provider.loadMore();

    expect(provider.loadMoreError, isNotNull);
    expect(provider.posts.length, 3);

    // Reintento exitoso limpia el error
    pages[2] = [7, 6];
    await provider.loadMore();

    expect(provider.loadMoreError, isNull);
    expect(provider.posts.map((p) => p.id), [10, 9, 8, 7, 6]);
  });

  test('fetchPosts limpia loadMoreError', () async {
    pages = {
      1: [10, 9, 8],
      2: null,
    };
    final provider = HomeProvider();

    await provider.fetchPosts();
    await provider.loadMore();
    expect(provider.loadMoreError, isNotNull);

    await provider.fetchPosts(refresh: true);
    expect(provider.loadMoreError, isNull);
  });
}
