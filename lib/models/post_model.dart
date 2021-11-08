import 'package:intl/intl.dart';

class PostModel {
  PostModel({
    required this.id,
    required this.date,
    required this.title,
    required this.link,
    required this.excerpt,
    required this.image,
    required this.content,
  });

  final int id;
  final DateTime date;
  final String title;
  final String link;
  final String image;
  final String excerpt;
  final String content;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        date: DateTime.parse(json['date']),
        title: json['title']['rendered'].toString(),
        image: json['jetpack_featured_media_url'].toString(),
        excerpt: json['jetpack-related-posts'][0]['excerpt'].toString(),
        content: json['content']['rendered'],
        link: json['link'].toString()
    );
  }
}