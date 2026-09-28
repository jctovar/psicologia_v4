import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/posts_service.dart';

import '../helpers/fake_wordpress_api.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWordPressApi api;

  setUpAll(() async {
    api = await FakeWordPressApi.install();
  });

  setUp(() => api.reset());

  group('PostsResponse', () {
    test('se crea correctamente con todos los campos', () {
      final posts = createTestPosts(5);
      final response = PostsResponse(
        posts: posts,
        totalPages: 3,
        totalPosts: 45,
      );

      expect(response.posts.length, 5);
      expect(response.totalPages, 3);
      expect(response.totalPosts, 45);
    });
  });

  group('HttpProvider.getPosts - Petición', () {
    test('usa page=1 y per_page=15 por defecto', () async {
      api.pages[1] = const FakePage.posts([1]);

      await HttpProvider.getPosts();

      expect(
        api.requests.single.path,
        '?rest_route=/wp/v2/posts&per_page=15&page=1',
      );
    });

    test('incluye page y perPage recibidos en el endpoint', () async {
      api.pages[2] = const FakePage.posts([1]);

      await HttpProvider.getPosts(page: 2, perPage: 10);

      expect(
        api.requests.single.path,
        '?rest_route=/wp/v2/posts&per_page=10&page=2',
      );
    });

    test('sin refreshCache no fuerza política de cache', () async {
      api.pages[1] = const FakePage.posts([1]);

      await HttpProvider.getPosts();

      expect(api.requests.single.getCacheOptions(), isNull);
    });

    test('refreshCache=true usa CachePolicy.refresh', () async {
      api.pages[1] = const FakePage.posts([1]);

      await HttpProvider.getPosts(refreshCache: true);

      expect(
        api.requests.single.getCacheOptions()?.policy,
        CachePolicy.refresh,
      );
    });
  });

  group('HttpProvider.getPosts - Respuesta', () {
    test('convierte el JSON en PostModel manteniendo el orden', () async {
      api.pages[1] = const FakePage.posts([30, 20, 10]);

      final response = await HttpProvider.getPosts();

      expect(response.posts, everyElement(isA<PostModel>()));
      expect(response.posts.map((p) => p.id), [30, 20, 10]);
      expect(response.posts.first.title, 'Post 30');
    });

    test('lee totalPages y totalPosts de los headers de WordPress', () async {
      api.pages[1] = const FakePage.posts([1]);
      api.totalPagesHeader = '5';
      api.totalPostsHeader = '75';

      final response = await HttpProvider.getPosts();

      expect(response.totalPages, 5);
      expect(response.totalPosts, 75);
    });

    test('usa 1 página y 0 posts si faltan los headers', () async {
      api.pages[1] = const FakePage.posts([1]);
      api.totalPagesHeader = null;
      api.totalPostsHeader = null;

      final response = await HttpProvider.getPosts();

      expect(response.totalPages, 1);
      expect(response.totalPosts, 0);
    });

    test('usa los valores por defecto si los headers no son números', () async {
      api.pages[1] = const FakePage.posts([1]);
      api.totalPagesHeader = 'invalid';
      api.totalPostsHeader = 'not-a-number';

      final response = await HttpProvider.getPosts();

      expect(response.totalPages, 1);
      expect(response.totalPosts, 0);
    });

    test('acepta una página vacía', () async {
      api.pages[1] = const FakePage.posts([]);

      final response = await HttpProvider.getPosts();

      expect(response.posts, isEmpty);
    });
  });

  group('HttpProvider.getPosts - Manejo de errores', () {
    Future<void> expectErrorMessage(FakePage page, String message) async {
      api.pages[1] = page;
      await expectLater(
        HttpProvider.getPosts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensaje',
            'Exception: $message',
          ),
        ),
      );
    }

    const sinConexion =
        'No se pudo conectar al servidor. Revisa tu conexión a internet.';

    test('connectionTimeout → mensaje de conexión', () async {
      await expectErrorMessage(
        const FakePage.dioError(DioExceptionType.connectionTimeout),
        sinConexion,
      );
    });

    test('receiveTimeout → mensaje de conexión', () async {
      await expectErrorMessage(
        const FakePage.dioError(DioExceptionType.receiveTimeout),
        sinConexion,
      );
    });

    test('sendTimeout → mensaje de conexión', () async {
      await expectErrorMessage(
        const FakePage.dioError(DioExceptionType.sendTimeout),
        sinConexion,
      );
    });

    test(
      'respuesta HTTP de error → mensaje de respuesta del servidor',
      () async {
        await expectErrorMessage(
          const FakePage.status(500),
          'Ocurrió un error al procesar la respuesta del servidor.',
        );
      },
    );

    test('solicitud cancelada → mensaje de cancelación', () async {
      await expectErrorMessage(
        const FakePage.dioError(DioExceptionType.cancel),
        'La solicitud fue cancelada.',
      );
    });

    test('otro error de Dio → mensaje genérico', () async {
      await expectErrorMessage(
        const FakePage.dioError(DioExceptionType.connectionError),
        'Ocurrió un error inesperado.',
      );
    });
  });

  group('Integración con PostModel', () {
    test('PostModel.fromJson maneja respuesta de WordPress', () {
      final wordPressJson = {
        'id': 123,
        'date': '2024-06-15T10:30:00',
        'title': {'rendered': 'Título del Post'},
        'link': 'https://suayed.iztacala.unam.mx/post/123',
        'jetpack_featured_media_url':
            'https://suayed.iztacala.unam.mx/image.jpg',
        'content': {'rendered': '<p>Contenido del post</p>'},
      };

      final post = PostModel.fromJson(wordPressJson);

      expect(post.id, 123);
      expect(post.title, 'Título del Post');
      expect(post.link, 'https://suayed.iztacala.unam.mx/post/123');
      expect(post.image, 'https://suayed.iztacala.unam.mx/image.jpg');
      expect(post.content, '<p>Contenido del post</p>');
    });

    test('PostModel usa cadena vacía si la imagen es nula', () {
      final jsonWithNullImage = {
        'id': 1,
        'date': '2024-01-01T00:00:00',
        'title': {'rendered': 'Post sin imagen'},
        'link': 'https://example.com',
        'jetpack_featured_media_url': null,
        'content': {'rendered': 'Contenido'},
      };

      final post = PostModel.fromJson(jsonWithNullImage);

      expect(post.image, '');
    });
  });
}
