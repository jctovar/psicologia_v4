class StoragePost {
  StoragePost({
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

  factory StoragePost.fromJson(Map<String, dynamic> json) {
    return StoragePost(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      link: json['link'].toString(),
      image: json['image'],
      content: json['content'],
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