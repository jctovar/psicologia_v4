class PostModel {

  final int id;
  String date;
  String title;
  String link;
  String image;
  String excerpt;

  PostModel({required this.id, required this.date, required this.title, required this.link, required this.excerpt, required this.image});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        date: json['date'].toString(),
        title: json['title']['rendered'].toString(),
        image: json['jetpack-related-posts'][0]['img']['src'].toString(),
        excerpt: json['jetpack-related-posts'][0]['excerpt'].toString(),
        link: json['link'].toString()
    );
  }
}