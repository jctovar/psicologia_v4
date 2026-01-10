import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/storage_post_model.dart';

void main() {
  group('StoragePost', () {
    test('fromJson creates a valid StoragePost instance', () {
      // Arrange
      final json = {
        'id': 123,
        'date': '2024-01-15T10:30:00.000',
        'title': 'Bookmark Title',
        'link': 'https://example.com/bookmark',
        'image': 'https://example.com/bookmark-image.jpg',
        'content': '<p>Bookmark content</p>',
      };

      // Act
      final storagePost = StoragePost.fromJson(json);

      // Assert
      expect(storagePost.id, 123);
      expect(storagePost.title, 'Bookmark Title');
      expect(storagePost.link, 'https://example.com/bookmark');
      expect(storagePost.image, 'https://example.com/bookmark-image.jpg');
      expect(storagePost.content, '<p>Bookmark content</p>');
      expect(storagePost.date, DateTime.parse('2024-01-15T10:30:00.000'));
    });

    test('toJson creates a valid JSON map', () {
      // Arrange
      final date = DateTime.parse('2024-02-20T14:45:00');
      final storagePost = StoragePost(
        id: 456,
        date: date,
        title: 'Another Bookmark',
        link: 'https://example.com/another-bookmark',
        image: 'https://example.com/another-bookmark-image.jpg',
        content: '<p>Another bookmark content</p>',
      );

      // Act
      final json = storagePost.toJson();

      // Assert
      expect(json['id'], 456);
      expect(json['title'], 'Another Bookmark');
      expect(json['link'], 'https://example.com/another-bookmark');
      expect(json['image'], 'https://example.com/another-bookmark-image.jpg');
      expect(json['content'], '<p>Another bookmark content</p>');
      expect(json['date'], date.toIso8601String());
    });

    test('fromJson and toJson are reversible', () {
      // Arrange
      final originalJson = {
        'id': 789,
        'date': '2024-03-25T09:15:00.000',
        'title': 'Reversible Bookmark',
        'link': 'https://example.com/reversible-bookmark',
        'image': 'https://example.com/reversible-image.jpg',
        'content': '<p>Reversible content</p>',
      };

      // Act
      final storagePost = StoragePost.fromJson(originalJson);
      final resultJson = storagePost.toJson();

      // Assert
      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['title'], originalJson['title']);
      expect(resultJson['link'], originalJson['link']);
      expect(resultJson['image'], originalJson['image']);
      expect(resultJson['content'], originalJson['content']);
    });

    test('creates StoragePost with all required fields', () {
      // Arrange & Act
      final date = DateTime.now();
      final storagePost = StoragePost(
        id: 1,
        date: date,
        title: 'Title',
        link: 'link',
        image: 'image',
        content: 'content',
      );

      // Assert
      expect(storagePost.id, 1);
      expect(storagePost.date, date);
      expect(storagePost.title, 'Title');
      expect(storagePost.link, 'link');
      expect(storagePost.image, 'image');
      expect(storagePost.content, 'content');
    });
  });
}
