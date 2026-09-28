import 'dart:async';

import 'package:dio/dio.dart';
import 'package:suayed/services/http_service.dart';

/// Respuesta simulada para una página de la API de posts.
sealed class FakePage {
  const FakePage();

  /// Página exitosa con los posts de los [ids] dados.
  const factory FakePage.posts(List<int> ids) = _PostsPage;

  /// Falla con un [DioException] del [type] dado (ej. timeout).
  const factory FakePage.dioError(DioExceptionType type) = _ErrorPage;

  /// Responde con un código HTTP de error (ej. 500).
  const factory FakePage.status(int statusCode) = _StatusPage;
}

class _PostsPage extends FakePage {
  const _PostsPage(this.ids);
  final List<int> ids;
}

class _ErrorPage extends FakePage {
  const _ErrorPage(this.type);
  final DioExceptionType type;
}

class _StatusPage extends FakePage {
  const _StatusPage(this.statusCode);
  final int statusCode;
}

/// JSON mínimo de un post con la estructura de la API de WordPress.
Map<String, dynamic> wordPressPostJson(int id) => {
  'id': id,
  'date': '2026-01-01T00:00:00',
  'title': {'rendered': 'Post $id'},
  'link': 'https://example.com/$id',
  'jetpack_featured_media_url': '',
  'content': {'rendered': '<p>Contenido $id</p>'},
};

/// Simula la API de WordPress sobre el cliente global [dio], sin red.
///
/// `flutter test` bloquea HTTP real (toda petición recibe 400), así que las
/// pruebas que usan [dio] deben instalar este fake para ejercer el código real
/// de [HttpProvider] y [HomeProvider] con respuestas controladas.
///
/// ```dart
/// late FakeWordPressApi api;
/// setUpAll(() async => api = await FakeWordPressApi.install());
/// setUp(() => api.reset());
///
/// api.pages[1] = const FakePage.posts([3, 2, 1]);
/// ```
class FakeWordPressApi {
  FakeWordPressApi._();

  static FakeWordPressApi? _installed;

  /// Inicializa [dio] con cache en memoria e intercepta sus peticiones.
  /// Idempotente dentro de un mismo archivo de pruebas.
  static Future<FakeWordPressApi> install() async {
    if (_installed != null) return _installed!;
    await initHttpService(useMemoryCache: true);
    final api = FakeWordPressApi._();
    dio.interceptors.insert(0, InterceptorsWrapper(onRequest: api._onRequest));
    return _installed = api;
  }

  /// Respuesta por número de página. Una página no configurada responde 404.
  final Map<int, FakePage> pages = {};

  /// Valor del header `X-WP-TotalPages` (`null` = omitir el header).
  String? totalPagesHeader = '1';

  /// Valor del header `X-WP-Total` (`null` = omitir el header).
  String? totalPostsHeader = '0';

  /// Peticiones recibidas, en orden.
  final List<RequestOptions> requests = [];

  /// Si no es `null`, las respuestas esperan a que se complete. Sirve para
  /// observar estados intermedios (isLoading, isLoadingMore).
  Completer<void>? gate;

  /// Restablece la configuración entre pruebas.
  void reset() {
    pages.clear();
    totalPagesHeader = '1';
    totalPostsHeader = '0';
    requests.clear();
    gate = null;
  }

  /// Configura [count] páginas de [perPage] posts con ids descendentes, como
  /// las devuelve WordPress (más reciente primero).
  void setUpPages(int count, {int perPage = 3}) {
    final total = count * perPage;
    for (var page = 1; page <= count; page++) {
      final first = total - (page - 1) * perPage;
      pages[page] = FakePage.posts([
        for (var id = first; id > first - perPage; id--) id,
      ]);
    }
    totalPagesHeader = '$count';
    totalPostsHeader = '$total';
  }

  /// Número de página solicitado en [options].
  static int pageOf(RequestOptions options) =>
      int.parse(RegExp(r'[&?]page=(\d+)').firstMatch(options.path)!.group(1)!);

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    requests.add(options);
    if (gate != null) await gate!.future;

    final page = pages[pageOf(options)];
    switch (page) {
      case _PostsPage(:final ids):
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: ids.map(wordPressPostJson).toList(),
            headers: Headers.fromMap({
              if (totalPagesHeader != null)
                'X-WP-TotalPages': [totalPagesHeader!],
              if (totalPostsHeader != null) 'X-WP-Total': [totalPostsHeader!],
            }),
          ),
        );
      case _ErrorPage(:final type):
        handler.reject(DioException(requestOptions: options, type: type));
      case _StatusPage(:final statusCode):
        handler.reject(_badResponse(options, statusCode));
      case null:
        handler.reject(_badResponse(options, 404));
    }
  }

  static DioException _badResponse(RequestOptions options, int statusCode) =>
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: statusCode),
      );
}
