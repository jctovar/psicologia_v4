import 'package:suayed/models/post_model.dart';
import 'package:suayed/models/storage_post_model.dart';

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
