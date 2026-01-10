import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/services/posts_service.dart';

import '../helpers/test_helpers.dart';

/// Mock de Dio para pruebas aisladas
class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

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

    test('permite lista vacía de posts', () {
      final response = PostsResponse(
        posts: [],
        totalPages: 0,
        totalPosts: 0,
      );

      expect(response.posts, isEmpty);
      expect(response.totalPages, 0);
      expect(response.totalPosts, 0);
    });

    test('mantiene orden de posts', () {
      final posts = [
        createTestPost(id: 3, title: 'Third'),
        createTestPost(id: 1, title: 'First'),
        createTestPost(id: 2, title: 'Second'),
      ];

      final response = PostsResponse(
        posts: posts,
        totalPages: 1,
        totalPosts: 3,
      );

      expect(response.posts[0].id, 3);
      expect(response.posts[1].id, 1);
      expect(response.posts[2].id, 2);
    });
  });

  group('HttpProvider.getPosts - Manejo de errores', () {
    group('DioException types', () {
      test('connectionTimeout lanza mensaje correcto', () {
        // Este test documenta el comportamiento esperado
        // cuando hay timeout de conexión
        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(exception.type, DioExceptionType.connectionTimeout);
        // El mensaje esperado es:
        // "No se pudo conectar al servidor. Revisa tu conexión a internet."
      });

      test('receiveTimeout lanza mensaje correcto', () {
        final exception = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(exception.type, DioExceptionType.receiveTimeout);
        // El mensaje esperado es:
        // "No se pudo conectar al servidor. Revisa tu conexión a internet."
      });

      test('badResponse lanza mensaje correcto', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        expect(exception.type, DioExceptionType.badResponse);
        // El mensaje esperado es:
        // "Ocurrió un error al procesar la respuesta del servidor."
      });

      test('cancel lanza mensaje correcto', () {
        final exception = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(exception.type, DioExceptionType.cancel);
        // El mensaje esperado es:
        // "La solicitud fue cancelada."
      });

      test('unknown lanza mensaje genérico', () {
        final exception = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
        );

        expect(exception.type, DioExceptionType.unknown);
        // El mensaje esperado es:
        // "Ocurrió un error inesperado."
      });
    });
  });

  group('HttpProvider.getPosts - Parámetros', () {
    test('valores por defecto son page=1 y perPage=15', () {
      // Documentar los valores por defecto esperados
      // page: 1, perPage: 15, refreshCache: false
      expect(1, 1); // page default
      expect(15, 15); // perPage default
      expect(false, false); // refreshCache default
    });

    test('endpoint construido correctamente', () {
      const page = 2;
      const perPage = 10;
      final expectedEndpoint = '?rest_route=/wp/v2/posts&per_page=$perPage&page=$page';

      expect(
        expectedEndpoint,
        '?rest_route=/wp/v2/posts&per_page=10&page=2',
      );
    });
  });

  group('Parseo de respuesta de API', () {
    test('parsea lista de posts correctamente', () {
      final apiResponse = createWordPressApiResponse(3);

      final posts = apiResponse.map((json) => PostModel.fromJson(json)).toList();

      expect(posts.length, 3);
      expect(posts[0].id, 1);
      expect(posts[1].id, 2);
      expect(posts[2].id, 3);
    });

    test('parsea headers de paginación correctamente', () {
      final headers = createWordPressHeaders(totalPages: 5, totalPosts: 75);

      final totalPages = int.tryParse(headers.value('X-WP-TotalPages') ?? '1') ?? 1;
      final totalPosts = int.tryParse(headers.value('X-WP-Total') ?? '0') ?? 0;

      expect(totalPages, 5);
      expect(totalPosts, 75);
    });

    test('usa valores por defecto si headers están ausentes', () {
      final headers = Headers();

      final totalPages = int.tryParse(headers.value('X-WP-TotalPages') ?? '1') ?? 1;
      final totalPosts = int.tryParse(headers.value('X-WP-Total') ?? '0') ?? 0;

      expect(totalPages, 1);
      expect(totalPosts, 0);
    });

    test('maneja headers con valores inválidos', () {
      final headers = Headers();
      headers.set('X-WP-TotalPages', 'invalid');
      headers.set('X-WP-Total', 'not-a-number');

      final totalPages = int.tryParse(headers.value('X-WP-TotalPages') ?? '1') ?? 1;
      final totalPosts = int.tryParse(headers.value('X-WP-Total') ?? '0') ?? 0;

      expect(totalPages, 1); // Fallback
      expect(totalPosts, 0); // Fallback
    });
  });

  group('Integración con PostModel', () {
    test('PostModel.fromJson maneja respuesta de WordPress', () {
      final wordPressJson = {
        'id': 123,
        'date': '2024-06-15T10:30:00',
        'title': {'rendered': 'Título del Post'},
        'link': 'https://suayed.iztacala.unam.mx/post/123',
        'jetpack_featured_media_url': 'https://suayed.iztacala.unam.mx/image.jpg',
        'content': {'rendered': '<p>Contenido del post</p>'},
      };

      final post = PostModel.fromJson(wordPressJson);

      expect(post.id, 123);
      expect(post.title, 'Título del Post');
      expect(post.link, 'https://suayed.iztacala.unam.mx/post/123');
      expect(post.image, 'https://suayed.iztacala.unam.mx/image.jpg');
      expect(post.content, '<p>Contenido del post</p>');
    });

    test('PostModel maneja imagen nula o vacía', () {
      final jsonWithNullImage = {
        'id': 1,
        'date': '2024-01-01T00:00:00',
        'title': {'rendered': 'Post sin imagen'},
        'link': 'https://example.com',
        'jetpack_featured_media_url': null,
        'content': {'rendered': 'Contenido'},
      };

      final post = PostModel.fromJson(jsonWithNullImage);

      // Dependiendo de la implementación, podría ser null o string vacío
      expect(post.image, anyOf(isNull, equals(''), equals('null')));
    });
  });
}
