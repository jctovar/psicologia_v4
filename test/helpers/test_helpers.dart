import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/models/storage_post_model.dart';

/// Mock de Dio para pruebas HTTP
class MockDio extends Mock implements Dio {}

/// Mock de RequestOptions para Dio
class FakeRequestOptions extends Fake implements RequestOptions {}

/// Mock de Response para Dio
class FakeResponse<T> extends Fake implements Response<T> {
  @override
  final T data;

  @override
  final Headers headers;

  @override
  final int? statusCode;

  FakeResponse({
    required this.data,
    Headers? headers,
    this.statusCode = 200,
  }) : headers = headers ?? Headers();
}

/// Genera un PostModel de prueba
PostModel createTestPost({
  int id = 1,
  String title = 'Test Post',
  String link = 'https://example.com/test',
  String image = 'https://example.com/image.jpg',
  String content = '<p>Test content</p>',
  DateTime? date,
}) {
  return PostModel(
    id: id,
    date: date ?? DateTime.now(),
    title: title,
    link: link,
    image: image,
    content: content,
  );
}

/// Genera un StoragePost de prueba
StoragePost createTestStoragePost({
  int id = 1,
  String title = 'Test Storage Post',
  String link = 'https://example.com/test',
  String image = 'https://example.com/image.jpg',
  String content = '<p>Test content</p>',
  DateTime? date,
}) {
  return StoragePost(
    id: id,
    date: date ?? DateTime.now(),
    title: title,
    link: link,
    image: image,
    content: content,
  );
}

/// Genera una lista de PostModels de prueba
List<PostModel> createTestPosts(int count) {
  return List.generate(
    count,
    (index) => createTestPost(
      id: index + 1,
      title: 'Test Post ${index + 1}',
      link: 'https://example.com/post-${index + 1}',
    ),
  );
}

/// Genera JSON de respuesta de API de WordPress
List<Map<String, dynamic>> createWordPressApiResponse(int count) {
  return List.generate(
    count,
    (index) => {
      'id': index + 1,
      'date': DateTime.now().toIso8601String(),
      'title': {'rendered': 'Post ${index + 1}'},
      'link': 'https://example.com/post-${index + 1}',
      'jetpack_featured_media_url': 'https://example.com/image-${index + 1}.jpg',
      'content': {'rendered': '<p>Content for post ${index + 1}</p>'},
    },
  );
}

/// Crea Headers de respuesta de WordPress con paginación
Headers createWordPressHeaders({
  int totalPages = 1,
  int totalPosts = 15,
}) {
  final headers = Headers();
  headers.set('X-WP-TotalPages', totalPages.toString());
  headers.set('X-WP-Total', totalPosts.toString());
  return headers;
}

/// Registra fallback values para mocktail
void registerFallbackValues() {
  registerFallbackValue(FakeRequestOptions());
}
