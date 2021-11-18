
class PostModel {
  PostModel({
    required this.id,
    required this.date,
    required this.title,
    required this.link,
    required this.image,
    required this.content,
  });

  final int id;
  final DateTime date;
  final String title;
  final String link;
  final String image;
  final String content;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title']['rendered'],
      link: json['link'].toString(),
      image: json['jetpack_featured_media_url'],
      content: json['content']['rendered'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toString(),
    "title": title,
    "link": link,
    "image": image,
    "content": content,
  };
}