import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/post_model.dart';

void main() {
  group('PostModel', () {
    test('fromJson creates a valid PostModel instance', () {
      // Arrange
      final json = {
        'id': 123,
        'date': '2024-01-15T10:30:00',
        'title': {'rendered': 'Test Post Title'},
        'link': 'https://example.com/post',
        'jetpack_featured_media_url': 'https://example.com/image.jpg',
        'content': {'rendered': '<p>Test content</p>'},
      };

      // Act
      final post = PostModel.fromJson(json);

      // Assert
      expect(post.id, 123);
      expect(post.title, 'Test Post Title');
      expect(post.link, 'https://example.com/post');
      expect(post.image, 'https://example.com/image.jpg');
      expect(post.content, '<p>Test content</p>');
      expect(post.date, DateTime.parse('2024-01-15T10:30:00'));
    });

    test('toJson creates a valid JSON map', () {
      // Arrange
      final date = DateTime.parse('2024-01-15T10:30:00');
      final post = PostModel(
        id: 456,
        date: date,
        title: 'Another Test Post',
        link: 'https://example.com/another-post',
        image: 'https://example.com/another-image.jpg',
        content: '<p>Another test content</p>',
      );

      // Act
      final json = post.toJson();

      // Assert
      expect(json['id'], 456);
      expect(json['title'], 'Another Test Post');
      expect(json['link'], 'https://example.com/another-post');
      expect(json['image'], 'https://example.com/another-image.jpg');
      expect(json['content'], '<p>Another test content</p>');
      expect(json['date'], date.toString());
    });

    test('fromJson and toJson are reversible', () {
      // Arrange
      final originalJson = {
        'id': 789,
        'date': '2024-03-20T15:45:00',
        'title': {'rendered': 'Reversible Test'},
        'link': 'https://example.com/reversible',
        'jetpack_featured_media_url': 'https://example.com/reversible.jpg',
        'content': {'rendered': '<p>Reversible content</p>'},
      };

      // Act
      final post = PostModel.fromJson(originalJson);
      final resultJson = post.toJson();

      // Assert
      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['title'], (originalJson['title'] as Map)['rendered']);
      expect(resultJson['link'], originalJson['link']);
    });

    test('creates PostModel with all required fields', () {
      // Arrange & Act
      final date = DateTime.now();
      final post = PostModel(
        id: 1,
        date: date,
        title: 'Title',
        link: 'link',
        image: 'image',
        content: 'content',
      );

      // Assert
      expect(post.id, 1);
      expect(post.date, date);
      expect(post.title, 'Title');
      expect(post.link, 'link');
      expect(post.image, 'image');
      expect(post.content, 'content');
    });
  });
}
